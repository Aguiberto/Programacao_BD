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

