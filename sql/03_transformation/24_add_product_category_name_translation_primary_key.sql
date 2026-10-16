-- ============================================================
-- ETAPA 24: CRIAÇÃO DA CHAVE PRIMÁRIA DAS CATEGORIAS
-- Objetivo: definir product_category_name como chave primária
-- da tabela analytics.product_category_name_translation.
-- A restrição garante unicidade e ausência de valores NULL.
-- ============================================================

ALTER TABLE analytics.product_category_name_translation
ADD CONSTRAINT pk_product_category_name_translation
PRIMARY KEY (product_category_name);

--verificação de chave primaria
select constraint_name, constraint_type
from information_schema.table_constraints 
where table_schema = 'analytics'
and table_name = 'product_category_name_translation';

-- 
select count(*) as produtos_sem_traducao
from analytics.products as p
left join analytics.product_category_name_translation as pcnt
on p.product_category_name = pcnt.product_category_name 
where p.product_category_name is not null
and pcnt.product_category_name is null;

--quais categorias estão ausentes e quantos produtos pertencem a cada uma.

select p.product_category_name, count(*) as quantidades_de_produtos
from analytics.products as p
left join analytics.product_category_name_translation as pcnt
on p.product_category_name = pcnt.product_category_name 
where p.product_category_name is not null
and pcnt.product_category_name is null
group by p.product_category_name 
order by quantidades_de_produtos desc;


select count(*) as categorias_vazias
from analytics.products as p 
where p.product_category_name is not null 
and nullif(trim(product_category_name), '') is null;

select count(*) as categorias_vazias_raw
from raw.products as p 
where p.product_category_name is not null 
and nullif(trim(product_category_name), '') is null;


