/*
 * ETAPA 17 - CRIAÇÃO DA CHAVE ESTRANGEIRA ORDER_ITEMS -> PRODUCTS
 *
 * Objetivo:
 * Relacionar analytics.order_items à tabela analytics.products
 * por meio da coluna product_id.
 *
 * Tabela filha: analytics.order_items
 * Tabela pai: analytics.products
 *
 * Constraint: fk_order_items_products
 *
 * Validações anteriores:
 * - analytics.products possui PK em product_id.
 * - Nenhum item de pedido possui produto inexistente.
 *
 * Resultado esperado:
 * Garantir a integridade referencial dos produtos
 * associados aos itens dos pedidos.
 */

ALTER TABLE analytics.order_items
ADD CONSTRAINT fk_order_items_products
FOREIGN KEY (product_id)
REFERENCES analytics.products(product_id);

-- consulta a criação da chave estrangeira

select constraint_name, constraint_type 
from information_schema.table_constraints
where table_schema = 'analytics'
and table_name = 'order_items';