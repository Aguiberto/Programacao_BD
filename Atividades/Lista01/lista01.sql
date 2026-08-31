DROP TABLE IF EXISTS orders_products CASCADE;
DROP TABLE IF EXISTS orders     CASCADE;
DROP TABLE IF EXISTS products   CASCADE;
DROP TABLE IF EXISTS users      CASCADE;

CREATE TABLE users (
    id serial PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE products (
    id serial PRIMARY KEY,
    name text NOT NULL,
    price numeric(10,2) NOT NULL CHECK (price >= 0),
    stock integer NOT NULL DEFAULT 0 CHECK (stock >= 0),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    id serial PRIMARY KEY,
    user_id integer NOT NULL REFERENCES users(id),
    order_date timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'pending'
           CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'canceled')),
    total numeric(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE orders_products (
    id serial PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id integer NOT NULL REFERENCES products(id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO users (name, email) VALUES
    ('Ana Souza',    'ana@tads.ifrn'),
    ('Bruno Lima',   'bruno@tads.ifrn'),
    ('Carla Alves',  'carla@tads.ifrn'),
    ('Diego Santos', 'diego@tads.ifrn'),
    ('Elisa Prado',  'elisa@tads.ifrn'),
    ('Felipe Silva', 'felipe@tads.ifrn');

INSERT INTO products (name, price, stock) VALUES
    ('Notebook Dell Inspiron',            4500.00, 10),
    ('Mouse Logitech MX',                 89.90, 50),
    ('Teclado Mecânico Logitech',         349.90, 30),
    ('Monitor 27" Dell',                  1899.00, 12),
    ('Webcam HD Logitech',                259.00, 40),
    ('Headset Gamer Logitech',            499.90, 25),
    ('Cadeira Ergonômica Flexform',       1299.00,  8),
    ('SSD 1TB Kingston',                  459.00, 20),
    ('Notebook Apple Macbook Pro M5',     19999.00, 8);

-- interval - second, minute, hour, day, month, year
INSERT INTO orders (user_id, order_date, status, total) VALUES
    (1, now() - interval '2 days',  'delivered', 4589.90),
    (2, now() - interval '5 days',  'shipped',    349.90),
    (3, now() - interval '10 days', 'paid',       618.90),
    (1, now() - interval '15 days', 'delivered', 1299.00),
    (4, now() - interval '20 days', 'paid',       459.00),
    (5, now() - interval '25 days', 'pending',    259.00),
    (2, now() - interval '40 days', 'delivered', 1899.00),
    (3, now() - interval '50 days', 'canceled',   499.90),
    (4, now() - interval '60 days', 'delivered',  349.90),
    (5, now() - interval '90 days', 'delivered', 4500.00);

INSERT INTO orders_products (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 4500.00),
    (1, 2, 1,   89.90),
    (2, 3, 1,  349.90),
    (3, 5, 1,  259.00),
    (3, 3, 1,  349.90),
    (3, 2, 1,   89.90),
    (4, 7, 1, 1299.00),
    (5, 8, 1,  459.00),
    (6, 5, 1,  259.00),
    (7, 4, 1, 1899.00),
    (8, 6, 1,  499.90),
    (9, 3, 1,  349.90),
    (10, 1, 1, 4500.00);


-- ======================================================
--                      SOLUÇÃO                
-- ======================================================

-- 1. mostrar os produtos com preço maior que mill
select * from products
where price > 1000;

-- 2. listar todos os produtos por ordem decrescente de preço
select * from products
order by price desc;

-- 3. aumento o preco de todos os produtos Dell em 10%
update products
set price = price * 1.10
where name like '%Dell%';

-- 4. deletar todos os Macbook
delete from products
where name like '%Macbook%';

-- 5. deletar todos os produtos que não tiverem pedidos regristrados
delete from products
where id not in (select product_id from orders_products);

-- 6. mostra todos os pedidos feito nos ultimos 30 dias
/*
pega a data atual e subtrai 30 dias (30/07)
pega todas as datas maior que 30/07
*/
select * from orders
where order_date >= now() - interval '30 days';

-- 7. Liste os pedidos e os respectivos nomes de usuários
select
    o.id as numero_pedido,
    u.name as nome_usuario
from orders o
left join users u on o.user_id = u.id;

-- 8. Listar todos os usuários e seus respectivos pedidos(inclusive usuários que não tem pedido)
select 
    u.id as id_usuario,
    u.name as nome_usuario,
    o.id as id_pedido,
    p.id as id_produto,
    p.name as nome_produto
from users u
left join orders o 
    on u.id = o.user_id
left join orders_products op 
    on o.id = op.order_id
full join products p 
    on op.product_id = p.id;


-- 9. Liste os usuário que realizaram pelo menos um pedido
select distinct
    u.id as id_usuario,
    u.name as nome_usuario,
    u.email as email
from users u  
join orders o  
    on u.id = o.user_id;

-- 10. Listando os produtos que nunca foram vendidos
select
    p.id as id_produto,
    p.name as nome_produto
from products p 
left join orders_products op 
    on p.id = op.product_id
where op.id is null;

-- 11. Liste usuários que nunca fizeram pedido
select
    u.name as nome_usuario,
    u.id as id_usuario
from users u
left join orders on u.id = orders.user_id
where orders.user_id is null;

-- 12. Liste os produtos acima da media em ordem decrescente
select
    price as preço,
    name as nome
from products
where price > (select avg(price) from products)
order by price desc;

-- 13. Liste a quantidade de produto pedido por cada usuário
select
    u.id as id_usuario,
    u.name as nome_usuario,
    count(o.id) as qtd_pedidos
from users u
left join orders o on u.id = o.user_id
group by u.id, u.name;
order by qtd_pedidos asc;

-- 14. Listar os três(03) produtos mais vendidos
select
    p.id as id_produto,
    p.name as produto,
    sum(op.quantity) as qtd_vendas
from products p 
left join orders_products op on p.id = op.product_id
group by p.id, p.name 
order by qtd_vendas desc
limit 3;

-- 15. Gerar relatório com: usuários, quantidade de pedidos e valor total comprado.

select 
    u.id as id_usuario,
    u.name as nome_usuario,
    count(o.id) as qtd_pedidos,
    sum(o.total) as preco_total
from users u 
left join orders o on u.id = o.user_id
group by u.id, u.name;

-- 