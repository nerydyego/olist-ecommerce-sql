
-- ============================================================
-- PROJETO: Olist Brazilian E-Commerce Dataset
-- ARQUIVO: 01_create_analytics_orders.sql
-- ETAPA: Transformação de dados (RAW -> ANALYTICS)
-- ============================================================
--
-- OBJETIVO:
-- Criar a tabela analytics.orders a partir de raw.orders,
-- preservando os registros originais e convertendo os campos
-- de data, inicialmente armazenados como TEXT, para TIMESTAMP.
--
-- REGRAS DE TRANSFORMAÇÃO:
-- 1. Preservar order_id, customer_id e order_status como TEXT.
-- 2. Remover espaços nas extremidades das datas com TRIM().
-- 3. Converter strings vazias em NULL utilizando NULLIF().
-- 4. Converter os cinco campos de data para TIMESTAMP.
-- 5. Preservar os nomes originais das colunas.
--
-- VALIDAÇÕES REALIZADAS:
-- Total na origem: 99.441 registros.
-- Total no destino: 99.441 registros.
-- Tipos verificados: 3 TEXT e 5 TIMESTAMP.
--
-- OBSERVAÇÃO:
-- O comando CREATE TABLE AS SELECT cria e popula a tabela,
-- mas não define automaticamente chaves ou índices.
-- A execução exige que analytics.orders ainda não exista.
-- ============================================================

CREATE TABLE analytics.orders AS
SELECT
    -- Identificadores e situação do pedido
    order_id,
    customer_id,
    order_status,

    -- Conversão das datas de TEXT para TIMESTAMP
    CAST(NULLIF(TRIM(order_purchase_timestamp), '') AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(NULLIF(TRIM(order_approved_at), '') AS TIMESTAMP) AS order_approved_at,
    CAST(NULLIF(TRIM(order_delivered_carrier_date), '') AS TIMESTAMP) AS order_delivered_carrier_date,
    CAST(NULLIF(TRIM(order_delivered_customer_date), '') AS TIMESTAMP) AS order_delivered_customer_date,
    CAST(NULLIF(TRIM(order_estimated_delivery_date), '') AS TIMESTAMP) AS order_estimated_delivery_date

FROM raw.orders;
