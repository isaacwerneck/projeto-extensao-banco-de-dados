# Patas na Rua — Banco de dados

Projeto individual de Isaac Azevedo Werneck, matrícula 2024101179. Cenário acadêmico fictício de proteção animal, com dez entidades.

## Entrega

- `entrega/Projeto_Patas_na_Rua_Isaac_Azevedo_Werneck.pdf`: relatório final para o AVA, convertido do Word preenchido no modelo do professor.
- O `.docx` na mesma pasta é a versão editável.
- `sql/patas_na_rua.sql`: criação do banco e tabelas, carga, três consultas, UPDATE, DELETE, procedure e chamada demonstrativa.
- `diagramas/`: DER em notação ER e modelo lógico completos, divididos em quatro recortes; PNG para leitura, SVG e DOT para edição.
- `evidencias/`: resultados reais e testes de integridade.

O PDF é o documento solicitado; o link do GitHub é complementar. O material fornecido não exige apresentação. Prazo: **11/12/2026**.

## Executar

Use MySQL 8.0.16 ou superior (validado no MySQL 8.4.8), com tabelas InnoDB. Abra o arquivo SQL no MySQL Workbench e execute por inteiro, ou no cliente mysql:

```sql
SOURCE C:/caminho/do/projeto/sql/patas_na_rua.sql;
```

É necessário usuário com permissão de criação de banco, tabelas e procedures. Execute uma vez em uma instância que ainda não tenha a base `patas_na_rua`; o script não apaga nem sobrescreve uma base existente. `DELIMITER` é uma diretiva do cliente mysql/Workbench. Ao final, Bob estará adotado e haverá oito doações após a remoção do lançamento duplicado cancelado. Todas as tabelas continuam com pelo menos cinco registros.

## Reproduzir a validação

Python 3 e cliente `mysql` no PATH, sem bibliotecas extras:

```powershell
$env:MYSQL_PWD = 'sua_senha_local'
python scripts/validar_mysql.py --host 127.0.0.1 --port 3306 --user root
Remove-Item Env:MYSQL_PWD
```

Se o cliente não estiver no PATH, informe `--mysql "C:/caminho/mysql.exe"`.
**Atenção:** o teste apaga e recria somente a base `patas_na_rua_validacao`. Não a use para dados reais. A base principal não é alterada. O usuário de teste precisa também de permissão para criar trigger (usada apenas no teste de rollback). A senha não é armazenada no repositório.

Os testes conferem contagens, consultas reais, CRUD, conclusão de adoção, dados inválidos, rollback e duas conclusões concorrentes. Há limitações de escopo explicitadas no relatório: não há aplicativo nem validação cadastral de documentos e nenhum contato com ONG real foi alegado.
