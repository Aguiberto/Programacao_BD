-- trigger de before, usado para a validação

reate or replace function fn_check_constructor_wins()
returns trigger as $$
begin
    if new.total_race_wins < 0 then
        raise exception 'O número de vitórias não pode ser negativo'
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_check_constructor_wins
before insert or update on constructor
for each row
execute function fn_check_constructor_wins();

insert into construction
values(

)

-- trigger com evento before insert or update
create or replace function fn_validate_driver_abbreviation()
returns trigger as $$
begin

    new.abbreviation := upper(new.abbreviation);

    if length(new.abbreviation) <> 3 then
        raise exception 'A sigla deve ter obrigatoriamente 3 caracteres!';
    end if;
    return new;
end;
$$ language plpgsql;

create or replace trigger trg_validade_driver_abbreviation
before insert or update on driver
for each row
execute function fn_validate_driver_abbreviation();

update driver 
set abbreviation = 'sen'
where id = 'ayrton-senna';

select
    id,
    abbreviation
from driver
where id = 'ayrton-senna';

update driver
set abbreviation = 'se'
where id = 'ayrton-senna';

-- trigger para de auditoria, com evento de after insert,update ou delete
/*
old = variável que guarda o valor antigo da linha
new = variável que guarda no novo valor da linha
tg_op = informa a operação que acionou o trigger
*/
create table driver_audit(
    id serial primary key,
    driver_id varchar(100) not null,
    old_abbreviation varchar(3),
    new_abbreviation varchar(3),
    changed_at timestamp default current_timestamp,
    action_type varchar(10) not null
);

create or replace function fn_driver_audit_abbreviation()
returns trigger as $$
begin

    if old.abbreviation is distinct from new.abbreviation then
        insert into driver_audit(driver_id,old_abbreviation,new_abbreviation,action_type)
        values(
            new.id,
            old.abbreviation,
            new.abbreviation,
            tg_op
        );
    end if;

return new;
end;
$$ language plpgsql;

create or replace trigger trg_driver_audit_abbreviation
after update on driver
for each row
execute function fn_driver_audit_abbreviation();

update driver
set abbreviation = 'FA1'
where id = 'fernando-alonso';

select * 
from driver_audit;