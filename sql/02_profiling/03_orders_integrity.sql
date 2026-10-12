/*
 * VALIDAÇÃO DE INTEGRIDADE - ORDERS
 *
 * Objetivo:
 * Identificar valores duplicados na coluna order_id
 * da tabela analytics.orders.
 *
 * Regra:
 * Cada order_id deve identificar um único pedido.
 *
 * Resultado da validação:
 * Nenhum order_id duplicado encontrado.
 */

SELECT
    order_id,
    COUNT(*) AS quantidade
FROM analytics.orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

/*
 * VALIDAÇÃO DE INTEGRIDADE - IDENTIFICADORES AUSENTES
 *
 * Objetivo:
 * Verificar a existência de pedidos sem identificador (order_id)
 * na tabela analytics.orders.
 *
 * Regras de validação:
 * 1. IS NULL: identifica valores nulos.
 * 2. TRIM(): remove espaços nas extremidades do identificador.
 * 3. = '': identifica strings vazias ou contendo apenas espaços.
 * 4. OR: considera qualquer uma das condições anteriores.
 *
 * Resultado obtido:
 * 0 identificadores ausentes em 99.441 registros.
 *
 * Conclusão:
 * Todos os pedidos possuem order_id preenchido.
 */
select count(*) as ids_ausentes	
	from analytics.orders 
	where order_id is null
		or trim(order_id) = '';

/*
 * VALIDAÇÃO DE INTEGRIDADE - RESTRIÇÕES DA TABELA
 *
 * Objetivo:
 * Consultar as restrições cadastradas em analytics.orders.
 *
 * Verificação principal:
 * Confirmar a existência da chave primária pk_orders.
 *
 * Resultado esperado:
 * Restrição pk_orders do tipo PRIMARY KEY.
 */
select constraint_name, constraint_type
	from information_schema.table_constraints 
	where table_schema = 'analytics'
	and table_name = 'orders';

/*
 * VALIDAÇÃO DE INTEGRIDADE REFERENCIAL - ORDERS X CUSTOMERS
 *
 * Objetivo:
 * Identificar pedidos sem cliente correspondente.
 *
 * Regra:
 * Todo customer_id de orders deve existir em customers.
 *
 * Método:
 * Utilizar LEFT JOIN para identificar registros órfãos.
 *
 * Finalidade:
 * Avaliar a integridade dos dados antes da criação
 * da restrição FOREIGN KEY.
 */
select a.order_id ,a.customer_id
	from analytics.orders as a
	left join raw.customers as c
		on a.customer_id = c.customer_id
	where c.customer_id is null;

/*
 * VALIDAÇÃO DE CUSTOMER_ID - ANALYTICS.ORDERS
 *
 * Objetivo:
 * Identificar customer_id nulos, vazios ou
 * representados textualmente como 'null' e 'NULL'.
 *
 * Resultado:
 * - Identificadores ausentes: 0.
 *
 * Conclusão:
 * Não foram identificados valores ausentes
 * segundo os critérios desta consulta.
 */
select count(*) as customer_id_ausentes 
	from analytics.orders 
	where customer_id is null 
		or trim (customer_id) = '' 
		or customer_id in ('null','NULL'); 