/*
 * ETAPA: CRIAÇÃO DA CHAVE PRIMÁRIA DE ORDER_REVIEWS
 *
 * Objetivo:
 * Garantir a identificação única de cada registro
 * da tabela analytics.order_reviews.
 *
 * Chave primária composta:
 * - review_id
 * - order_id
 *
 * Validações realizadas:
 * - 99.224 registros.
 * - Nenhuma combinação duplicada.
 * - Nenhum identificador nulo ou vazio.
 */
ALTER TABLE analytics.order_reviews
ADD CONSTRAINT pk_order_reviews
PRIMARY KEY (review_id, order_id);

-- Verificar a chave primária
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
where table_schema = 'analytics'
and table_name = 'order_reviews';