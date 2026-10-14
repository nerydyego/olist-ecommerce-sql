/*
 * ETAPA: CRIAÇÃO DA TABELA ANALYTICS.ORDER_PAYMENTS
 *
 * Objetivo:
 * Criar a tabela analítica de pagamentos dos pedidos
 * a partir de raw.order_payments.
 *
 * Transformações:
 * - payment_sequential: TEXT para INTEGER.
 * - payment_installments: TEXT para INTEGER.
 * - payment_value: TEXT para NUMERIC(12,2).
 * - order_id e payment_type permanecem como TEXT.
 *
 * Regras:
 * - Preservar todos os registros da origem.
 * - Tratar strings vazias como NULL nas conversões.
 * - Não modificar os dados da camada RAW.
 *
 * Validação posterior:
 * - Conferir a quantidade de registros.
 * - Verificar os tipos das colunas.
 * - Validar as chaves e os relacionamentos.
 */
CREATE TABLE analytics.order_payments as
SELECT 
	order_id,
	cast(NULLIF(trim(payment_sequential), '') as integer) AS payment_sequential,
	payment_type,
	cast(NULLIF(trim(payment_installments), '') as integer) AS payment_installments,
	cast(NULLIF(trim(payment_value), '') as numeric(12,2)) AS payment_value
FROM raw.order_payments