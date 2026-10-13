/*
 * ETAPA: CRIAÇÃO DA CHAVE PRIMÁRIA DE ANALYTICS.ORDER_ITEMS
 *
 * Objetivo:
 * Garantir a identificação única de cada item de pedido.
 *
 * Chave primária composta:
 * - order_id
 * - order_item_id
 *
 * Validações realizadas:
 * - 112.650 registros.
 * - Nenhuma combinação duplicada.
 * - Nenhum valor NULL nas colunas da chave.
 */

ALTER TABLE analytics.order_items
ADD CONSTRAINT pk_order_items
PRIMARY KEY (order_id, order_item_id); 

select 
	constraint_name, 
	constraint_type
from information_schema.table_constraints
where 
	table_schema = 'analytics'
	and table_name = 'order_items';

-- registro orfãos

select count(*) as order_items_orfaos
from analytics.order_items oi
left join analytics.orders o
	on oi.order_id = o.order_id 
where o.order_id is null;
	

