create view vw_circuit_datais AS
select
    c.id as id_circuito,
    c.name as nome_circuito,
    c.place_name as cidade,
    co.name as pais,
    ct.name as continente,
    c.type as tipo,
    c.length as comprimento,
    c.turns as total_voltas
from circuit c
join country co on c.country_id = co.id
join continent ct on co.continent_id = ct.id;

select * from vw_circuit_datais where pais = 'Brazil';

-- histórico de qual fabricante de motor, cada equipe usou em cada temporada
create or replace view vw_constructor_engine_history as 
select
    sec.year as temporada,
    c.name as equipe,
    em.name as fabricante_motor
from season_entrant_constructor sec 
join constructor c on sec.constructor_id = c.id
join engine_manufacturer em on sec.engine_manufacturer_id = em.id;

select * 
from vw_constructor_engine_history
where temporada = 2023
order by equipe asc;

-- view para listar os circuitos
create or replace view vw_circuit_countries as
select
    cir.name as nome_circuito,
    cir.place_name as cidade,
    coun.name as pais,
    coun.alpha2_code as codigo
from circuit cir 
join country coun on cir.country_id = coun.id;

select *
from vw_circuit_countries;

select * 
from vw_circuit_countries
where pais = 'Brazil';

create or replace view vw_driver_nationalites as 
select
    dri.full_name as nome_piloto,
    dri.abbreviation as abrevicao,
    nat.name as nacionalidade,
    coun.name as compete_por
from driver dri 
join country coun on dri.nationality_country_id = coun.id
join country nat on dri.country_of_birth_country_id = nat.id;

select * 
from vw_driver_nationalites;

-- quantidade de Grandes Prêmios
create or replace view vw_country_grand_prix_count as 
select
    c.name as pais,
    count(gp.id) as total_grandes_premios
from country c
join grand_prix gp on gp.country_id = c.id 
group by c.id, c.name
order by total_grandes_premios desc;

-- total de vitórias acumuladas por equipes
create or replace view vw_constructor_wins as
select
    coun.name as pais,
    count(con.id) as total_equipes,
    sum(con.total_race_wins) as total_corridas_ganhas
from constructor con
join country coun on con.country_id = coun.id
group by  coun.id, con.name;

select *
from vw_constructor_wins;

-- resumo de tipo de circuito
create or replace view vw_circut_type_summary as 
select
    c.type as tipo,
    count(c.type) as quantidade_tipo,
    sum(c.total_races_held) as total_corridas
from circuit c 
group by c.type;

select * 
from vw_circut_type_summary;

-- estatística de quantos temporadas o piloto esteve em corridas
create or replace view vw_season_driver_stats as 
select
    d.full_name as nome_piloto,
    count(sed.year) as qtd_participacoes,
    min(sed.year) as primeiro_ano,
    max(sed.year) as ultimo_ano
from season_entrant_driver sed 
join driver d on sed.driver_id = d.id
group by d.id, d.full_name;

select *
from vw_season_driver_stats;

create or replace view vw_country_constructor_stats as
select
    cn.name as nome_pais,
    count(c.id) as qtd_equipes,
    max(c.total_championship_wins) as maior_qtd_campeonatos,
    max(c.total_race_wins) as maior_qtd_vitorias
from constructor c
join country cn on c.country_id = cn.id
group by cn.id, cn.name;

select * 
from vw_country_constructor_stats
order by maior_qtd_campeonatos desc;