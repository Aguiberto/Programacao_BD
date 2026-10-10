-- QUESTÃO 1 : View de performance da equipe  
REPLACE VIEW v_staff_performance AS 
WITH pagamentos_por_staff AS (
    -- Agrupa os pagamentos primeiro para não duplicar com as locações
    SELECT 
        staff_id, 
        SUM(amount) AS valor_total_arrecadado
    FROM payment
    GROUP BY staff_id
)
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS nome_completo,
    c.city || '/' || co.country AS endereco_loja,
    COALESCE(COUNT(DISTINCT r.rental_id), 0) AS total_locacoes,
    COALESCE(p.valor_total_arrecadado, 0.00) AS valor_total_arrecadado
FROM staff s 
LEFT JOIN store st ON s.store_id = st.store_id
LEFT JOIN address a ON st.address_id = a.address_id
LEFT JOIN city c ON a.city_id = c.city_id
LEFT JOIN country co ON c.country_id = co.country_id
LEFT JOIN rental r ON s.staff_id = r.staff_id
LEFT JOIN pagamentos_por_staff p ON s.staff_id = p.staff_id
GROUP BY
    s.staff_id,
    s.first_name,
    s.last_name,
    c.city,
    co.country,
    p.valor_total_arrecadado;

select * from v_staff_performance;

-- QUESTÃO 2: Materializerd View para receita por categoria
CREATE materialized VIEW mv_category_total_sales AS
SELECT
    c.category_id,
    c.name as categoria,
    COALESCE(SUM(p.amount), 0.00) as total_receita
FROM category c
LEFT JOIN film_category fc ON c.category_id = fc.category_id
LEFT JOIN film f ON fc.film_id = f.film_id
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
LEFT JOIN payment p on r.rental_id = p.rental_id
GROUP BY
    c.category_id,
    c.name;

CREATE UNIQUE INDEX idx_mv_category_id on mv_category_total_sales(category_id);
REFRESH MATERIALIZED VIEW concurrently mv_category_total_sales;

SELECT * FROM mv_category_total_sales ORDER BY total_receita DESC;

-- QUESTÃO 3
CREATE INDEX idx_rental_pendentes
on rental(rental_date)
WHERE return_date is null;  -- WHERE é o que torna o índice parcial

explain analyze
select
    rental_id,
    rental_date,
    customer_id,
    inventory_id,
    staff_id
from rental
where return_date is null;


-- QUESTÃO 04
CREATE INDEX idx_film_description_btree
on film (description)
where description like 'act%';

explain analyze
select
    film_id,
    title,
    description
from film
where description like '%act%';

/*
 Planning Time: 39.651 ms
 Execution Time: 0.837 ms
*/

CREATE INDEX idx_film_description_gin
on film 
using gin(to_tsvector('english',description));

explain analyze
select
    film_id,
    title, 
    description
from film
where to_tsvector('english',description) @@ to_tsquery('english','documentary');

/*
Planning Time: 3.058 ms
 Execution Time: 0.666 ms
*/


--QUESTÃO 5
CREATE INDEX idx_customer_payment_date
on payment(customer_id, payment_date DESC);

/*
customer_id primeiro reflete os os sistema reais, além disso a busca se torna mais eficiente
visto que o filtro será iniciado da esquerda para a direita. Outra vantagem é que dessa forma
uma busca usando apenas o customer_id ainda funcionará.
*/

-- QUESTÃO 6 : Expression Index
CREATE INDEX idx_customer_email
on customer (lower(email));

explain analyze
select
    customer_id,
    first_name,
    last_name,
    email
from customer
where lower(email) = lower('MARY.smith@sakilacustomer.org');

/*

   ->  Bitmap Index Scan on idx_customer_email  (cost=0.00..4.30 rows=3 width=0) (actual time=0.089..0.089 rows=1.00 loops=1)
         Index Cond: (lower((email)::text) = 'mary.smith@sakilacustomer.org'::text)
         Index Searches: 1
         Buffers: shared read=2

*/

-- QUESTÃO 07: TRIGGER BEFORE INSERT OR UPDATE
create or replace function fn_rental_date_validation()
returns trigger as $$
begin

    if new.return_date is not null and new.return_date < new.rental_date then
        raise exception 'Erro de validação: A data de devolução (%) não pode ser anterior a data de locação (%).',
            new.return_date, new.rental_date;
    end if;
    return new;
end; 
$$ language plpgsql;

-- TRIGGER
create trigger trg_check_rental_dates
before insert or update on rental -- event
for each row
execute function fn_rental_date_validation(); -- action

-- TESTE DE FALHA
INSERT INTO rental (rental_date, return_date, inventory_id, customer_id, staff_id)
VALUES (
    '2026-10-07 10:00:00', 
    '2026-10-06 08:00:00', 
    1, 
    1, 
    1
);

-- TESTE POSITIVO
INSERT INTO rental (rental_date, return_date, inventory_id, customer_id, staff_id)
VALUES (
    '2026-10-07 10:00:00', 
    '2026-10-08 14:00:00', 
    1, 
    1, 
    1
);


-- QUESTÃO 8: TRIGGER AFTER UPDATE

create table film_cost_audit(
    audit_id serial primary key,
    film_id int not null,
    old_cost numeric(5,2),
    new_cost numeric(5,2),
    changed_at timestamp default current_timestamp
    );

create or replace function fn_audit_film()
returns trigger as $$
begin
    insert into film_cost_audit(film_id, old_cost, new_cost, changed_at)
    values(old.film_id, old.replacement_cost, new.replacement_cost, now());
    return new;

end;
$$ language plpgsql;

create trigger tgr_audit_replacement_cost
after update on film           -- event
for each row 
when(old.replacement_cost is distinct from new.replacement_cost)  --condition
execute function fn_audit_film();        -- action

-- film teste 1
set replacement_cost = 25.99
where film_id = 1;

-- teste 2
update film
set title = 'ACADEMY DINOSAUR REVISED'
where film_id = 1;

select * from film_cost_audit;

-- Questão 09: Trigger before delete

-- função
create or replace function fn_delete_condition()
returns trigger as $$
declare
    v_qtd_films int;
begin
    select count(*) into v_qtd_films
    from film
    where language_id = old.language_id;

    if v_qtd_films > 0 then
        raise exception 'Não é possível excluir o idioma "%" (ID%) pois existem % filmes viculados a ele.',
            old.name, old.language_id, v_qtd_films;
    end if;

    return old;

end;
$$ language plpgsql;

-- trigger
create or replace trigger trg_protect_condition
before delete on language
for each row
execute function fn_delete_condition();

-- teste
delete from language
where language_id = 1;

-- QUESTÃO 10: 

create table customer_rental_stats (
    customer_id int primary key,
    total_rentals int default 0
);

insert into customer_rental_stats(customer_id, total_rentals)
select customer_id, count(*)
from rental 
group by customer_id;

create or replace function fn_increment_customer_rentals()
returns trigger as $$
begin

    insert into customer_rental_stats(customer_id, total_rentals)
    VALUES(new.customer_id,1)
    on conflict(customer_id)
    do update set total_rentals = customer_rental_stats.total_rentals+1;
    return new;
end;
$$ language plpgsql;

create trigger trg_after_insert_rental
after insert on rental
for each row
execute function fn_increment_customer_rentals();

-- teste
select * from customer_rental_stats
where customer_id = 1;

insert into rental (rental_date, inventory_id, customer_id,staff_id)
values(now(),1,1,1);

select * from customer_rental_stats where customer_id = 1;