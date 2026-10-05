-- Projeto de Extensao em Banco de Dados - ONG Patas na Rua
-- Aluno: Isaac Azevedo Werneck - Matricula: 2024101179
-- SGBD: MySQL 8.0

DROP DATABASE IF EXISTS patas_na_rua;
CREATE DATABASE patas_na_rua
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
USE patas_na_rua;

-- 1. MODELO FISICO

CREATE TABLE especie (
    id_especie INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(255)
);

CREATE TABLE raca (
    id_raca INT AUTO_INCREMENT PRIMARY KEY,
    id_especie INT NOT NULL,
    nome VARCHAR(80) NOT NULL,
    descricao VARCHAR(255),
    CONSTRAINT uq_raca_especie_nome UNIQUE (id_especie, nome),
    CONSTRAINT fk_raca_especie
        FOREIGN KEY (id_especie) REFERENCES especie (id_especie)
);

CREATE TABLE voluntario (
    id_voluntario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(120),
    funcao VARCHAR(80) NOT NULL,
    data_entrada DATE NOT NULL,
    situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO',
    CONSTRAINT ck_voluntario_situacao
        CHECK (situacao IN ('ATIVO', 'INATIVO'))
);

CREATE TABLE animal (
    id_animal INT AUTO_INCREMENT PRIMARY KEY,
    id_especie INT NOT NULL,
    id_raca INT,
    id_voluntario_responsavel INT,
    nome VARCHAR(80) NOT NULL,
    sexo CHAR(1) NOT NULL,
    data_nascimento_estimada DATE,
    porte VARCHAR(10) NOT NULL,
    cor_pelagem VARCHAR(100),
    data_resgate DATE NOT NULL,
    local_resgate VARCHAR(160) NOT NULL,
    situacao VARCHAR(25) NOT NULL,
    observacoes VARCHAR(500),
    CONSTRAINT ck_animal_sexo CHECK (sexo IN ('M', 'F')),
    CONSTRAINT ck_animal_porte CHECK (porte IN ('PEQUENO', 'MEDIO', 'GRANDE')),
    CONSTRAINT ck_animal_situacao CHECK (situacao IN (
        'EM_TRATAMENTO', 'DISPONIVEL_ADOCAO', 'EM_PROCESSO_ADOCAO',
        'ADOTADO', 'FALECIDO'
    )),
    CONSTRAINT fk_animal_especie
        FOREIGN KEY (id_especie) REFERENCES especie (id_especie),
    CONSTRAINT fk_animal_raca
        FOREIGN KEY (id_raca) REFERENCES raca (id_raca),
    CONSTRAINT fk_animal_voluntario
        FOREIGN KEY (id_voluntario_responsavel)
        REFERENCES voluntario (id_voluntario)
);

CREATE TABLE veterinario (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    crmv VARCHAR(20) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(120),
    clinica VARCHAR(120)
);

CREATE TABLE tratamento (
    id_tratamento INT AUTO_INCREMENT PRIMARY KEY,
    id_animal INT NOT NULL,
    id_veterinario INT NOT NULL,
    data_tratamento DATE NOT NULL,
    tipo VARCHAR(80) NOT NULL,
    diagnostico VARCHAR(255),
    descricao VARCHAR(500) NOT NULL,
    valor DECIMAL(10,2) NOT NULL DEFAULT 0,
    data_retorno DATE,
    situacao VARCHAR(12) NOT NULL DEFAULT 'REALIZADO',
    CONSTRAINT ck_tratamento_valor CHECK (valor >= 0),
    CONSTRAINT ck_tratamento_situacao
        CHECK (situacao IN ('AGENDADO', 'REALIZADO', 'CANCELADO')),
    CONSTRAINT fk_tratamento_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal),
    CONSTRAINT fk_tratamento_veterinario
        FOREIGN KEY (id_veterinario) REFERENCES veterinario (id_veterinario)
);

CREATE TABLE adotante (
    id_adotante INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(120),
    endereco VARCHAR(180) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    data_cadastro DATE NOT NULL,
    situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO',
    CONSTRAINT ck_adotante_situacao
        CHECK (situacao IN ('ATIVO', 'INATIVO'))
);

CREATE TABLE adocao (
    id_adocao INT AUTO_INCREMENT PRIMARY KEY,
    id_animal INT NOT NULL,
    id_adotante INT NOT NULL,
    data_solicitacao DATE NOT NULL,
    data_analise DATE,
    data_adocao DATE,
    situacao VARCHAR(12) NOT NULL DEFAULT 'EM_ANALISE',
    observacoes VARCHAR(500),
    CONSTRAINT ck_adocao_situacao CHECK (situacao IN (
        'EM_ANALISE', 'APROVADA', 'RECUSADA', 'CANCELADA', 'CONCLUIDA'
    )),
    CONSTRAINT ck_adocao_datas CHECK (
        (data_analise IS NULL OR data_analise >= data_solicitacao)
        AND (data_adocao IS NULL OR data_adocao >= data_solicitacao)
    ),
    CONSTRAINT fk_adocao_animal
        FOREIGN KEY (id_animal) REFERENCES animal (id_animal),
    CONSTRAINT fk_adocao_adotante
        FOREIGN KEY (id_adotante) REFERENCES adotante (id_adotante)
);

CREATE TABLE doador (
    id_doador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(140) NOT NULL,
    tipo_pessoa CHAR(2) NOT NULL,
    documento VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(120),
    cidade VARCHAR(80) NOT NULL,
    data_cadastro DATE NOT NULL,
    CONSTRAINT ck_doador_tipo_pessoa CHECK (tipo_pessoa IN ('PF', 'PJ'))
);

CREATE TABLE doacao (
    id_doacao INT AUTO_INCREMENT PRIMARY KEY,
    id_doador INT NOT NULL,
    data_doacao DATE NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10,2),
    quantidade DECIMAL(10,2),
    unidade VARCHAR(30),
    situacao VARCHAR(10) NOT NULL DEFAULT 'RECEBIDA',
    CONSTRAINT ck_doacao_tipo CHECK (tipo IN ('FINANCEIRA', 'MATERIAL')),
    CONSTRAINT ck_doacao_situacao CHECK (situacao IN ('RECEBIDA', 'CANCELADA')),
    CONSTRAINT ck_doacao_conteudo CHECK (
        (tipo = 'FINANCEIRA' AND valor > 0)
        OR
        (tipo = 'MATERIAL' AND quantidade > 0 AND unidade IS NOT NULL)
    ),
    CONSTRAINT fk_doacao_doador
        FOREIGN KEY (id_doador) REFERENCES doador (id_doador)
);

-- 2. INSERCAO DE DADOS
-- Todos os dados pessoais abaixo sao ficticios.

INSERT INTO especie (id_especie, nome, descricao) VALUES
    (1, 'Cao', 'Caninos domesticos'),
    (2, 'Gato', 'Felinos domesticos'),
    (3, 'Coelho', 'Coelhos domesticos'),
    (4, 'Ave', 'Aves domesticas resgatadas'),
    (5, 'Outro', 'Outros pequenos animais domesticos');

INSERT INTO raca (id_raca, id_especie, nome, descricao) VALUES
    (1, 1, 'SRD Canino', 'Sem raca definida'),
    (2, 1, 'Labrador Retriever', 'Cao de porte medio ou grande'),
    (3, 1, 'Poodle', 'Cao de porte pequeno ou medio'),
    (4, 2, 'SRD Felino', 'Sem raca definida'),
    (5, 2, 'Siames', 'Felino de pelagem clara e extremidades escuras'),
    (6, 2, 'Persa', 'Felino de pelagem longa'),
    (7, 3, 'Mini Lop', 'Coelho de orelhas caidas'),
    (8, 3, 'SRD Coelho', 'Coelho sem raca definida'),
    (9, 4, 'Calopsita', 'Ave domestica de pequeno porte'),
    (10, 5, 'Nao identificada', 'Classificacao ainda nao definida');

INSERT INTO voluntario (
    id_voluntario, nome, cpf, telefone, email, funcao, data_entrada, situacao
) VALUES
    (1, 'Ana Lima', '11111111101', '(21) 99901-1001', 'ana@exemplo.org', 'Resgate', '2025-02-10', 'ATIVO'),
    (2, 'Bruno Alves', '11111111102', '(21) 99901-1002', 'bruno@exemplo.org', 'Transporte', '2025-03-15', 'ATIVO'),
    (3, 'Carla Mendes', '11111111103', '(21) 99901-1003', 'carla@exemplo.org', 'Alimentacao', '2025-05-01', 'ATIVO'),
    (4, 'Diego Ramos', '11111111104', '(21) 99901-1004', 'diego@exemplo.org', 'Divulgacao', '2025-07-20', 'ATIVO'),
    (5, 'Elisa Castro', '11111111105', '(21) 99901-1005', 'elisa@exemplo.org', 'Apoio em eventos', '2025-09-12', 'ATIVO');

INSERT INTO animal (
    id_animal, id_especie, id_raca, id_voluntario_responsavel, nome, sexo,
    data_nascimento_estimada, porte, cor_pelagem, data_resgate,
    local_resgate, situacao, observacoes
) VALUES
    (1, 1, 1, 1, 'Lua', 'F', '2023-04-01', 'MEDIO', 'Caramelo', '2026-01-12', 'Praca Central', 'DISPONIVEL_ADOCAO', 'Vacinada e sociavel'),
    (2, 1, 2, 2, 'Thor', 'M', '2021-08-15', 'GRANDE', 'Amarelo', '2026-02-03', 'Rodovia RJ-001', 'EM_TRATAMENTO', 'Em recuperacao de fratura'),
    (3, 2, 4, 3, 'Mel', 'F', '2024-02-10', 'PEQUENO', 'Tigrada', '2026-02-20', 'Mercado Municipal', 'ADOTADO', 'Adocao concluida em maio'),
    (4, 2, 5, 4, 'Nina', 'F', '2022-11-05', 'PEQUENO', 'Creme', '2026-03-08', 'Rua das Flores', 'EM_PROCESSO_ADOCAO', 'Processo em analise'),
    (5, 1, 3, 5, 'Bob', 'M', '2020-06-30', 'PEQUENO', 'Branco', '2026-03-17', 'Terminal Rodoviario', 'EM_PROCESSO_ADOCAO', 'Candidato aprovado'),
    (6, 2, 6, 1, 'Amora', 'F', '2023-09-12', 'PEQUENO', 'Cinza', '2026-04-02', 'Parque Norte', 'DISPONIVEL_ADOCAO', 'Necessita escovacao frequente'),
    (7, 3, 7, 2, 'Pipoca', 'M', '2025-01-10', 'PEQUENO', 'Branco e marrom', '2026-04-18', 'Condominio Primavera', 'DISPONIVEL_ADOCAO', 'Animal docil'),
    (8, 4, 9, 3, 'Sol', 'F', '2024-07-01', 'PEQUENO', 'Amarela e cinza', '2026-05-01', 'Bairro das Palmeiras', 'EM_TRATAMENTO', 'Asa em recuperacao'),
    (9, 1, 1, 4, 'Chico', 'M', '2022-03-14', 'MEDIO', 'Preto', '2026-05-06', 'Avenida Brasil', 'ADOTADO', 'Adocao concluida em agosto'),
    (10, 2, 4, 5, 'Frida', 'F', '2025-02-20', 'PEQUENO', 'Preta e branca', '2026-05-22', 'Escola Municipal Horizonte', 'DISPONIVEL_ADOCAO', 'Saudavel');

INSERT INTO veterinario (
    id_veterinario, nome, crmv, telefone, email, clinica
) VALUES
    (1, 'Mariana Costa', 'CRMV-RJ-10001', '(21) 3333-1001', 'mariana@vetexemplo.org', 'Clinica Vida Animal'),
    (2, 'Rafael Nunes', 'CRMV-RJ-10002', '(21) 3333-1002', 'rafael@vetexemplo.org', 'Hospital Vet Popular'),
    (3, 'Juliana Reis', 'CRMV-RJ-10003', '(21) 3333-1003', 'juliana@vetexemplo.org', 'Clinica Bicho Feliz'),
    (4, 'Pedro Martins', 'CRMV-RJ-10004', '(21) 3333-1004', 'pedro@vetexemplo.org', 'Centro Veterinario Sul'),
    (5, 'Larissa Gomes', 'CRMV-RJ-10005', '(21) 3333-1005', 'larissa@vetexemplo.org', 'Atendimento Voluntario');

INSERT INTO tratamento (
    id_tratamento, id_animal, id_veterinario, data_tratamento, tipo,
    diagnostico, descricao, valor, data_retorno, situacao
) VALUES
    (1, 1, 1, '2026-01-13', 'Consulta', 'Desidratacao leve', 'Avaliacao geral e hidratacao', 120.00, '2026-01-20', 'REALIZADO'),
    (2, 1, 1, '2026-01-20', 'Vacinacao', 'Animal saudavel', 'Aplicacao de vacina multipla', 85.00, NULL, 'REALIZADO'),
    (3, 2, 2, '2026-02-04', 'Radiografia', 'Fratura na pata traseira', 'Exame e imobilizacao', 450.00, '2026-02-18', 'REALIZADO'),
    (4, 2, 2, '2026-02-18', 'Retorno', 'Boa consolidacao ossea', 'Troca de imobilizacao', 180.00, '2026-03-04', 'REALIZADO'),
    (5, 3, 3, '2026-02-21', 'Castracao', 'Apta para procedimento', 'Castracao e medicacao', 320.00, '2026-02-28', 'REALIZADO'),
    (6, 4, 3, '2026-03-09', 'Exame', 'Anemia leve', 'Hemograma e suplementacao', 210.00, '2026-03-23', 'REALIZADO'),
    (7, 5, 4, '2026-03-18', 'Odontologia', 'Tartaro moderado', 'Limpeza dentaria', 260.00, NULL, 'REALIZADO'),
    (8, 6, 1, '2026-04-03', 'Consulta', 'Dermatite', 'Tratamento topico por dez dias', 150.00, '2026-04-13', 'REALIZADO'),
    (9, 7, 5, '2026-04-19', 'Consulta', 'Animal saudavel', 'Avaliacao e orientacao alimentar', 90.00, NULL, 'REALIZADO'),
    (10, 8, 5, '2026-05-02', 'Ortopedia', 'Lesao na asa', 'Imobilizacao e analgesico', 275.00, '2026-05-16', 'REALIZADO'),
    (11, 9, 4, '2026-05-07', 'Vacinacao', 'Animal saudavel', 'Reforco anual', 80.00, NULL, 'REALIZADO'),
    (12, 10, 3, '2026-05-23', 'Castracao', 'Apta para procedimento', 'Castracao e medicacao', 310.00, '2026-05-30', 'REALIZADO');

INSERT INTO adotante (
    id_adotante, nome, cpf, data_nascimento, telefone, email,
    endereco, cidade, data_cadastro, situacao
) VALUES
    (1, 'Fernanda Souza', '22222222201', '1990-04-12', '(21) 98801-2001', 'fernanda@exemplo.com', 'Rua A, 10', 'Rio de Janeiro', '2026-04-15', 'ATIVO'),
    (2, 'Gustavo Rocha', '22222222202', '1987-09-21', '(21) 98801-2002', 'gustavo@exemplo.com', 'Rua B, 20', 'Niteroi', '2026-05-05', 'ATIVO'),
    (3, 'Helena Duarte', '22222222203', '1995-01-30', '(21) 98801-2003', 'helena@exemplo.com', 'Rua C, 30', 'Rio de Janeiro', '2026-06-12', 'ATIVO'),
    (4, 'Igor Moreira', '22222222204', '1992-12-03', '(21) 98801-2004', 'igor@exemplo.com', 'Rua D, 40', 'Duque de Caxias', '2026-06-20', 'ATIVO'),
    (5, 'Joana Freitas', '22222222205', '1985-07-18', '(21) 98801-2005', 'joana@exemplo.com', 'Rua E, 50', 'Sao Goncalo', '2026-07-02', 'ATIVO');

INSERT INTO adocao (
    id_adocao, id_animal, id_adotante, data_solicitacao, data_analise,
    data_adocao, situacao, observacoes
) VALUES
    (1, 3, 1, '2026-04-16', '2026-04-25', '2026-05-02', 'CONCLUIDA', 'Visita domiciliar aprovada'),
    (2, 4, 2, '2026-06-01', NULL, NULL, 'EM_ANALISE', 'Entrevista agendada'),
    (3, 9, 3, '2026-07-10', '2026-07-20', '2026-08-01', 'CONCLUIDA', 'Adaptacao acompanhada por voluntario'),
    (4, 1, 4, '2026-06-25', '2026-06-30', NULL, 'CANCELADA', 'Candidato desistiu do processo'),
    (5, 5, 5, '2026-07-05', '2026-07-15', NULL, 'APROVADA', 'Aguardando assinatura do termo'),
    (6, 10, 2, '2026-07-22', '2026-07-28', NULL, 'RECUSADA', 'Residencia sem protecao nas janelas');

INSERT INTO doador (
    id_doador, nome, tipo_pessoa, documento, telefone, email, cidade, data_cadastro
) VALUES
    (1, 'Kelly Batista', 'PF', '33333333301', '(21) 97701-3001', 'kelly@exemplo.com', 'Rio de Janeiro', '2026-01-05'),
    (2, 'Lucas Teixeira', 'PF', '33333333302', '(21) 97701-3002', 'lucas@exemplo.com', 'Niteroi', '2026-01-18'),
    (3, 'Mercado Bom Preco Ltda', 'PJ', '33333333000103', '(21) 3777-3003', 'contato@bompreco.exemplo', 'Rio de Janeiro', '2026-02-01'),
    (4, 'Farmacia Animal Ltda', 'PJ', '33333333000104', '(21) 3777-3004', 'doacoes@farmaciaanimal.exemplo', 'Sao Goncalo', '2026-02-15'),
    (5, 'Marcos Vieira', 'PF', '33333333305', '(21) 97701-3005', 'marcos@exemplo.com', 'Duque de Caxias', '2026-03-01');

INSERT INTO doacao (
    id_doacao, id_doador, data_doacao, tipo, descricao,
    valor, quantidade, unidade, situacao
) VALUES
    (1, 1, '2026-01-10', 'FINANCEIRA', 'Contribuicao para consultas', 300.00, NULL, NULL, 'RECEBIDA'),
    (2, 2, '2026-01-25', 'MATERIAL', 'Racao para caes', NULL, 20.00, 'kg', 'RECEBIDA'),
    (3, 3, '2026-02-05', 'MATERIAL', 'Racao para gatos', NULL, 30.00, 'kg', 'RECEBIDA'),
    (4, 4, '2026-02-20', 'MATERIAL', 'Medicamentos veterinarios', NULL, 15.00, 'unidades', 'RECEBIDA'),
    (5, 5, '2026-03-05', 'FINANCEIRA', 'Apoio aos tratamentos', 500.00, NULL, NULL, 'RECEBIDA'),
    (6, 1, '2026-04-10', 'MATERIAL', 'Cobertores', NULL, 12.00, 'unidades', 'RECEBIDA'),
    (7, 2, '2026-05-12', 'FINANCEIRA', 'Campanha mensal', 250.00, NULL, NULL, 'RECEBIDA'),
    (8, 3, '2026-06-18', 'MATERIAL', 'Produtos de higiene', NULL, 24.00, 'unidades', 'RECEBIDA'),
    (9, 5, '2026-07-01', 'FINANCEIRA', 'Lancamento duplicado', 100.00, NULL, NULL, 'CANCELADA');

-- 3. CONSULTAS SELECT

-- 3.1 Duas tabelas, GROUP BY e agregacao:
-- quantidade de animais por especie.
SELECT
    e.nome AS especie,
    COUNT(a.id_animal) AS quantidade_animais
FROM especie AS e
LEFT JOIN animal AS a ON a.id_especie = e.id_especie
GROUP BY e.id_especie, e.nome
ORDER BY quantidade_animais DESC, e.nome;

-- 3.2 Tres tabelas, GROUP BY e agregacao:
-- total gasto com tratamentos por animal e veterinario.
SELECT
    a.nome AS animal,
    v.nome AS veterinario,
    COUNT(t.id_tratamento) AS quantidade_tratamentos,
    SUM(t.valor) AS total_gasto
FROM tratamento AS t
INNER JOIN animal AS a ON a.id_animal = t.id_animal
INNER JOIN veterinario AS v ON v.id_veterinario = t.id_veterinario
GROUP BY a.id_animal, a.nome, v.id_veterinario, v.nome
ORDER BY total_gasto DESC, a.nome;

-- 3.3 Subconsulta:
-- animais cujo gasto total com tratamentos esta acima da media por animal.
SELECT
    a.nome AS animal,
    (
        SELECT SUM(t.valor)
        FROM tratamento AS t
        WHERE t.id_animal = a.id_animal
    ) AS total_tratamentos
FROM animal AS a
WHERE (
    SELECT COALESCE(SUM(t.valor), 0)
    FROM tratamento AS t
    WHERE t.id_animal = a.id_animal
) > (
    SELECT AVG(totais.total_animal)
    FROM (
        SELECT SUM(valor) AS total_animal
        FROM tratamento
        GROUP BY id_animal
    ) AS totais
)
ORDER BY total_tratamentos DESC;

-- 4. ATUALIZACAO
-- Mudanca da funcao da voluntaria Ana Lima.
UPDATE voluntario
SET funcao = 'Coordenacao de resgates'
WHERE id_voluntario = 1;

SELECT id_voluntario, nome, funcao
FROM voluntario
WHERE id_voluntario = 1;

-- 5. EXCLUSAO
-- Remove somente o lancamento de doacao previamente cancelado.
DELETE FROM doacao
WHERE id_doacao = 9
  AND situacao = 'CANCELADA';

SELECT id_doacao, id_doador, data_doacao, situacao
FROM doacao
ORDER BY id_doacao;

-- 6. STORED PROCEDURE
-- Conclui uma adocao e atualiza o animal na mesma transacao.

DELIMITER $$

CREATE PROCEDURE sp_concluir_adocao (
    IN p_id_animal INT,
    IN p_id_adotante INT,
    IN p_data_adocao DATE
)
BEGIN
    DECLARE v_animal_disponivel INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_animal_disponivel
      FROM animal
     WHERE id_animal = p_id_animal
       AND situacao = 'DISPONIVEL_ADOCAO';

    IF v_animal_disponivel = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Animal inexistente ou indisponivel para adocao';
    END IF;

    START TRANSACTION;

    INSERT INTO adocao (
        id_animal, id_adotante, data_solicitacao,
        data_analise, data_adocao, situacao, observacoes
    ) VALUES (
        p_id_animal, p_id_adotante, p_data_adocao,
        p_data_adocao, p_data_adocao, 'CONCLUIDA',
        'Adocao registrada pela stored procedure'
    );

    UPDATE animal
       SET situacao = 'ADOTADO'
     WHERE id_animal = p_id_animal;

    COMMIT;
END$$

DELIMITER ;

-- Exemplo de uso com a animal Amora e a adotante Joana:
-- CALL sp_concluir_adocao(6, 5, '2026-11-20');

-- Conferencia apos executar o exemplo:
-- SELECT id_animal, nome, situacao FROM animal WHERE id_animal = 6;
-- SELECT * FROM adocao WHERE id_animal = 6 ORDER BY id_adocao DESC;
