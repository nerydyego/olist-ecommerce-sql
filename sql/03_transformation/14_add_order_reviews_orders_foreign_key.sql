/*
 * ETAPA: CRIAÇÃO DA CHAVE ESTRANGEIRA DE ORDER_REVIEWS
 *
 * Objetivo:
 * Garantir a integridade referencial entre
 * as avaliações e os pedidos.
 *
 * Tabela de origem: analytics.order_reviews
 * Coluna: order_id
 *
 * Tabela referenciada: analytics.orders
 * Coluna: order_id
 *
 * Validações realizadas:
 * - 99.224 registros.
 * - 0 avaliações órfãs.
 * - Chave primária de analytics.orders validada.
 */

ALTER TABLE analytics.order_reviews
ADD CONSTRAINT fk_order_reviews_orders
FOREIGN KEY (order_id)
REFERENCES analytics.orders(order_id);

-- Verificar as restrições de integridade da tabela order_reviews (PK e FK).
SELECT constraint_name, table_name, constraint_type
FROM information_schema.table_constraints
where table_schema = 'analytics'
and table_name = 'order_reviews';