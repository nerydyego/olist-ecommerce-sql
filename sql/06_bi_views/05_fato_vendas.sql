-- Validação de integridade entre as tabelas "se existem itens sem pedidos correspondentes?"

select 
	count(*)
from analytics.order_items oi
left join analytics.orders o 
on o.order_id = oi.order_id 
where o.order_id is null;

-- Criação view fato_vendas

create or replace view bi.fato_vendas as
select 
	o.order_id,
	oi.order_item_id,
	oi.product_id,
	oi.seller_id,
	o.customer_id,
	o.order_purchase_timestamp,
	oi.price,
	oi.freight_value
from analytics.order_items oi
inner join analytics.orders o
on o.order_id = oi.order_id
where o.order_status = 'delivered';

-- Quantidade de registros

select 
	count(*)
from bi.fato_vendas;