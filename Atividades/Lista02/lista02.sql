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