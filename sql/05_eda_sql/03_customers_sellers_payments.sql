-- ============================================================
-- Q12 - Quantidade de clientes únicos
-- Objetivo: identificar quantos clientes distintos realizaram
-- compras com status delivered.
-- ============================================================

select * from analytics.orders;
select * from analytics.customers;

select 
		count(distinct c.customer_unique_id) as clientes_unicos
from analytics.orders o
inner join analytics.customers c
on o.customer_id = c.customer_id 
where o.order_status = 'delivered';

--=============================================================
--Q13 Quantos clientes únicos realizaram mais de um pedido 
--entregue?
--=============================================================
select 
		c.customer_unique_id as cliente,
		count(*) as quantidade_pedidos
from analytics.orders o
inner join analytics.customers c
on o.customer_id = c.customer_id 
where o.order_status = 'delivered'
group by c.customer_unique_id
having count(*) > 1;

--=============================================================
--Q14 Qual é a distribuição dos clientes por estado (UF)?
--=============================================================

select * from analytics.customers;
select 
		c.customer_state as estados,
		count(distinct c.customer_unique_id) as clientes_unicos
from analytics.orders o
inner join analytics.customers c
on o.customer_id = c.customer_id 
where o.order_status = 'delivered'
group by c.customer_state
order by clientes_unicos desc;

--=============================================================
--Q15 Qual é a distribuição dos clientes por estado (UF)?
--=============================================================
select * from analytics.customers;
select * from analytics.sellers;

select 
		seller_state as estados,
		count(distinct seller_id) as quantidade_vendedor
from analytics.sellers
group by seller_state
order by quantidade_vendedor desc;

--=============================================================
--Q16 Quais são as formas de pagamento mais utilizadas nos 
--pedidos entregues?
--=============================================================

select * from analytics.order_payments; 
select * from analytics.orders;

select 
		p.payment_type as tipo_pagamento,
		count(distinct o.order_id) as quantidade_pedidos
from analytics.orders o
inner join analytics.order_payments p
on o.order_id = p.order_id 
where o.order_status = 'delivered'
group by p.payment_type
order by quantidade_pedidos desc;

--=============================================================
--Q17 Qual é o valor total dos pagamentos associados aos 
--pedidos entregues, agrupado por modalidade?
--=============================================================

select * from analytics.order_payments; 
select * from analytics.orders;

select 
		p.payment_type as modalidade,
		sum(p.payment_value) as total_pagamentos
from analytics.order_payments p
inner join analytics.orders o
on o.order_id = p.order_id
where o.order_status = 'delivered'
group by p.payment_type
order by total_pagamentos desc;

--=============================================================
--Q18 Qual é o tempo médio, em dias, entre a compra e a entrega 
--efetiva dos pedidos?
--=============================================================

select 
	 	round(
	 		avg(
	 			extract(epoch from o.order_delivered_customer_date - o.order_purchase_timestamp) / 86400
	 		), 2	
	 	) as tempo_medio
from analytics.orders o 
where o.order_status = 'delivered' 
and order_delivered_customer_date is not null;

--============================================================
--Q19 Quantos pedidos foram entregues após a data estimada de 
--entrega?
--============================================================

select * from analytics.orders;

select 
	count(*) pedidos_fora_de_entrega
from analytics.orders o
where o.order_status = 'delivered'
and o.order_estimated_delivery_date is not null
and o.order_delivered_customer_date is not null
and o.order_delivered_customer_date > o.order_estimated_delivery_date; 

--============================================================
--Q20 Qual é a distribuição das avaliações dos clientes para
-- os pedidos entregues?
--============================================================

select * from analytics.order_reviews t;
select * from analytics.orders o;

select 
	t.review_score as notas_avaliacao,
	count(*) as quantidade
from analytics.orders o
inner join analytics.order_reviews t 
on o.order_id = t.order_id
where o.order_status = 'delivered'
group by t.review_score 
order by notas_avaliacao;