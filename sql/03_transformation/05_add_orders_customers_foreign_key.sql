/*
 * ETAPA: INTEGRIDADE REFERENCIAL - ORDERS X CUSTOMERS
 *
 * Objetivo:
 * Estabelecer o relacionamento entre pedidos e clientes
 * por meio da coluna customer_id.
 *
 * Tabela de origem: analytics.orders.
 * Tabela referenciada: analytics.customers.
 *
 * Validações prévias:
 * - Pedidos sem cliente correspondente: 0.
 * - customer_id ausentes em orders: 0.
 * - PRIMARY KEY pk_customers criada e validada.
 *
 * Regra:
 * Todo customer_id não nulo em orders deve existir
 * em analytics.customers.
 */

alter table analytics.orders
add constraint fk_orders_customers
foreign key (customer_id)
REFERENCES analytics.customers (customer_id);

-- Criação de chave estrangeira orders
select constraint_name, constraint_type
	from information_schema.table_constraints
	where table_schema = 'analytics'
		and table_name = 'orders';
	