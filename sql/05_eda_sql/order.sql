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

select 
	order_status,
	count(*) quantidade_pedidos,
	sum(count(*)) over() total_geral
from analytics.orders
group by order_status;

select 
	count(order_id) total_registros,
	count(distinct order_id) pedidos_distintos,
	count(order_id) - count(distinct order_id) pedidos_duplicados
from analytics.orders;