/*
 * -0 Data Profiling
 */

-- Exploração inicial: visualizar 10 registros da tabela raw.orders.
SELECT * FROM raw.orders limit 10;
-- Verificar a quantidade de pedidos sem data de entrega ao cliente.
select count(*) as total_nulos_entrega from raw.orders where order_delivered_customer_date is null;
-- Identificar pedidos com data de entrega ausente,
-- considerando NULL, strings vazias, espaços e textos 'NULL'/'null'.
select count(*) as total_vazios_entrega from raw.orders where order_delivered_customer_date is null 
or Trim(order_delivered_customer_date) = '' or order_delivered_customer_date in ('NULL', 'null')
or ;
