/*
 * ETAPA: TRANSFORMAÇÃO DA TABELA ORDER_REVIEWS
 *
 * Objetivo:
 * Criar analytics.order_reviews a partir de raw.order_reviews,
 * aplicando os tipos de dados definidos.
 *
 * Validações realizadas:
 * - 99.224 registros na origem.
 * - review_score validado para SMALLINT (notas de 1 a 5).
 * - Datas validadas para TIMESTAMP.
 * - Chave composta (review_id, order_id) sem duplicidades.
 * - Identificadores não nulos e não vazios.
 * - 0 avaliações órfãs.
 *
 * Observação:
 * Preservar os dados originais na camada raw.
 */
CREATE TABLE analytics.order_reviews AS 
SELECT 
	review_id,
	order_id,
	CAST(NULLIF(trim(review_score), '') AS SMALLINT) AS review_score,
	review_comment_title,
	review_comment_message,
	CAST(NULLIF(trim(review_creation_date), '') AS TIMESTAMP) AS review_creation_date,
	CAST(NULLIF(trim(review_answer_timestamp), '') AS TIMESTAMP) AS review_answer_timestamp
FROM raw.order_reviews;

-- Quantidade de registros na tabela
select count(*) from analytics.order_reviews;

--Tipos de colunas na converção de raw para analytics
select column_name, data_type
from information_schema.columns
where table_schema = 'analytics'
and table_name = 'order_reviews'
order by ordinal_position;