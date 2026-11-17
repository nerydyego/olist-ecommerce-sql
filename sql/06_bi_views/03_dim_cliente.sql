-- Verificação de unicidade
select 
	customer_id,
	count(*) as quantidade
from analytics.customers
group by customer_id
having count(*) > 1;

-- Criar a view bi.dim_cliente
create or replace view bi.dim_cliente as
select 
	customer_id,
	customer_unique_id,
	customer_zip_code_prefix,
	customer_city,
	customer_state
from analytics.customers;

-- Verificação de quantidade de registros
select 
	count(*)
from bi.dim_cliente;