/*
 * ETAPA: TRANSFORMAÇÃO DA TABELA PRODUCTS
 *
 * Objetivo:
 * Criar analytics.products a partir de raw.products,
 * convertendo os campos numéricos para INTEGER.
 *
 * Validações realizadas:
 * - 32.951 registros na origem.
 * - product_id único e sem valores nulos ou vazios.
 * - 32.341 valores preenchidos nas colunas descritivas numéricas.
 * - 32.949 valores preenchidos nas medidas físicas.
 * - 0 itens de pedidos com produtos inexistentes.
 *
 * Observação:
 * Preservar valores ausentes como NULL.
 * Manter os dados originais na camada raw.
 */

CREATE TABLE analytics.products AS
SELECT
	product_id,
	product_category_name,
	cast(nullif(trim(product_name_lenght), '') AS INTEGER) AS product_name_lenght, 
	cast(nullif(trim(product_description_lenght), '') AS INTEGER) AS product_description_lenght, 
	cast(nullif(trim(product_photos_qty), '') AS INTEGER) AS product_photos_qty, 
	cast(nullif(trim(product_weight_g), '') AS INTEGER) AS product_weight_g, 
	cast(nullif(trim(product_length_cm), '') AS INTEGER) AS product_length_cm, 
	cast(nullif(trim(product_height_cm), '') AS INTEGER) AS product_height_cm, 
	cast(nullif(trim(product_width_cm), '') AS INTEGER) AS product_width_cm
FROM raw.products;

-- Quantidade de registros
select count(*) from analytics.products;

-- Tipos do dados
select column_name, data_type 
from information_schema.columns 
where table_schema = 'analytics'
and table_name = 'products'
order by ordinal_position;