-- ===============================================
--   Exemplo 3 - Testar DML em geral
-- ===============================================

begin; -- inicia de uma transação

insert into rental(rental_date, inventory_id, curstomer_id, staff_id)
values
(now(),1,1,1),
(now(),2,2,1),
(now(),3,2,1);

-- visualizar se a operação foi feita
select renta_id, rental_date, from rental order by rental_id desc limit 5;

rollback;  -- comando que desfaz todas as operações dentro da transação 

-- ===============================================
--   Exemplo 4 - SAVEPOINT
-- ===============================================

begin;

insert into rental(rental_date, inventory_id, curstomer_id, staff_id)
values (now(),1,1,1);

-- save point: garante o retorno para esse ponto após o rollback 
savepoint aluguel_criado;

insert into payment(curstomer_id, staff_id, rental_id, amount, payment_date)
values(9999, 1, currval('rental_rental_id_seq'), 4.99, now());

select rental_id, rental_date, from rental order by rental_id desc limit 5;

rollback to aluguel_criado; -- retorna para o save point criado

-- ====================================================
--   Exemplo 5 - Locação concorrente (ROW-LEVEL BLOCK)
-- ====================================================


begin;

select inventory_id from inventory where inventory_id = 1
-- condição que reserva o recurso selecionado na linha anterior
-- bloqueia o recurso para outras sessões até que a transação seja concluída
for update;

-- verificar disponibilidade do exemplar (filme)
-- função anonima / não nomeada
do $$  
begin
    if exists (
        select 1
        from rental
        where inventory_id = 1 and inventory_date is null
    ) then
        raise exception 'Exemplar indisponível';
    end if;
end;
$$;

-- alugel do filme
insert into rental(rental_date, inventory_id, curstomer_id, staff_id)
values (now(),1,1,1);

-- finaliza a transação e libera o recurso para outras sessões
commit;