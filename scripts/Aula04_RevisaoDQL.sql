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


/*
    Aula 25/08
*/

-- ORDENAÇÃO
-- order by, limit

-- ordenação alfabetica crescente
select pnome, unome from funcionario
order by pnome, unome asc;

-- ordenação alfabetica decrescente
select pnome, unome from funcionario
order by pnome desc, unome desc; 

-- selecionando o maior salario
select pnome, unome, salario from funcionario
order by salario desc
limit 1;

-- FUNÇÕES DE AGREGAÇÃO: count, sum, avg, min, max

-- conta quantos funcionario(linhas) há na tabela funcionários
select count (*) TotalFuncionarios from funcionario;


select count(distinct numero_departamento) from funcionario;

select sum(salario) FolhaSalarial from funcionario;

select sum(salario) as "Folha Salarial D1" from funcionario
where numero_departamento = 1;

select avg(salario) MediaSalarial from funcionario;

select round(avg(salario),2) media_salarial from funcionario;

select 
    min(salario) menor_salario, 
    max(salario) maior_salario 
from funcionario;

--subconsulta : uma consulta dentro da outra (no 'where' é preciso colocar os parentesis) 
select pnome, salario from funcionario
where salario = (
    select min(salario) from funcionario 
);

-- funcionarios que recebem salario maior que a média
select pnome from funcionario
where salario >= (
    select avg(salario) from funcionario
);

select 
        count(*) TotalFuncionarios,
        sum(salario) FolhaSalarial,
        sum(salario) *0.11 folha_inss,
        round(avg(salario),2) MediaSalarial,
        min(salario) MenorSalario,
        max(salario) MaiorSalario
from funcionario;


-- JUNÇÕES: inner join, left join, right join, full join
-- REALIZANDO INTERSEÇÕES

-- listar nome dos funcionarios e seus respectivos departamentos
select 
    f.pnome || ' ' || f.unome funcionario,
    d.nome departamento
from funcionario f
join departamento d
    on f.numero_departamento = d.numero
order by d.nome, f.pnome;

-- listar todos os funcionarios e seus respetivos supervisores
-- SUPERVISOU FICOU DE FORA PQ SUA CHAVE ESTRAGEIRA PARA SUPERVISOR É NULL
select
    f.pnome || ' ' || f.unome funcionario,
    s.pnome || ' ' || s.unome supervisores
from funcionario f 
join funcionario s
    on f.cpf_supervisor = s.cpf
order by f.pnome, f.unome;

-- INCLUINDO O SUPERVISOR   
-- COALESCE: se um valor for nulo substitui por um valor escolhido (alias)
select
    f.pnome || ' ' || f.unome funcionario,
    coalesce(s.pnome || ' ' || s.unome, 'Null') supervisores
from funcionario f 
left join funcionario s
    on f.cpf_supervisor = s.cpf
order by s.pnome nulls last, f.pnome, f.unome;

/*
LEFT JOIN e RIGHT JOIN usa a refeência da tabela que vem escrita 
antes ou depois ( esquerda e direita)
*/


update funcionario
set numero_departamento = null
where cpf = '11122233345';

insert into departamento(numero, nome, cpf_gerente, data_ini)
values (4,'Marketing',null,current_date);

select
    coalesce(d.nome, 'Sem departamento') departamento,
    coalesce(f.pnome || ' ' || f.unome, 'Sem funcionario') funcionario
from departamento d 
full join funcionario f 
    on d.numero = f.numero_departamento
order by departamento nulls last, funcionario nulls last;

-- EXISTS, NOT EXIST

-- listar funcionarios que são gerentes de algum departamento
-- exits para executar uma subconsulta
select f.pnome || ' ' || f.unome funcionario
from funcionario f
where exists (
    select * from departamento d
    where d.cpf_gerente = f.cpf
)
order by funcionario;

-- existe algum funcionario que não é gerete
select f.pnome || ' ' || f.unome funcionario
from funcionario f
where not exists (
    select * from departamento d
    where d.cpf_gerente = f.cpf
)
order by funcionario;

--  FUNÇÕES DE AGRUPAMENTO: group by, having

-- Qual é o salário medio dos funcionario em cada departamento?
select 
    numero_departamento,
    round(avg(salario), 2) media_salarial
from funcionario
group by numero_departamento
order by numero_departamento;

-- Qual é o salário medio dos funcionario em cada departamento (sem valores nulos)?
select 
    numero_departamento,
    round(avg(salario), 2) media_salarial
from funcionario
where numero_departamento is not null
-- para sql quando se trata de valores nulos deve se usar o "is" ou "is not"
group by numero_departamento
order by numero_departamento;

-- Qual é o salário medio dos funcionario em cada departamento (sem valores nulos) USANDO HAVING?
select 
    numero_departamento,
    round(avg(salario), 2) media_salarial
from funcionario
group by numero_departamento
having numero_departamento is not null
order by numero_departamento;

-- Qual é o numero de funcionario que trabalham em cada departamento?

select
    numero_departamento,
    count(*) qtd_funcionarios
from funcionario f 
group by numero_departamento
order by numero_departamento;

/*
    LISTAR: numero e nome do departamento, quantidade de funcionários,
            média salarial e folha salarial
*/

select
    d.numero numero_departamento,
    d.nome nome_departamento,
    count(f.cpf) qtd_funcionarios,
    round(avg(f.salario),2) media_salarial,
    sum(f.salario) folha_salarial
from funcionario f
right join departamento d
    on f.numero_departamento = d.numero
group by d.numero
order by numero_departamento;



