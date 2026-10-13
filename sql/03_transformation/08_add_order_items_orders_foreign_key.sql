/*
 * ETAPA: CRIAÇÃO DA CHAVE ESTRANGEIRA DE ORDER_ITEMS
 *
 * Objetivo:
 * Estabelecer o relacionamento entre os itens
 * dos pedidos e a tabela de pedidos.
 *
 * Tabela de origem: analytics.order_items
 * Coluna: order_id
 *
 * Tabela referenciada: analytics.orders
 * Coluna: order_id
 *
 * Validações realizadas:
 * - 112.650 registros em analytics.order_items.
 * - 0 registros órfãos.
 * - Chave primária de analytics.orders validada.
 */
ALTER TABLE analytics.order_items
ADD CONSTRAINT fk_order_items_orders
FOREIGN KEY (order_id)
REFERENCES analytics.orders(order_id);

SELECT 
	constraint_name,
	constraint_type
from information_schema.table_constraints
WHERE
	table_schema = 'analytics'
	AND table_name = 'order_items';