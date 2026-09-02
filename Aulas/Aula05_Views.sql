-- 1. Resumo de pedidos por usuário
drop view if exists v_users_orders;
create view v_users_orders as 
select 
    u.id as id_usuario,
    u.name as nome_usuario,
    count(o.id) as qtd_pedidos,
    sum(o.total) as preco_total
from users u 
left join orders o on u.id = o.user_id
group by u.id, u.name;

-- select * from v_users_orders order by id;

-- 2. Relatório de vendas de produtos (id,produto, qtd_vendida, total_vendido)
drop view if exists v_products_sales;
create view v_products_sales as 
select
    p.id as id_produto,
    p.name as nome_produto,
    sum(op.quantity) as qtd_vendida,
    sum(op.quantity * op.unit_price) as total_vendio
from products p 
join orders_products op on op.product_id = p.id 
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

-- select * from  v_produts_sale order by id;

-- 3. Relatório detalhado dos pedidos 
drop view if exists v_orders_details;
create view v_orders_details as
select
    o.id id,
    u.name usuario,
    u.email email,
    o.order_date,
    o.status,
    p.name produto,
    op.quantity qtd,
    op.unit_price valor_unitatio,
    op.unit_price * op.quantity valor_total
from orders o 
join users u on u.id = o.user_id
join orders_products op on op.order_id = o.id
join products p on p.id = op.product_id;

-- select * from v_orders_datails order by id;

-- 4. relatorio de itens em estoque
drop view if exists v_products_in_stock;
create view v_products_in_stock as
select
    id,
    name produto,
    price valor,
    stock estoque
from products
where stock > 0
with check option;
-- controla operações usando a view

-- select * from v_products_in_stock order by id;

-- usando uma view para manipular os dados

-- update products
-- set stock = 10
-- where id = 1


-- update v_products_in_stock
-- set estoque = 0
-- where id = 1
-- returning id,produto,  stock;

/*
MATERIALIZED VIEW
*/

-- 5. Relatório de produtos mais vendidos
drop view if exists v_top_products;
create view v_top_produtcs as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p 
join orders_products op on op.product_id = p.id 
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;

-- explain analyze select * from v_top_products order by total_vendido desc limit 3;

-- 1º MATERIALIZED VIEW
drop view if exists mv_top_products;
create materialized view mv_top_produtcs as
select
    p.id id,
    p.name produto,
    sum(op.quantity) unid_vendidas,
    sum(op.quantity * op.unit_price) total_vendido
from products p 
join orders_products op on op.product_id = p.id 
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name;
-- with data; -- por padrão
-- with no data; inicia sem dados

-- explain analyze select * from mv_top_products order by total_vendido desc limit 3;


-- 6. MV mostrar o total vendido por mês
drop materialized view if exists mv_monthly_sales;
create materialized view mv_monthly_sales as
select
    to_char(date_trunc('month',order_date), 'yyy-mm') mes,
    sum(o.total) total_vendido
from orders o 
where o.status <> 'canceled'
group by mes
with no data; 

-- select * from mv_monthly_sales order by mes desc;

-- Recarregando a MV
refresh materialized view mv_monthly_sales;

create unique index idx_mv_mothly_sales_month
on mv_monthly_sales(mes);

-- permite consultas ...
refresh materialized view concurrently mv_monthly_sales;


