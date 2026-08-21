-- comandos DML (Data Manipulation Language) são utilizados para manipular dados em um banco de dados.
-- INSERIR, ALTERAR, REMOVER dados

-- INSERIR

insert into funcionario values
-- ainda não há supervisores e departamentos cadastrados
('11122233345','Joao','Silva','joao@mail.ifrn','Natal-RN',9990,'1995-12-12','M',null,null),
('23142543908','Xabrislau','Silva','xazin@mail.ifrn','SãoMiguel-RN',9990,'1998-1-12','M',null,null),
('23164587953','Zenia','Silva','zania_silva@mail.ifrn','Santos-SP',9990,'2000-6-25','M',null,null);

insert into funcionario(cpf, pnome, unome, email, salario, data_nasc, sexo) values
('44455566677','Maicon','Jeqson','reidopop2026@mail.com',8590,'2006-07-19','M');


-- ATUALIZAR
-- recomendados usar sempre a chave primaria para a busca(WHERE)

update funcionario
set salario = 5830
where cpf = '23142543908'
-- gera uma consulta que exibe os atributos informados
returning cpf, pnome, unome, salario;

-- REMOVER
-- recomendados usar sempre a chave primaria para a busca(WHERE)

-- delete from funcionario
-- where cpf = '11122233345'
-- returning cpf, pnome, unome;

-- Cria os departamentos
insert into departamento values
(1,'TI','11122233345', current_date),
(2,'Financeiro','23142543908', current_date - interval '3 days'),
(3,'RH','23164587953', current_date - interval '5 days');

-- CRIA um SUPERVISOR 
/*Confere valor ao atributo cpf_supervisor de todas as colunas 
usando a chave primaria de um funcionário, TODOS OS FUNCIONARIOS
TERÃO O MESMO SUPERVISOR com excessão '<>' do que tem o cpf do supervisor*/
update funcionario
set cpf_supervisor='11122233345'
where cpf <> '11122233345';

/*Adiciona os funcionários com os cpf informados
ao departamento 1*/
update funcionario
set numero_departamento = 1
where cpf in ('11122233345','23142543908');

update funcionario
set numero_departamento = 2
where cpf in ('23164587953');

update funcionario
set numero_departamento = 3
where cpf in ('44455566677');