-- ============================================================
-- ETAPA 26: COMPLEMENTAÇÃO DAS CATEGORIAS DE PRODUTOS
-- Objetivo: cadastrar duas categorias existentes em products
-- que não possuem correspondência na tabela de tradução.
-- As traduções em inglês serão mantidas como NULL.
-- Os dados originais da camada RAW serão preservados.
-- ============================================================

INSERT INTO analytics.product_category_name_translation
	(product_category_name, product_category_name_english)
VALUES 
	('pc_gamer', null),
	('portateis_cozinha_e_preparadores_de_alimentos', null);

select count(*) produtos_sem_traducao
from analytics.products as p 
left join analytics.product_category_name_translation as pcnt 
on p.product_category_name = pcnt.product_category_name 
where p.product_category_name is not null
and pcnt.product_category_name is null;

select count(*) as total_categorias
from analytics.product_category_name_translation