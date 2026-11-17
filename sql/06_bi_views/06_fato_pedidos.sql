-- Verificação de Unicidade

SELECT 
	count(*)
FROM analytics.orders
GROUP BY order_id
HAVING count(*) > 1;

-- Criação da view

create or replace view bi.fato_pedidos as
select 
	order_id,
	customer_id,	
	order_status,
	order_purchase_timestamp,
	order_approved_at,
	order_delivered_carrier_date,
	order_delivered_customer_date,
	order_estimated_delivery_date
from analytics.orders;

-- Verificação de quantidade de registros

select 
	count(*)
from bi.fato_pedidos;