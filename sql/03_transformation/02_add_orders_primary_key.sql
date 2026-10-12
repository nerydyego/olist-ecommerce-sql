/*
 * ETAPA: DEFINIÇÃO DA CHAVE PRIMÁRIA - ORDERS
 *
 * Objetivo:
 * Definir order_id como chave primária de analytics.orders.
 *
 * Validações realizadas:
 * - 99.441 registros analisados.
 * - Nenhum identificador duplicado.
 * - Nenhum identificador nulo ou vazio.
 *
 * Regra:
 * Garantir unicidade e não nulidade de order_id.
 *
 * Pré-requisito:
 * A tabela analytics.orders deve existir.
 */
alter table analytics.orders 
	add constraint pk_orders
	primary key (order_id);

