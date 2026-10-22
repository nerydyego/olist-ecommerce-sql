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
--Qual é a distribuição dos clientes por estado (UF)?
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
--Qual é a distribuição dos clientes por estado (UF)?
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
--Quais são as formas de pagamento mais utilizadas nos pedidos
--entregues?
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

