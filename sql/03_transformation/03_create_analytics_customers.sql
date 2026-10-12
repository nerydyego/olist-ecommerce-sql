/*
 * ETAPA: CRIAÇÃO DA TABELA ANALYTICS.CUSTOMERS
 *
 * Objetivo:
 * Criar a tabela analítica de clientes a partir
 * dos registros originais de raw.customers.
 *
 * Regras:
 * - Preservar todos os registros.
 * - Manter os nomes originais das colunas.
 * - Manter os cinco campos como TEXT.
 * - Não modificar os dados da camada RAW.
 *
 * Validação posterior:
 * Conferir a quantidade de registros e
 * os tipos das colunas.
 */

create table analytics.customers as 
	select 
		customer_id,
		customer_unique_id, 
		customer_zip_code_prefix,
		customer_city,
		customer_state
	from raw.customers;

select count(*) from analytics.customers;

select column_name, data_type, is_nullable
	from information_schema.columns 
	where table_schema = 'analytics' 
		and table_name = 'customers'
	order by ordinal_position ;