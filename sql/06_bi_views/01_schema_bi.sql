create schema if not exists bi;

select schema_name
from information_schema.schemata 
where schema_name = 'bi';


