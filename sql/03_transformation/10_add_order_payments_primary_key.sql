/*
 * ETAPA: CRIAÇÃO DA CHAVE PRIMÁRIA DE ANALYTICS.ORDER_PAYMENTS
 *
 * Objetivo:
 * Garantir a identificação única de cada pagamento.
 *
 * Chave primária composta:
 * - order_id
 * - payment_sequential
 *
 * Validações realizadas:
 * - 103.886 registros.
 * - Nenhuma combinação duplicada.
 * - Nenhum valor NULL nas colunas da chave.
 */
ALTER TABLE analytics.order_payments
ADD CONSTRAINT PK_ORDER_PAYMENTS
PRIMARY KEY (order_id, payment_sequential);