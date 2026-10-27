-- QUESTAO 1

begin;
insert into customer(customer_id,store_id, first_name, last_name, email,address_id)
values(999,99999,'teste', 'silva', 'silvateste@mail.com',1);

rollback;

/*
O cliente não existe mais, pois o princípio da atomicidade
garante que uma transação seja concluída apenas se todas as
operações sejam executadas com êxito, como o isso não ocorre
o comando de rollback retorna o banco para condição inicial 
antes do início da transação
*/

-- QUESTAO 2

begin;
savepoint estoque_atualizado
insert into inventory(film_id,store_id,last_update)
values(9999,1,now());

insert into inventory(film_id,store_id,last_update)
values(1,1,now());

commit;

/*
A tabela terá apenas o resgistro válido, pois se uma operação
da transação não tiver êxito a transação fica bloqueada até que
seja executada um commit ou rollback, ao executar o commit o banco automaticamente
executará um rollback retornando o banco ao estado original ou então
ao estado guardado em um savepoint, que tem por vantagem trazer o banco
para estado definido pelo programador no meio da transação
*/
