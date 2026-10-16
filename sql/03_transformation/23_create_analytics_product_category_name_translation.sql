-- ============================================================
-- ETAPA 23: CRIAÇÃO DA TABELA DE TRADUÇÃO DAS CATEGORIAS
-- Objetivo: criar a tabela de categorias na camada ANALYTICS
-- a partir dos registros existentes na camada RAW.
--
-- As duas colunas permanecem como TEXT.
-- A chave primária será adicionada na etapa seguinte.
-- ============================================================

CREATE TABLE analytics.product_category_name_translation AS
SELECT
    product_category_name,
    product_category_name_english
FROM raw.product_category_name_translation;