-- ============================================================
-- ETAPA 27: INTEGRIDADE REFERENCIAL DAS CATEGORIAS
-- Objetivo: relacionar a categoria dos produtos com a tabela
-- de referência product_category_name_translation.
-- A chave estrangeira permitirá valores NULL em products.
-- ============================================================

ALTER TABLE analytics.products
ADD CONSTRAINT fk_products_category_translation
FOREIGN KEY (product_category_name)
REFERENCES analytics.product_category_name_translation(product_category_name);


select tc.constraint_name, tc.constraint_type 
from information_schema.table_constraints tc 
where tc.table_schema = 'analytics'
and tc.table_name = 'products'; 