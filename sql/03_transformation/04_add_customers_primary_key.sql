/*
 * ETAPA: DEFINIÇÃO DA CHAVE PRIMÁRIA - ANALYTICS.CUSTOMERS
 *
 * Objetivo:
 * Definir customer_id como chave primária da tabela
 * analytics.customers.
 *
 * Validações prévias:
 * - Total de registros: 99.441.
 * - Identificadores distintos: 99.441.
 * - Identificadores ausentes: 0.
 *
 * Regra de integridade:
 * Impedir valores NULL e identificadores duplicados
 * na coluna customer_id.
 *
 * Pré-requisito:
 * A tabela analytics.customers deve existir.
 */

ALTER TABLE analytics.customers
ADD CONSTRAINT pk_customers
PRIMARY KEY (customer_id);

select constraint_name, constraint_type
	from information_schema.table_constraints
	where table_schema = 'analytics'
	and table_name = 'customers';

alter table analytics.orders
add constraint fk.customers
foreign key 