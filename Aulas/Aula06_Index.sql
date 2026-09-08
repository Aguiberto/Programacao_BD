select
    schamanema;
    tablename,
    indexname,
    indexdef,
from pg_indexes
where tablename = 'address'
order by tablename, indexname;

select
    address_id,
    

from address
where phone = '223664661973';

explain analyse

drop index if exists idx_address_phone;

create index idx_address_phone on address(phone);
