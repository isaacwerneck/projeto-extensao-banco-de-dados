# Patas na Rua

Isaac Azevedo Werneck — 2024101179

A Patas na Rua é uma ONG fictícia de proteção animal adotada como cenário deste projeto. O público atendido é formado por animais domésticos em situação de abandono, pessoas interessadas em adoção responsável, voluntários, veterinários parceiros e doadores da comunidade.

O problema considerado é a dispersão dos registros de resgate, atendimento e adoção em mensagens e planilhas separadas. Nesse cenário, seria difícil localizar o histórico de um animal, saber quem está responsável por ele, acompanhar um pedido de adoção e consultar os gastos com tratamentos. O banco proposto reúne essas informações e registra também as contribuições recebidas.

Cada animal possui identificação, espécie, raça quando conhecida, sexo, porte, local e data do resgate, situação atual e observações. Um voluntário pode ser responsável por vários animais; um animal pode ficar temporariamente sem responsável cadastrado. Espécies e raças são cadastros separados, e a raça escolhida precisa pertencer à espécie do animal. No cadastro de pequenos animais, o campo raça também admite variedade ou classificação não identificada.

Os atendimentos veterinários são registrados como tratamentos. Cada tratamento corresponde a um animal e a um veterinário, com data, tipo, descrição, situação e custo. Um mesmo animal pode receber vários tratamentos, inclusive com profissionais diferentes. Custos não podem ser negativos.

Uma adoção representa um processo, não apenas a entrega do animal. Ela identifica o animal, o adotante, as datas de solicitação, análise e conclusão e sua situação. O histórico pode conter pedidos recusados ou cancelados, mas um animal não pode ter dois processos ativos ao mesmo tempo. A conclusão é feita pela procedure: exige processo aprovado, animal em processo de adoção, adotante ativo e data válida, e atualiza o processo e o animal na mesma transação.

Cada doação pertence a um doador, pessoa física ou jurídica. Doações financeiras exigem valor positivo; materiais exigem quantidade positiva e unidade informada. Contribuições recebidas devem ser preservadas no histórico. A exclusão demonstrada no trabalho se limita a um lançamento duplicado e já cancelado.

O levantamento foi realizado por análise do cenário e definição de regras de negócio, sem entrevistas ou contato com uma organização real. Os nomes, documentos e demais dados usados nos testes são fictícios. Não fazem parte do escopo um aplicativo, controle de estoque, prontuário clínico completo ou contabilidade da ONG. O resultado é o banco relacional, seus diagramas, scripts e consultas.

Requisitos e decisões de modelagem

R01. Cadastrar espécies, raças, voluntários, animais, veterinários, tratamentos, adotantes, processos de adoção, doadores e doações: dez entidades.
R02. Manter identificadores únicos e referências válidas entre os cadastros.
R03. Garantir compatibilidade entre raça e espécie e permitir raça e responsável desconhecidos.
R04. Registrar tratamentos com profissional, animal e custo não negativo.
R05. Preservar o histórico de adoções e limitar a um processo ativo por animal.
R06. Concluir uma adoção aprovada atomicamente, sem deixar animal e processo em situações diferentes em caso de erro.
R07. Validar os campos obrigatórios de doações financeiras e materiais.
R08. Consultar quantidade de animais por espécie, gastos por animal/profissional e animais com gasto acima da média.
R09. Demonstrar inserção, atualização e exclusão controlada de registros.

As cardinalidades estão escritas junto à entidade a que se aplicam: (0,N), (1,1) e (0,1). As entidades repetidas nos recortes representam os mesmos cadastros, não entidades adicionais. No DER, retângulos representam entidades, losangos representam relacionamentos, elipses representam atributos e o identificador aparece sublinhado. Chaves estrangeiras surgem apenas no modelo lógico.

## Verificação

Testado no MySQL 8.4.8: consultas, CRUD, procedure, restrições, rollback e concorrência. Resultados completos em `evidencias/`.
