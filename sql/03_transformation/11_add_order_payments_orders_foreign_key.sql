/*
 * ETAPA: CRIAÇÃO DA CHAVE ESTRANGEIRA DE ORDER_PAYMENTS
 *
 * Objetivo:
 * Garantir a integridade referencial entre os
 * pagamentos e os pedidos.
 *
 * Tabela de origem: analytics.order_payments
 * Coluna: order_id
 *
 * Tabela referenciada: analytics.orders
 * Coluna: order_id
 *
 * Validações realizadas:
 * - 103.886 registros de pagamentos.
 * - 0 pagamentos órfãos.
 * - Chave primária de analytics.orders validada.
 */

ALTER TABLE analytics.order_payments
ADD CONSTRAINT fk_order_payments_orders
FOREIGN KEY (order_id)
REFERENCES analytics.orders (order_id);