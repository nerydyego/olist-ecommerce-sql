-- ============================================================
-- ETAPA 25: NORMALIZAÇÃO DAS CATEGORIAS DOS PRODUTOS
-- Objetivo: substituir por NULL os valores vazios ou compostos
-- apenas por espaços na coluna product_category_name.
-- A alteração será realizada exclusivamente na camada ANALYTICS.
-- A tabela RAW permanecerá inalterada.
-- ============================================================

update analytics.products
set product_category_name = null
where trim(product_category_name) = ''
and product_category_name is not null;

select count(*) as categorias_vazias_analytics
from analytics.products as p 
where p.product_category_name is not null 
and nullif(trim(product_category_name), '') is null;

select 
	count(*) as total_produtos,
	count(product_category_name) as categorias_preenchidas,
	count(*) - count(product_category_name) as categorias_nulas
from analytics.products;

select count(*) produtos_sem_traducao
from analytics.products as p 
left join analytics.product_category_name_translation as pcnt 
on p.product_category_name = pcnt.product_category_name 
where p.product_category_name is not null
and pcnt.product_category_name is null;

select p.product_id , p.product_category_name, pcnt.product_category_name, pcnt.product_category_name_english  
from analytics.products as p 
left join analytics.product_category_name_translation as pcnt 
on p.product_category_name = pcnt.product_category_name 
where p.product_category_name is not null
and pcnt.product_category_name is null;

select p.product_id , p.product_category_name, pcnt.product_category_name, pcnt.product_category_name_english  
from analytics.products as p 
left join analytics.product_category_name_translation as pcnt 
on p.product_category_name = pcnt.product_category_name 
limit 20;

select column_name, data_type, is_nullable
from information_schema.columns 
where table_schema = 'analytics'
and table_name = 'product_category_name_translation'
and column_name = 'product_category_name_english';