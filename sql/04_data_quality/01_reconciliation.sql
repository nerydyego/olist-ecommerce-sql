-- ============================================================
-- PROJETO OLIST E-COMMERCE
-- ETAPA 5.1 - RECONCILIACAO RAW X ANALYTICS
-- ============================================================
-- Objetivo: comparar o volume de registros entre as camadas
-- RAW e Analytics, identificando e justificando divergencias.
--
-- 5.1.1 - Contagem de registros na camada Analytics
-- ============================================================

select count(*) as total_registros_analytics_customers
from analytics.customers; 
union
select count(*) as total_registros_raw_customers
from raw.customers; 

--Subconsulta escalar
-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: customers
-- ============================================================
-- RAW: 99.441 registros
-- Analytics: 99.441 registros
-- Diferenca: 0
-- Resultado: contagens reconciliadas.
-- Observacao: a igualdade quantitativa nao garante
-- a igualdade integral dos registros.
-- ============================================================
select 
	(select count(*) from analytics.customers) as total_registros_analytics_customers,
	(select count(*) from raw.customers) as total_registros_raw_customers,
	(select count(*) from analytics.customers) - (select count(*) from raw.customers) as diferenca;

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: orders
-- ============================================================
-- RAW: 99.441 registros
-- Analytics: 99.441 registros
-- Diferenca: 0
-- Resultado: contagens reconciliadas.
-- Observacao: a igualdade quantitativa nao garante
-- a igualdade integral dos registros.
-- ============================================================
select 
	(select count(*) from analytics.orders) as total_registros_analytics_orders,
	(select count(*) from raw.orders) as total_registros_raw_orders,
	(select count(*) from analytics.orders) - (select count(*) from raw.orders) as diferenca;

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: order_items
-- ============================================================
-- RAW: 112.650 registros
-- Analytics: 112.650 registros
-- Diferenca: 0
-- Resultado: contagens reconciliadas.
-- Observacao: a igualdade quantitativa nao garante
-- a igualdade integral dos registros.
-- ============================================================
select 
	(select count(*) from analytics.order_items) as total_registros_order_items,
	(select count(*) from raw.order_items) as total_registros_raw_order_items,
	(select count(*) from analytics.order_items) - (select count(*) from raw.order_items) as diferenca;

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: order_payments
-- ============================================================
-- RAW: 103.886 registros
-- Analytics: 103.886 registros
-- Diferenca: 0
-- Resultado: contagens reconciliadas.
-- Observacao: a igualdade quantitativa nao garante
-- a igualdade integral dos registros.
-- ============================================================
select 
	(select count(*) from analytics.order_payments) as total_registros_order_payments,
	(select count(*) from raw.order_payments) as total_registros_raw_order_payments,
	(select count(*) from analytics.order_payments) - (select count(*) from raw.order_payments) as diferenca;

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: order_reviews
-- ============================================================
-- RAW: 99.224 registros
-- Analytics: 99.224 registros
-- Diferenca: 0
-- Resultado: contagens reconciliadas.
-- Observacao: a igualdade quantitativa nao garante
-- a igualdade integral dos registros.
-- ============================================================
select 
	(select count(*) from analytics.order_reviews) as total_registros_order_reviews,
	(select count(*) from raw.order_reviews) as total_registros_raw_order_reviews,
	(select count(*) from analytics.order_reviews) - (select count(*) from raw.order_reviews) as diferenca;

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: products
-- ============================================================
-- RAW: 32.951 registros
-- Analytics: 32.951 registros
-- Diferenca: 0
-- Resultado: contagens reconciliadas.
-- Observacao: a igualdade quantitativa nao garante
-- a igualdade integral dos registros.
-- ============================================================
select 
	(select count(*) from analytics.products) as total_registros_products,
	(select count(*) from raw.products) as total_registros_raw_products,
	(select count(*) from analytics.products) - (select count(*) from raw.products) as diferenca;

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: sellers
-- ============================================================
-- RAW: 3.095 registros
-- Analytics: 3.095 registros
-- Diferenca: 0
-- Resultado: contagens reconciliadas.
-- Observacao: a igualdade quantitativa nao garante
-- a igualdade integral dos registros.
-- ============================================================
select 
	(select count(*) from analytics.sellers) as total_registros_sellers,
	(select count(*) from raw.sellers) as total_registros_raw_sellers,
	(select count(*) from analytics.sellers) - (select count(*) from raw.sellers) as diferenca;

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: geolocation
-- ============================================================
-- RAW: 1.000.163 registros
-- Analytics: 738.332 registros
-- Diferenca: -261.831
-- Reducao percentual: 26,18%
--
-- Regra: SELECT DISTINCT nas cinco colunas, com conversao
-- de latitude e longitude para NUMERIC.
--
-- Validacao: 738.332 combinacoes distintas identificadas
-- na RAW, correspondentes ao total da Analytics.
--
-- Resultado: reconciliacao quantitativa conforme a regra.
-- ============================================================
select 
	(select count(*) from analytics.geolocation) as total_registros_analytics_geolocation,
	(select count(*) from raw.geolocation) as total_registros_raw_geolocation,
	(select count(*) from analytics.geolocation) - (select count(*) from raw.geolocation) as diferenca;

-- combinações distintas existem na raw
select count(*) as total_registros_distintos
from (
	select DISTINCT
		geolocation_zip_code_prefix,
		CAST(geolocation_lat AS NUMERIC) AS geolocation_lat,
		CAST(geolocation_lng AS NUMERIC) AS geolocation_lng,
		geolocation_city,
	 	geolocation_state
 	from raw.geolocation
);

-- ============================================================
-- 5.1 - RECONCILIACAO RAW X ANALYTICS
-- Tabela: product_category_name_translation
-- ============================================================
-- RAW: 71 registros
-- Analytics: 73 registros
-- Diferenca: +2
--
-- Justificativa: inclusao manual de duas categorias:
-- 1. pc_gamer
-- 2. portateis_cozinha_e_preparadores_de_alimentos
--
-- Ambas foram inseridas com traducao em ingles NULL.
-- Resultado: diferenca quantitativa justificada.
-- ============================================================
select 
	(select count(*) from analytics.product_category_name_translation) as total_registros_analytics_product_category_name_translation,
	(select count(*) from raw.product_category_name_translation) as total_registros_raw_product_category_name_translation,
	(select count(*) from analytics.product_category_name_translation) - (select count(*) from raw.product_category_name_translation) as diferenca;

-- identificação de categoria adicionados
select * from analytics.product_category_name_translation
except 
select * from raw.product_category_name_translation

