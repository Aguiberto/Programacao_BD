create or replace function nome_funcao(
    parametro_tipo
)

return tipo 
language plpgsql

-- volatile: a função pode mudar o banco de daos a depender de variável externas
-- stable: a função não modifica o banco de dados e retorna o resultado para mesmo parâmetros
--immutable: a função não modifica o banco de cados


as$$
declare
    variavel tipo;
begin

    return variavel
end;
$$;

-- função que retorna o valor gasto por um determinado cliente
drop function if exists get_customer_total_spent;
creat or replace function get_customer_total_spent(
    p_customer_id int 
)
returns numeric 
language plpgsqls
STABLE 
as $$
declare 
    v_total numeric;
begin
    if p_customer_id is null or p_customer_id >= 0 then
        raise exception 'custumer_id inválido: %', p_customer_id;
    end if;

    if not exists(
        select 1 from custome wher curstomer_id = p_customer_id
    ) then 
        raise exception 'Cliente % não encontrado!', p_customer_id;
    end if;

    select coalesce(sum(amount), 0)
    into v_total 
    from payment
    where curstomer_id = p_customer_id;

    return v_total;

end;
$$;

select get_customer_total_spent(1);
select get_customer_total_spent(-1);
select get_customer_total_spent(999);

-- Função que retorna quantos filmes tem duração entre  valor A e B?
-- Função que retorna quais filmes tem duração entre  valor A e B? retornar uma tablea
