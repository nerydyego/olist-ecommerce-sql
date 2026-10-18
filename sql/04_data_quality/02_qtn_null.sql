
-- ============================================================
-- PROJETO: OLIST BRAZILIAN E-COMMERCE
-- ETAPA 5.2: AUDITORIA DE COMPLETUDE
-- ARQUIVO: sql/04_data_quality/02_qtn_null.sql
-- ============================================================
--
-- OBJETIVO:
-- Identificar valores ausentes nas tabelas da camada Analytics
-- e verificar sua preservacao em relacao a camada RAW.
--
-- CONVENCOES:
-- RAW       : campos ausentes representados por texto vazio ('')
-- ANALYTICS : campos ausentes padronizados como NULL
--
-- ESCOPO:
-- 1. analytics.orders
-- 2. analytics.products
--
-- OBSERVACOES:
-- As consultas sao somente de leitura.
-- Nenhum registro sera alterado, removido ou preenchido.
-- ============================================================


-- ============================================================
-- 01. COMPLETUDE - ORDERS
-- ============================================================

-- 01.1. Contagem geral de valores NULL
-- Objetivo:
-- Quantificar a ausencia de datas de aprovacao, envio e entrega
-- considerando todos os pedidos, independentemente do status.

SELECT
    COUNT(*) AS total_de_pedidos,
    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS total_null_order_approved_at,
    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NULL
    ) AS total_null_order_delivered_carrier_date,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS total_null_order_delivered_customer_date
FROM analytics.orders;

-- RESULTADOS VALIDADO​S:
-- Total de pedidos:                  99.441
-- Sem data de aprovacao:                160
-- Sem data de envio:                  1.783
-- Sem data de entrega:                2.965


-- 01.2. Distribuicao das ausencias por status
-- Objetivo:
-- Diferenciar ausencias potencialmente esperadas no ciclo
-- operacional de pedidos de inconsistencias que exigem atencao.

SELECT
    order_status,
    COUNT(*) AS total_de_pedidos,
    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS total_null_order_approved_at,
    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NULL
    ) AS total_null_order_delivered_carrier_date,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS total_null_order_delivered_customer_date
FROM analytics.orders
GROUP BY order_status
ORDER BY total_de_pedidos DESC;


-- 01.3. Percentual de valores ausentes por status
-- Objetivo:
-- Calcular a taxa de ausencia em cada grupo de pedidos.
-- Os percentuais sao arredondados para duas casas decimais.
--
-- ATENCAO:
-- Um resultado de 0,00% nao significa necessariamente
-- ausencia de registros afetados.

SELECT
    order_status,
    COUNT(*) AS total_de_pedidos,
    ROUND(
        COUNT(*) FILTER (
            WHERE order_approved_at IS NULL
        ) * 100.0 / COUNT(*), 2
    ) AS pct_null_order_approved_at,
    ROUND(
        COUNT(*) FILTER (
            WHERE order_delivered_carrier_date IS NULL
        ) * 100.0 / COUNT(*), 2
    ) AS pct_null_order_delivered_carrier_date,
    ROUND(
        COUNT(*) FILTER (
            WHERE order_delivered_customer_date IS NULL
        ) * 100.0 / COUNT(*), 2
    ) AS pct_null_order_delivered_customer_date
FROM analytics.orders
GROUP BY order_status
ORDER BY total_de_pedidos DESC;


-- 01.4. Achados de completude em pedidos entregues
-- Objetivo:
-- Quantificar ausencias em datas operacionais de pedidos
-- classificados como delivered.
--
-- DQ-001: 14 pedidos entregues sem data de aprovacao.
-- DQ-002:  2 pedidos entregues sem data de envio.
-- DQ-003:  8 pedidos entregues sem data de entrega.
--
-- Os achados podem compartilhar os mesmos pedidos.
-- Portanto, as quantidades nao devem ser somadas para
-- calcular o numero de pedidos distintos afetados.

SELECT
    COUNT(*) AS total_pedidos_entregues,
    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS dq_001_sem_aprovacao,
    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NULL
    ) AS dq_002_sem_envio,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS dq_003_sem_entrega
FROM analytics.orders
WHERE order_status = 'delivered';


-- 01.5. Verificacao quantitativa das ausencias na RAW
-- Objetivo:
-- Conferir se os tres achados identificados em pedidos
-- entregues ja estavam presentes como strings vazias na RAW.
--
-- RESULTADOS VALIDADOS:
-- DQ-001: 14 registros
-- DQ-002:  2 registros
-- DQ-003:  8 registros

SELECT
    COUNT(*) AS total_pedidos_entregues_raw,
    COUNT(*) FILTER (
        WHERE order_approved_at = ''
    ) AS dq_001_raw_sem_aprovacao,
    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date = ''
    ) AS dq_002_raw_sem_envio,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date = ''
    ) AS dq_003_raw_sem_entrega
FROM raw.orders
WHERE order_status = 'delivered';


-- CONCLUSAO - ORDERS:
-- As ausencias dos achados DQ-001, DQ-002 e DQ-003 foram
-- verificadas na RAW e na Analytics.
-- As comparacoes de identificadores realizadas durante
-- a investigacao nao identificaram divergencias.
--
-- A transformacao utiliza a expressao:
-- CAST(NULLIF(TRIM(coluna), '') AS TIMESTAMP)
--
-- Essa regra converte textos vazios em NULL antes da
-- conversao para TIMESTAMP.
--
-- DECISAO:
-- Preservar os valores NULL e documentar suas limitacoes
-- nos indicadores dependentes das datas operacionais.


-- ============================================================
-- 02. COMPLETUDE - PRODUCTS
-- ============================================================

-- 02.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- dos produtos.

SELECT
    COUNT(*) AS total_produtos,
    COUNT(*) FILTER (
        WHERE product_name_lenght IS NULL
    ) AS null_product_name_lenght,
    COUNT(*) FILTER (
        WHERE product_description_lenght IS NULL
    ) AS null_product_description_lenght,
    COUNT(*) FILTER (
        WHERE product_photos_qty IS NULL
    ) AS null_product_photos_qty,
    COUNT(*) FILTER (
        WHERE product_weight_g IS NULL
    ) AS null_product_weight_g,
    COUNT(*) FILTER (
        WHERE product_length_cm IS NULL
    ) AS null_product_length_cm,
    COUNT(*) FILTER (
        WHERE product_height_cm IS NULL
    ) AS null_product_height_cm,
    COUNT(*) FILTER (
        WHERE product_width_cm IS NULL
    ) AS null_product_width_cm
FROM analytics.products;

-- RESULTADOS VALIDADOS:
-- Total de produtos:               32.951
-- product_name_lenght:                610
-- product_description_lenght:         610
-- product_photos_qty:                 610
-- product_weight_g:                     2
-- product_length_cm:                    2
-- product_height_cm:                    2
-- product_width_cm:                     2


-- 02.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_produtos_raw,
    COUNT(*) FILTER (
        WHERE product_name_lenght = ''
    ) AS vazio_product_name_lenght,
    COUNT(*) FILTER (
        WHERE product_description_lenght = ''
    ) AS vazio_product_description_lenght,
    COUNT(*) FILTER (
        WHERE product_photos_qty = ''
    ) AS vazio_product_photos_qty,
    COUNT(*) FILTER (
        WHERE product_weight_g = ''
    ) AS vazio_product_weight_g,
    COUNT(*) FILTER (
        WHERE product_length_cm = ''
    ) AS vazio_product_length_cm,
    COUNT(*) FILTER (
        WHERE product_height_cm = ''
    ) AS vazio_product_height_cm,
    COUNT(*) FILTER (
        WHERE product_width_cm = ''
    ) AS vazio_product_width_cm
FROM raw.products;

-- RESULTADO:
-- As quantidades de campos vazios na RAW correspondem
-- as quantidades de NULL na Analytics para os sete atributos.
--
-- Nenhuma divergencia quantitativa foi identificada.


-- 02.3. Categorias ausentes: Analytics -> RAW
-- Objetivo:
-- Identificar produtos com categoria NULL na Analytics
-- que nao possuem categoria vazia na RAW.
--
-- RESULTADO VALIDADO: zero linhas.

SELECT product_id
FROM analytics.products
WHERE product_category_name IS NULL

EXCEPT

SELECT product_id
FROM raw.products
WHERE product_category_name = '';


-- 02.4. Categorias ausentes: RAW -> Analytics
-- Objetivo:
-- Identificar produtos com categoria vazia na RAW
-- que nao possuem categoria NULL na Analytics.
--
-- RESULTADO VALIDADO: zero linhas.

SELECT product_id
FROM raw.products
WHERE product_category_name = ''

EXCEPT

SELECT product_id
FROM analytics.products
WHERE product_category_name IS NULL;


-- CONCLUSAO - PRODUCTS:
-- RAW e Analytics possuem 32.951 registros.
--
-- As contagens de ausencias dos sete atributos analisados
-- sao equivalentes entre as duas camadas.
--
-- As verificacoes bidirecionais com EXCEPT confirmaram
-- a equivalencia dos conjuntos de product_id com
-- categoria ausente.
--
-- Nenhuma divergencia foi identificada nas verificacoes
-- de completude realizadas.
--
-- LIMITACAO:
-- A igualdade das contagens nao comprova que todos os
-- valores nao nulos foram preservados sem alteracoes.
-- Essa verificacao nao faz parte do escopo deste script.


-- ============================================================
-- 03. COMPLETUDE - ORDER_ITEMS
-- ============================================================

-- 03.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- das order_items.

SELECT * FROM analytics.order_items;

SELECT
    COUNT(*) AS total_order_items,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS null_order_item_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
    COUNT(*) FILTER (WHERE shipping_limit_date IS null) AS null_shipping_limit_date,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS null_freight_value
FROM analytics.order_items;

-- RESULTADOS VALIDADOS:
-- total order_items:	112650
-- order_item_id:         	 0
-- seller_id:                0
-- shipping_limit_date:      0
-- price:                    0
-- freight_value:            0


-- 03.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_order_items,
    COUNT(*) FILTER (WHERE order_item_id = '') AS raw_null_order_item_id,
    COUNT(*) FILTER (WHERE product_id = '') AS raw_null_product_id,
    COUNT(*) FILTER (WHERE seller_id = '') AS raw_null_seller_id,
    COUNT(*) FILTER (WHERE shipping_limit_date = '') AS raw_null_shipping_limit_date,
    COUNT(*) FILTER (WHERE price = '') AS raw_null_price,
    COUNT(*) FILTER (WHERE freight_value = '') AS raw_null_freight_value
FROM raw.order_items;

-- RESULTADOS:
-- Total RAW:       112.650
-- Total Analytics: 112.650
--
-- Nenhum valor ausente identificado nos seis campos
-- analisados em ambas as camadas.
--
-- CONCLUSAO:
-- Nenhuma divergencia de completude identificada.
-- Verificacao de order_id pendente de inclusao.

-- ============================================================
-- 04. COMPLETUDE - ORDER_PAYMENTS
-- ============================================================

-- 04.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- das order_payments.

SELECT * FROM analytics.order_payments;

SELECT
    COUNT(*) AS total_order_payments,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE payment_sequential IS NULL) AS null_payment_sequential,
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS null_payment_type,
    COUNT(*) FILTER (WHERE payment_installments IS null) AS null_payment_installments,
    COUNT(*) FILTER (WHERE payment_value IS NULL) AS null_payment_value
FROM analytics.order_payments;

-- RESULTADOS VALIDADOS:
-- total order_payments:	103886
-- order_id:         			 0
-- payment_sequential:           0
-- payment_type:      			 0
-- payment_installments:         0
-- payment_value:            	 0


-- 04.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_order_payments,
    COUNT(*) FILTER (WHERE order_id ='') AS raw_null_order_id,
    COUNT(*) FILTER (WHERE payment_sequential = '') AS raw_null_payment_sequential,
    COUNT(*) FILTER (WHERE payment_type = '') AS raw_null_payment_type,
    COUNT(*) FILTER (WHERE payment_installments = '') AS raw_null_payment_installments,
    COUNT(*) FILTER (WHERE payment_value = '') AS raw_null_payment_value
FROM raw.order_payments;

-- RESULTADOS:
-- Total RAW:       103.886
-- Total Analytics: 103.886
--
-- Nenhum valor ausente identificado nos cinco campos
-- analisados em ambas as camadas.
--
-- CONCLUSAO:
-- Nenhuma divergencia de completude identificada.

-- ============================================================
-- 05. COMPLETUDE - ORDER_REVIEWS
-- ============================================================

-- 05.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- das order_reviews.

SELECT * FROM analytics.order_reviews;

SELECT
    COUNT(*) AS total_order_reviews,
    COUNT(*) FILTER (WHERE review_id IS NULL) AS null_review_id,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE review_score IS NULL) AS null_review_score,
    COUNT(*) FILTER (WHERE review_comment_title = '') AS null_review_comment_title,
    COUNT(*) FILTER (WHERE review_comment_message = '') AS null_review_comment_message,
    COUNT(*) FILTER (WHERE review_creation_date IS NULL) AS null_review_creation_date,
    COUNT(*) FILTER (WHERE review_answer_timestamp IS NULL) AS null_review_answer_timestamp
FROM analytics.order_reviews;

-- RESULTADOS VALIDADOS:
-- total order_reviews:		99224
-- review_id:            		0
-- order_id:           			0
-- review_score:      			0
-- review_comment_title:        0
-- review_comment_message:      0
-- review_creation_date:        0
-- review_answer_timestamp:     0


-- 05.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_raw_order_reviews,
    COUNT(*) FILTER (WHERE review_id ='') AS raw_null_review_id,
    COUNT(*) FILTER (WHERE order_id = '') AS raw_null_order_id,
    COUNT(*) FILTER (WHERE review_score = '') AS raw_null_review_score,
    COUNT(*) FILTER (WHERE review_comment_title = '') AS raw_null_review_comment_title,
    COUNT(*) FILTER (WHERE review_comment_message = '') AS raw_null_review_comment_message,
    COUNT(*) FILTER (WHERE review_creation_date = '') AS raw_null_review_creation_date,
    COUNT(*) FILTER (WHERE review_answer_timestamp = '') AS raw_null_review_answer_timestamp
FROM raw.order_reviews;

-- RESULTADOS:
-- Total RAW:       99.224
-- Total Analytics: 99.224
--
-- Campos com strings vazias em ambas as camadas:
-- review_comment_title:   87.656
-- review_comment_message: 58.247
--
-- Demais campos:
-- Nenhuma ausencia identificada nas verificacoes realizadas.
--
-- OBSERVACAO:
-- Os campos de comentarios permaneceram como strings vazias
-- na Analytics, diferentemente de outros atributos tratados
-- com conversao de valores vazios para NULL.
--
-- DECISAO:
-- Manter os dados originais e documentar a diferenca de
-- padronizacao para avaliacao posterior.
--
-- STATUS: CONCLUIDO

-- ============================================================
-- 06. COMPLETUDE - CUSTOMERS
-- ============================================================

-- 06.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- das order_customers.

SELECT * FROM analytics.customers;

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS null_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS null_customer_zip_code_prefix,
    COUNT(*) FILTER (WHERE customer_city is null) AS null_customer_city,
    COUNT(*) FILTER (WHERE customer_state is null) AS null_customer_state
FROM analytics.customers;

-- RESULTADOS VALIDADOS:
-- total customers:			99441
-- customer_id:            		0
-- customer_unique_id:      	0
-- customer_zip_code_prefix:	0
-- customer_city:        		0
-- customer_state:      		0


-- 06.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE customer_id = '') AS raw_null_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id = '') AS raw_null_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix = '') AS raw_null_customer_zip_code_prefix,
    COUNT(*) FILTER (WHERE customer_city = '') AS raw_null_customer_city,
    COUNT(*) FILTER (WHERE customer_state = '') AS raw_null_customer_state
FROM raw.customers;

-- RESULTADOS:
-- Total RAW:       99.441
-- Total Analytics: 99.441
--
-- Nenhum valor ausente identificado nos cinco campos
-- analisados em ambas as camadas.
--
-- CONCLUSAO:
-- Nenhuma divergencia de completude identificada.
-- STATUS: CONCLUIDO

-- ============================================================
-- 07. COMPLETUDE - sellers
-- ============================================================

-- 07.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- das sellers.

SELECT * FROM analytics.sellers;

SELECT
    COUNT(*) AS total_sellers,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS null_seller_id,
    COUNT(*) FILTER (WHERE seller_zip_code_prefix IS NULL) AS null_seller_zip_code_prefix,
    COUNT(*) FILTER (WHERE seller_city IS NULL) AS null_seller_city,
    COUNT(*) FILTER (WHERE seller_state is null) AS null_seller_state
FROM analytics.sellers;

-- RESULTADOS VALIDADOS:
-- total sellers:			3095
-- seller_id:            	   0
-- seller_zip_code_prefix:     0
-- seller_city:				   0
-- seller_state:        	   0



-- 07.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_sellers,
    COUNT(*) FILTER (WHERE seller_id = '') AS raw_null_seller_id,
    COUNT(*) FILTER (WHERE seller_zip_code_prefix = '') AS raw_null_seller_zip_code_prefix,
    COUNT(*) FILTER (WHERE seller_city = '') AS raw_null_seller_city,
    COUNT(*) FILTER (WHERE seller_state = '') AS raw_null_seller_state
FROM raw.sellers;

-- RESULTADOS:
-- Total RAW:       3.095
-- Total Analytics: 3.095
--
-- Nenhum valor ausente identificado nos quatro campos
-- analisados em ambas as camadas.
--
-- CONCLUSAO:
-- Nenhuma divergencia de completude identificada.
-- STATUS: CONCLUIDO

-- ============================================================
-- 08. COMPLETUDE - geolocation
-- ============================================================

-- 08.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- das geolocation.

SELECT * FROM analytics.geolocation;

SELECT
    COUNT(*) AS total_geolocation,
    COUNT(*) FILTER (WHERE geolocation_zip_code_prefix IS NULL) AS null_geolocation_zip_code_prefix,
    COUNT(*) FILTER (WHERE geolocation_lat IS NULL) AS null_geolocation_lat,
    COUNT(*) FILTER (WHERE geolocation_lng IS NULL) AS null_geolocation_lng,
    COUNT(*) FILTER (WHERE geolocation_city is null) AS null_geolocation_city,
    COUNT(*) FILTER (WHERE geolocation_state is null) AS null_geolocation_state
FROM analytics.geolocation;

-- RESULTADOS VALIDADOS:
-- total geolocation:				738332
-- geolocation_zip_code_prefix:	   		 0
-- geolocation_lat:     				 0
-- geolocation_lng:				   		 0
-- geolocation_city:        	   		 0
-- geolocation_state:        	   		 0



-- 08.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_geolocation,
    COUNT(*) FILTER (WHERE geolocation_zip_code_prefix = '') AS raw_null_geolocation_zip_code_prefix,
    COUNT(*) FILTER (WHERE geolocation_lat = '') AS raw_null_geolocation_lat,
    COUNT(*) FILTER (WHERE geolocation_lng = '') AS raw_null_geolocation_lng,
    COUNT(*) FILTER (WHERE geolocation_city = '') AS raw_null_geolocation_city,
    COUNT(*) FILTER (WHERE geolocation_state = '') AS raw_null_geolocation_state
FROM raw.geolocation;

-- RESULTADOS:
-- Total RAW:       1.000.163
-- Total Analytics:   738.332
-- Diferenca:         261.831
--
-- Nenhum valor ausente identificado nos cinco atributos
-- analisados em ambas as camadas.
--
-- DECISOES DE MODELAGEM:
-- 1. Criacao de geolocation_id como chave primaria artificial.
-- 2. Deduplicacao por SELECT DISTINCT considerando os cinco
--    atributos da origem, com conversao das coordenadas.
--
-- A diferenca de registros foi documentada na reconciliacao
-- RAW x Analytics.
--
-- CONCLUSAO:
-- Nenhuma divergencia de completude identificada.
-- STATUS: CONCLUIDO

-- ============================================================
-- 09. COMPLETUDE - product_category_name_translation
-- ============================================================

-- 08.1. Contagem de valores NULL na Analytics
-- Objetivo:
-- Verificar a completude dos atributos descritivos e fisicos
-- das product_category_name_translation.

SELECT * FROM analytics.product_category_name_translation;

SELECT
    COUNT(*) AS total_product_category_name,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_product_category_name,
    COUNT(*) FILTER (WHERE product_category_name_english IS NULL) AS null_product_category_name_english
FROM analytics.product_category_name_translation;

-- RESULTADOS VALIDADOS:
-- total_product_category_name:		73
-- product_category_name:	   	 	 0
-- product_category_name_english:    2


-- 09.2. Contagem de campos vazios na RAW
-- Objetivo:
-- Comparar a quantidade de campos vazios da RAW com
-- a quantidade de NULL identificados na Analytics.

SELECT
    COUNT(*) AS total_raw_product_category_name,
    COUNT(*) FILTER (WHERE product_category_name = '') AS raw_null_product_category_name,
    COUNT(*) FILTER (WHERE product_category_name_english = '') AS raw_null_product_category_name_english
FROM raw.product_category_name_translation;

-- RESULTADOS:
-- Total RAW:        71
-- Total Analytics:  73
--
-- RAW:
-- Nenhuma string vazia identificada nas duas colunas.
--
-- ANALYTICS:
-- product_category_name:         0 valores NULL
-- product_category_name_english: 2 valores NULL
--
-- JUSTIFICATIVA:
-- Duas categorias existentes em products nao estavam
-- presentes na tabela original de traducoes:
--
-- pc_gamer
-- portateis_cozinha_e_preparadores_de_alimentos
--
-- Essas categorias foram adicionadas a Analytics para
-- permitir a integridade referencial com products.
--
-- As traducoes permanecem NULL por nao terem sido
-- definidas traducoes validadas.
--
-- CONCLUSAO:
-- Ausencias conhecidas e justificadas pela transformacao.
-- STATUS: CONCLUIDO
-- ============================================================
-- FIM DO SCRIPT 
-- ============================================================
