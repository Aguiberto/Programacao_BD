-- comandos DQL (Data Query Language) são utilizados para consultar dados em um banco de dados.

select * from funcionario;

select pnome, unome, numero_departamento from funcionario;

-- concatenação das colunas nome e sobrenome
select pnome || ' ' || unome, numero_departamento from funcionario;

-- as (alias) renomeia as colunas
select pnome || ' ' || unome as "Nome Completo", numero_departamento as "Dep" from funcionario;

select all numero_departamento from funcionario;

-- mostra os números de departamento sem repetição
select distinct numero_departamento from funcionario;

-- nome e inss são alias declarados sem precisar o comando 'as'
select pnome || ' ' || unome nome, salario, round(salario*0.11,2) issn from funcionario;

-- FILTRANDO usando o comando WHERE

select cpf, pnome, unome from funcionario
where endereco='Natal-RN';

select cpf, pnome, unome from funcionario
where numero_departamento = 1 and salario>9000;

select cpf, pnome, unome from funcionario
where salario > 8000 and salario < 10000;


select cpf, pnome, unome from funcionario
where salario between 8000 and 10000;

select cpf, pnome, unome from funcionario
where salario not between 8000 and 10000;

-- Caracteres coringa : _ e %
-- %: Substituem qualquer texto
-- _: substitui qualquer caractere

select cpf, pnome, unome from funcionario
where endereco like '%RN';

select cpf, pnome, unome from funcionario
where pnome like 'Ze%';

select cpf, pnome, unome from funcionario
where endereco like '%S_';

create table t(

    message text

);

insert into t(message)

values('The rents are now 10% higher the last month'),
      ('The new film will have _ in the tittle');

select message from t;

-- "escape é para anular o caractere especial tornando-o como um caractere comum"
select * from t
where message like '%10$%%' escape '$';
