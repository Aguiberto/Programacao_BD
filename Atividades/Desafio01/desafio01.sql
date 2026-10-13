-- QUESTÃO 1
/*
O painel analítico precisa de um resumo rápido por piloto/temporada 
sem consultar a gigantesca race_data a cada acesso. 
Crie uma materialized view mv_driver_season_summary 
que agregue os resultados de corrida (type = 'RACE_RESULT') 
mostrando: ano, piloto, total de corridas, vitórias, pódios, abandonos (DNFs) e total de pontos. Inclua um índice único e o comando de REFRESH CONCURRENTLY. Para testar, exibir o resumo das 10 últimas temporadas de Ayrton Senna.
*/

create or replace materialized_view mv_driver_season_summary
select
    sd.year as ano,
    d.full_name as piloto,
    sd.total_race_entries as total_corridas,
    sd.total_race_wins as vitorias,
    sd.total_podiums as podios,
    count(rd.race_reason_reatired) as qtd_abandonos,
    sd.total_points as pontos_totais
from season_driver sd 
join driver d on sd.driver_id = d.id
join race_data rd on sd.driver_id = rd.driver_id


-- QUESTÃO 2
/*
Pontos do campeonato podem ser ajustados após penalizações. 
Crie uma tabela de auditoria `points_adjustment_audit` e uma trigger na tabela `season_driver_standing`
 que registre alterações de pontos **apenas quando houver mudança real**. 
 Para testar, tente incrementar a quantidade de pontos da temporada 1993 de Ayrton Senna em 100. 
 Verifique se a tabela `points_adjustment_audit` foi atualizada.
*/

DROP TABLE IF EXISTS points_adjustment_audit;
CREATE TABLE points_adjustment_audit (
    id         SERIAL PRIMARY KEY,
    year       INT NOT NULL,
    driver_id  VARCHAR(100) NOT NULL,
    old_points DECIMAL(8,2),
    new_points DECIMAL(8,2),
    changed_at TIMESTAMPTZ DEFAULT NOW(),
);

create or replace function fn_check_point_changes()
return trigger as $$
begin

    if new.total_points <> old.total_points then

        -- id e changed_at são adicionados automaticamente
        insert into points_adjustment_audit(year, driver_id, old_points, new_points)
        values(year,driver_id,old,new)

    end if;
    return new;

end;
$$ language plpgsql;

create or replace trigger trg_check_point_changes as 
after update on driver
for each row
execute function fn_check_point_changes;

-- QUESTÃO 3 
/*
Crie uma trigger para impedir a exclusão de um piloto da tabela `driver` 
caso existam registros na `race_data` vinculados a ele. 
Lance uma exceção com o nome do piloto. 
Para testar, tente excluir Ayrton Senna da tabela `driver`. 
Logo após, exclua algum piloto sem registros em `race_data`.
*/

create or replace function fn_check_driver()
returns trigger as $$
begin

    if old.race_data <> null then
        raise exception 'O piloto não pode ser excluído'
    end if;

return new;
end;
$$ language plpgsql;

create or replace trigger as 
before delete on driver
for each row
execute function fn_check_driver;