/*
============================================================
Projeto: Olist Brazilian E-Commerce Dataset
Etapa: 02 - Preparação do PostgreSQL
Arquivo: 03_create_raw_tables.sql

Objetivo:
Criar as tabelas da camada RAW para receber os dados
originais provenientes dos arquivos CSV do Olist.

Observação:
A camada RAW será mantida próxima à fonte, sem aplicação
inicial de regras de limpeza, PKs ou FKs.
============================================================
*/


-- =========================================================
-- CUSTOMERS
-- Fonte: olist_customers_dataset.csv
-- =========================================================

CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id              TEXT,
    customer_unique_id       TEXT,
    customer_zip_code_prefix TEXT,
    customer_city            TEXT,
    customer_state           TEXT
);

-- =========================================================
-- ORDERS
-- Fonte: olist_orders_dataset.csv
-- =========================================================

CREATE TABLE IF NOT EXISTS raw.orders (
    order_id                      TEXT,
    customer_id                   TEXT,
    order_status                  TEXT,
    order_purchase_timestamp      TEXT,
    order_approved_at             TEXT,
    order_delivered_carrier_date  TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT
);

-- =========================================================
-- ORDERS ITEMS
-- Fonte: olist_order_items_dataset.csv
-- Objetivo: armazenar os itens associados aos pedidos.
-- Observação: dados preservados como TEXT na camada RAW.
-- =========================================================

create table if not exists raw.order_items (
	order_id text,
	order_item_id text,
	product_id text,
	seller_id text,
	shipping_limit_date text,
	price text,
	freight_value text
	);

-- =========================================================
-- ORDER PAYMENTS
-- Fonte: olist_order_payments_dataset.csv
-- Objetivo: armazenar os pagamentos associados aos pedidos.
-- Um pedido pode possuir múltiplos registros de pagamento.
-- Os dados serão inicialmente armazenados como TEXT.
-- =========================================================

create table if not exists raw.order_payments (
	order_id text,
	payment_sequential text,
	payment_type text,
	payment_installments text,
	payment_value text
);

-- =========================================================
-- ORDER REVIEWS
-- Fonte: olist_order_reviews_dataset.csv
-- Objetivo: armazenar avaliações realizadas sobre os pedidos.
-- Inclui notas, comentários e datas relacionadas às avaliações.
-- Os dados serão inicialmente armazenados como TEXT.
-- =========================================================

create table if not exists raw.order_reviews ( 
	review_id text,
	order_id text,
	review_score text,
	review_comment_title text,
	review_comment_message text,
	review_creation_date text,
	review_answer_timestamp text
);

-- =========================================================
-- PRODUCTS
-- Fonte: olist_products_dataset.csv
-- Objetivo: armazenar informações cadastrais dos produtos,
-- incluindo categoria, dimensões, peso e características.
-- Os dados serão inicialmente armazenados como TEXT.
-- =========================================================

create table if not exists raw.products (
	product_id text,
	product_category_name text,
	product_name_lenght text,
	product_description_lenght text,
	product_photos_qty text,
	product_weight_g text,
	product_length_cm text,
	product_height_cm text,
	product_width_cm text
);
/*
SELLERS
Fonte: olist_sellers_dataset.csv
Objetivo: armazenar informações cadastrais e de
localização dos vendedores da plataforma Olist.
Os dados serão inicialmente armazenados como TEXT.
*/
create table if not exists raw.sellers( 
	seller_id text,
	seller_zip_code_prefix text,
	seller_city text,
	seller_state text
);
/*
GEOLOCATION
Fonte: olist_geolocation_dataset.csv
Objetivo: armazenar coordenadas geográficas e informações
de localização associadas aos prefixos de CEP.
Os dados serão inicialmente armazenados como TEXT.
*/
create table if not exists raw.geolocation( 
	geolocation_zip_code_prefix text,
	geolocation_lat text,
	geolocation_lng text,
	geolocation_city text,
	geolocation_state text
);
-- =========================================================
-- PRODUCT CATEGORY NAME TRANSLATION
-- Fonte: product_category_name_translation.csv
-- Objetivo: armazenar a correspondência entre os nomes
-- das categorias de produtos em português e inglês.
-- Os dados serão inicialmente armazenados como TEXT.
-- =========================================================
create table if not exists raw.product_category_name_translation ( 
	product_category_name text,
	product_category_name_english text
);
