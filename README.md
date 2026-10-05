# Projeto Patas na Rua

Projeto individual da disciplina Projeto de Extensão em Banco de Dados.

- Aluno: Isaac Azevedo Werneck
- Matrícula: 2024101179
- SGBD: MySQL 8.0
- Entrega: 11 de dezembro de 2026

## Objetivo

Modelar e implementar um banco de dados para a ONG fictícia Patas na Rua, que atua no resgate, tratamento e adoção de animais e no recebimento de doações.

## Arquivos

- `docs/projeto.md`: minimundo, regras de negócio, modelos conceitual e lógico e orientações.
- `diagramas/`: diagramas conceitual e lógico.
- `sql/patas_na_rua.sql`: criação, dados, consultas, CRUD e stored procedure.
- `scripts/validar_sql.py`: verifica o esquema, os dados e as consultas usando apenas a biblioteca padrão do Python.
- `entrega/`: documento Word editável e PDF final.

## Execução

No MySQL 8.0:

```bash
mysql -u root -p < sql/patas_na_rua.sql
```

Validação local sem MySQL:

```bash
python scripts/validar_sql.py
```

O validador executa a parte portável do script em um banco SQLite temporário, confirma pelo menos cinco registros em cada tabela e testa as três consultas avaliadas. A stored procedure permanece específica do MySQL.
