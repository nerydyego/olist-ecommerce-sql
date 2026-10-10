/*
 * -0 Data Profiling
 */

-- Exploração inicial: visualizar 10 registros da tabela raw.orders.
SELECT * FROM raw.orders limit 10;
-- Verificar a quantidade de pedidos sem data de entrega ao cliente.
select count(*) as total_nulos_entrega from raw.orders where order_delivered_customer_date is null;