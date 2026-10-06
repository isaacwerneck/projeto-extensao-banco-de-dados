"""Executa e testa o projeto em uma base MySQL exclusiva para validação."""
import argparse
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--mysql', default='mysql')
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', default='3306')
    parser.add_argument('--user', default='root')
    args = parser.parse_args()
    command = [args.mysql, '--no-defaults', '-h', args.host, '-P', args.port,
               '-u', args.user, '--default-character-set=utf8mb4', '--batch']

    def run(sql, fail=False):
        result = subprocess.run(command, input=sql, encoding='utf-8',
                                capture_output=True)
        if fail:
            assert result.returncode != 0, 'Entrada inválida foi aceita: ' + sql
        else:
            assert result.returncode == 0, result.stderr
        return result

    # Não altera o banco utilizado pelo aluno: cria uma base de teste separada.
    database = 'patas_na_rua_validacao'
    run('DROP DATABASE IF EXISTS ' + database)
    script = (ROOT / 'sql/patas_na_rua.sql').read_text(encoding='utf-8')
    result = run(script.replace('patas_na_rua', database))
    (ROOT / 'evidencias').mkdir(exist_ok=True)
    (ROOT / 'evidencias/execucao_mysql.txt').write_text(result.stdout, encoding='utf-8')

    def query(sql):
        lines = run('USE ' + database + ';\n' + sql).stdout.strip().splitlines()
        return {'colunas': lines[0].split('\t'),
                'linhas': [line.split('\t') for line in lines[1:]]}

    tables = ['especie', 'raca', 'voluntario', 'animal', 'veterinario',
              'tratamento', 'adotante', 'adocao', 'doador', 'doacao']
    counts = {table: int(query('SELECT COUNT(*) AS total FROM ' + table)['linhas'][0][0])
              for table in tables}
    assert all(n >= 5 for n in counts.values()), counts
    sections = script.split('-- 3. CONSULTAS SELECT')[1].split('-- 4. ATUALIZACAO')[0]
    import re
    clean = re.sub(r'^--.*$', '', sections, flags=re.M)
    queries = [part.strip() + ';' for part in clean.split(';') if part.strip()]
    results = [query(sql) for sql in queries]
    assert results[0]['linhas'] == [['Cao', '4'], ['Gato', '4'], ['Calopsita', '1'], ['Coelho', '1'], ['Hamster', '0']]
    assert results[1]['linhas'][0] == ['Thor', 'Rafael Nunes', '2', '630.00']
    assert [row[0] for row in results[2]['linhas']] == ['Thor', 'Mel', 'Frida', 'Sol', 'Bob']
    updates = query('SELECT id_voluntario,nome,funcao FROM voluntario WHERE id_voluntario=1')
    assert updates['linhas'][0][2] == 'Coordenacao de resgates'
    deletions = query('SELECT id_doacao,descricao,situacao FROM doacao ORDER BY id_doacao')
    assert len(deletions['linhas']) == 8
    procedure = query('''SELECT ad.id_adocao,a.nome,ad.situacao,ad.data_adocao,a.situacao
        FROM adocao ad JOIN animal a ON a.id_animal=ad.id_animal WHERE ad.id_adocao=5''')
    assert procedure['linhas'] == [['5', 'Bob', 'CONCLUIDA', '2026-09-20', 'ADOTADO']]

    invalid = {
        'raça de outra espécie': 'UPDATE animal SET id_raca=5 WHERE id_animal=1',
        'duas adoções ativas': "INSERT INTO adocao(id_animal,id_adotante,data_solicitacao,situacao) VALUES(4,1,'2026-09-01','EM_ANALISE')",
        'doação financeira sem valor': "INSERT INTO doacao(id_doador,data_doacao,tipo,descricao) VALUES(1,'2026-09-01','FINANCEIRA','Teste')",
        'doação material sem quantidade': "INSERT INTO doacao(id_doador,data_doacao,tipo,descricao,unidade) VALUES(1,'2026-09-01','MATERIAL','Teste','kg')",
        'custo negativo': 'UPDATE tratamento SET valor=-1 WHERE id_tratamento=1',
        'chave estrangeira inexistente': 'UPDATE tratamento SET id_animal=9999 WHERE id_tratamento=1',
        'conclusão duplicada': "CALL sp_concluir_adocao(5,'2026-09-20')",
        'processo não aprovado': "CALL sp_concluir_adocao(2,'2026-09-20')",
        'processo inexistente': "CALL sp_concluir_adocao(9999,'2026-09-20')",
    }
    errors = {}
    for label, sql in invalid.items():
        errors[label] = run('USE ' + database + ';' + sql, fail=True).stderr.strip()

    reset = "USE " + database + "; UPDATE adocao SET situacao='APROVADA',data_adocao=NULL WHERE id_adocao=5; UPDATE animal SET situacao='EM_PROCESSO_ADOCAO' WHERE id_animal=5;"
    run(reset)
    errors['data anterior à análise'] = run('USE ' + database + ";CALL sp_concluir_adocao(5,'2026-01-01')", fail=True).stderr.strip()
    # Provoca uma falha após o primeiro UPDATE da procedure: ambos devem ser desfeitos.
    run('USE ' + database + "; CREATE TRIGGER teste_rollback BEFORE UPDATE ON animal FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Falha controlada';")
    run('USE ' + database + ";CALL sp_concluir_adocao(5,'2026-09-20')", fail=True)
    assert query('SELECT situacao,data_adocao FROM adocao WHERE id_adocao=5')['linhas'] == [['APROVADA','NULL']]
    assert query('SELECT situacao FROM animal WHERE id_animal=5')['linhas'] == [['EM_PROCESSO_ADOCAO']]
    run('USE ' + database + ';DROP TRIGGER teste_rollback;')

    def concurrent(_):
        return subprocess.run(command, input='USE ' + database + ";CALL sp_concluir_adocao(5,'2026-09-20')", encoding='utf-8', capture_output=True).returncode
    with ThreadPoolExecutor(max_workers=2) as pool:
        codes = list(pool.map(concurrent, range(2)))
    assert sum(code == 0 for code in codes) == 1, codes
    assert query('SELECT situacao FROM animal WHERE id_animal=5')['linhas'] == [['ADOTADO']]

    evidence = {'versao': query('SELECT VERSION() AS versao')['linhas'][0][0],
                'registros': counts, 'consultas': results, 'update': updates,
                'delete': deletions, 'procedure': procedure,
                'entradas_invalidas_bloqueadas': errors,
                'rollback': 'confirmado após falha controlada',
                'concorrencia': 'uma conclusão aceita e uma rejeitada'}
    (ROOT / 'evidencias/resultados_mysql.json').write_text(json.dumps(evidence, ensure_ascii=False, indent=2), encoding='utf-8')
    print('MySQL', evidence['versao'], ': todos os testes passaram.')
    print('Contagens:', counts)
    print('Integridade, consultas, CRUD, procedure, rollback e concorrência: OK')


if __name__ == '__main__':
    main()
