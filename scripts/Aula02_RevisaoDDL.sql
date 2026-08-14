
drop table if exists funcionario cascade;
drop table if exists departamento cascade;

create table funcionario(

    cpf char(11) primary key,
    pnome varchar(50) not null,
    unome varchar(50) not null,
    email varchar(50) unique,
    endereco varchar(100), 
    salario numeric(7,2), --salario máximo 7 digitos com 2 cadas decimais
    data_nasc date,
    sexo char(1),
    cpf_supervisor char(11),
    numero_departamento smallint,

    -- restrições
    constraint  funcionario_salario_check
    check (salario >= 2000 and salario <= 15000)
);

create table departamento(

    numero smallint primary key,
    nome varchar(50) unique,
    cpf_gerente char(11)

);

-- Adicionar um novo atributo
alter table departamento
add column data_ini date;

-- Alterar um atributo para NOT NULL
alter table departamento
alter column data_ini set not null;

-- Removendo um atributo
alter table departamento
drop column data_ini;

-- Adicionando um valor PADRÃO
alter table funcionario
alter column endereco set default 'Macau-RN';

-- Excluir um valor PADRÃO
alter table funcionario
alter column endereco drop default;

-- Adicionar restrição (constraint) CHECK
alter table funcionario
add constraint funcionario_sexo_check
check (lower(sexo) in ('m','f','o') );
-- check (sexo in ('m','f','o','M','F','O') );

/*
CHECK: se o valor não estiver dentro das opções 
o banco não permite o armazenamento desse dado
*/

-- Excluir uma restrição
alter table funcionario
drop constraint if exists funcionario_sexo_check;

-- Adicionar restrição FOREING KEY
alter table funcionario 
add constraint funcionario_num_dep_fk
foreign key(numero_departamento)
references departamento(numero)
on delete no action -- no action, set null, cascade, set default, restrict
on update cascade;

-- TO DO: adicionar restrições FK para cfp_supervisor e cpf_gerente

/*
Cria uma chave estrangeira que se relaciona
com a chave primária da própria tabela gerando 
um auto relacionamento
*/

alter table funcionario
add constraint funcionario_cpf_supervisor_fk
foreign key(cpf_supervisor)
references funcionario(cpf)
on delete set null
on update cascade;

/*
Regra que permite saber qual é o funcionário
que é gerente de um departamento
*/
alter table departamento
add constraint departamento_cpf_gerente_fk
foreign key(cpf_gerente) references funcionario(cpf)
on delete set null
on update cascade