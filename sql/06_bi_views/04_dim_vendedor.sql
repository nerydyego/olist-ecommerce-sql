-- Verificação de inicidade

select 
	seller_id, 
	count (*)
from analytics.sellers
group by seller_id 
having count(*) > 1;

-- Criação da View dim_vendedor

create or replace view bi.dim_vendedor as 
select 
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
from analytics.sellers;

-- Verificação de quantidade de registros
select 
	count(*)
from bi.dim_vendedor;