-- ============================================================
-- Q06 - Ticket médio dos pedidos elegíveis
-- Objetivo: calcular o valor médio por pedido entregue,
-- considerando os valores dos itens e do frete.
-- ============================================================

SELECT * FROM analytics.order_items;
SELECT * FROM analytics.products;

select 
	count(*) quantidade_items,
	count(distinct i.order_id) quantidade_pedidos
from analytics.order_items i
inner join analytics.orders o 
on i.order_id = o.order_id
where o.order_status = 'delivered' 

--ticket medio
select 
	sum(i.price) + sum(i.freight_value) valor_total,
	count(distinct o.order_id) Total_pedidos,
	round((sum(i.price) + sum(i.freight_value)) / (count(distinct o.order_id)), 2) as ticket_medio
		from analytics.order_items i
inner join analytics.orders o
on o.order_id = i.order_id 
where o.order_status = 'delivered'
--
--valor_total|total_pedidos|ticket_medio|
-------------+-------------+------------+
--15419773.75|        96478|      159.83|

-- ============================================================
-- Q07 - Evolução mensal do valor bruto dos produtos
-- Objetivo: analisar o valor dos produtos vendidos por mês,
-- considerando exclusivamente pedidos entregues.
-- ============================================================

select 
	date_trunc('month', o.order_purchase_timestamp) mes,
	sum(i.price) valor_vendas_produtos	
from analytics.order_items i 
inner join analytics.orders o
on i.order_id = o.order_id
where o.order_status = 'delivered'
group by date_trunc('month', o.order_purchase_timestamp)
order by mes;
--limit 5;
 
mes                    |valor_vendas_produtos|
-----------------------+---------------------+
2016-09-01 00:00:00.000|               134.97|
2016-10-01 00:00:00.000|             40325.11|
2016-12-01 00:00:00.000|                10.90|
2017-01-01 00:00:00.000|            111798.36|
2017-02-01 00:00:00.000|            234223.40|

select 
	sum(i.price) valor_vendas_produtos	
from analytics.order_items i 
inner join analytics.orders o
on i.order_id = o.order_id
where o.order_status = 'delivered';

-- ============================================================
-- Q08 - Valor bruto dos produtos por estado do cliente
-- Objetivo: identificar a distribuição geográfica das vendas
-- de produtos em pedidos entregues, sem incluir frete.
-- ============================================================

select * from analytics.orders; 
select * from analytics.order_items; 
select * from analytics.customers;

select 
	c.customer_state as estados,
	sum(i.price) valor_produto
from analytics.orders o
inner join analytics.order_items i
on o.order_id = i.order_id 
inner join  analytics.customers c 
on o.customer_id = c.customer_id 
where o.order_status = 'delivered'
group by c.customer_state
order by valor_produto desc;

-- ============================================================
-- Q09 - Valor bruto dos produtos por categoria
-- Objetivo: identificar as categorias com maior valor bruto
-- de produtos vendidos em pedidos entregues.
-- ============================================================
select * from analytics.orders;
select * from analytics.order_items;
select * from analytics.products;

select 
		p.product_category_name as categorias,
		sum(i.price) preco
from analytics.orders o  
inner join analytics.order_items i
on o.order_id = i.order_id 
inner join analytics.products p 
on i.product_id = p.product_id 
where o.order_status = 'delivered'
group by p.product_category_name
order by preco desc;

-- ============================================================
-- Q10 - Produtos com maior valor bruto de vendas
-- Objetivo: identificar os 10 produtos com maior valor
-- bruto vendido em pedidos entregues, sem incluir frete.
-- ============================================================
select 
		i.product_id as produto,
		sum(i.price) preco
from analytics.orders o  
inner join analytics.order_items i
on o.order_id = i.order_id 
where o.order_status = 'delivered'
group by i.product_id 
order by preco desc
limit 10;

-- ============================================================
-- Q11 - Participação percentual das categorias nas vendas
-- Objetivo: calcular a participação de cada categoria
-- no valor bruto total dos produtos vendidos.
-- ============================================================


select * from analytics.products;
select * from analytics.orders;
select * from analytics.order_items;

select 
	p.product_category_name as categoria,
	sum(i.price) total_categoria,
	round(sum(i.price) * 100.0 / sum(sum(i.price)) over(),2) as participacao_pct
from analytics.orders o
inner join analytics.order_items i
on o.order_id = i.order_id 
inner join analytics.products p 
on i.product_id = p.product_id 
where o.order_status = 'delivered'
group by p.product_category_name
order by total_categoria desc;

	