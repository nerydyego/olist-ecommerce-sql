-- ============================================================
-- PROJETO: Olist Brazilian E-Commerce
-- ETAPA: 05 - Análise Exploratória de Dados (EDA SQL)
-- ARQUIVO: 01_orders.sql
-- BANCO: olist_ecommerce
-- SCHEMA: analytics
--
-- OBJETIVO:
-- Analisar a distribuição, evolução temporal e localização
-- geográfica dos pedidos realizados na plataforma Olist.
--
-- ANÁLISES:
-- Q01 - Distribuição dos pedidos por status
-- Q02 - Evolução mensal e anual dos pedidos
-- Q03 - Meses com maior e menor volume de pedidos
-- Q04 - Distribuição dos pedidos por UF
-- ============================================================

-- Q01 - Distribuição dos pedidos por status
-- Objetivo: identificar a quantidade e a participação
-- percentual de cada status no total de pedidos.
-- Granularidade esperada: um registro por pedido.

select * from analytics.orders;

--Quantos pedidos existem para cada status na plataforma Olist?
select 
		order_status, 
		count(*) quantidade_pedidos,
		round(count(*) * 100.0 / (select count(*) from analytics.orders) ,2)  percentual
from analytics.orders 
group by order_status
order by quantidade_pedidos desc;

--Como evoluiu o número de pedidos elegíveis por ano e mês?
select 
	date_trunc('month', order_purchase_timestamp) as ano_mes,
	count(*) quantidade
from analytics.orders
where order_status = 'delivered'
group by date_trunc('month', order_purchase_timestamp)
order by ano_mes;
--ano com percentual
select 
	date_trunc('year', order_purchase_timestamp) as ano,
	count(*) quantidade,
	round(count(*) * 100.0 / (select count(*) from analytics.orders where order_status = 'delivered') ,2) percentual
from analytics.orders
where order_status = 'delivered'
group by date_trunc('year', order_purchase_timestamp)
order by ano;

-- ============================================================
-- Q03 - Meses com maior e menor volume de pedidos elegíveis
-- Objetivo: identificar os períodos de maior e menor volume
-- de pedidos entregues, considerando a cobertura temporal.
-- ============================================================
--Maiores
select 
	date_trunc('month', order_purchase_timestamp) mes,
	count(*) quantidade
from analytics.orders o 
where order_status = 'delivered'
and o.order_purchase_timestamp >= '2017-01-01'
and o.order_purchase_timestamp < '2018-08-31'
group by date_trunc('month', order_purchase_timestamp)
order by quantidade desc
limit 3;
--Menores
select 
	date_trunc('month', order_purchase_timestamp) mes,
	count(*) quantidade
from analytics.orders o 
where order_status = 'delivered'
and o.order_purchase_timestamp >= '2017-01-01'
and o.order_purchase_timestamp < '2018-08-31'
group by date_trunc('month', order_purchase_timestamp)
order by quantidade
limit 3;

-- ============================================================
-- Q04 - Distribuição geográfica dos pedidos elegíveis
-- Objetivo: identificar a quantidade de pedidos entregues
-- por estado do cliente.
-- ============================================================
select * from analytics.customers;
select * from analytics.orders;
select 
	c.customer_state as estado,
	count(*) quantidade
from analytics.orders o
inner join analytics.customers c
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
group by c.customer_state
order by quantidade desc;