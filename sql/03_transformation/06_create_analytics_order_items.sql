/*
 * ETAPA: CRIAÇÃO DA TABELA ANALYTICS.ORDER_ITEMS
 *
 * Objetivo:
 * Criar a tabela analítica de itens dos pedidos
 * a partir de raw.order_items.
 *
 * Transformações:
 * - order_item_id: TEXT para INTEGER.
 * - shipping_limit_date: TEXT para TIMESTAMP.
 * - price: TEXT para NUMERIC(12,2).
 * - freight_value: TEXT para NUMERIC(12,2).
 * - Demais colunas permanecem como TEXT.
 *
 * Regras:
 * - Preservar todos os registros da origem.
 * - Tratar strings vazias como NULL nas conversões.
 * - Não modificar os dados da camada RAW.
 *
 * Validação posterior:
 * Conferir quantidade de registros e tipos.
 * Verificar integridade dos identificadores.
 */

CREATE TABLE analytics.order_items AS
	SELECT 
		order_id,
		CAST(NULLIF(trim (order_item_id), '') AS integer) as order_item_id,
		product_id,
		seller_id,
		CAST(NULLIF(trim(shipping_limit_date), '') AS timestamp) as shipping_limit_date,
		CAST(NULLIF(trim(price), '') AS NUMERIC (12,2)) as price,
		CAST(NULLIF(trim(freight_value), '') AS NUMERIC (12,2)) as freight_value
	FROM raw.order_items
	
select * from analytics.order_items limit 5;

select count(*) as total_registros_order_items from analytics.order_items;

select 
	column_name,
	data_type
from information_schema."columns"
where table_schema = 'analytics'
and table_name = 'order_items'
order by ordinal_position;

select 
	order_id,
	order_item_id,
	count(*) as quantidade
	from analytics.order_items 
	group by order_id, order_item_id
	having count(*) > 1;

select count(*) as registros_com_nulos
	from analytics.order_items 
	where order_id is null
	or order_item_id is null; 

