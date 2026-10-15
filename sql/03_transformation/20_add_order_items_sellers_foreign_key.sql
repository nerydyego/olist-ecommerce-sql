/*
 * ETAPA 20 - CRIAÇÃO DA CHAVE ESTRANGEIRA ORDER_ITEMS -> SELLERS
 *
 * Objetivo:
 * Relacionar os itens dos pedidos aos vendedores
 * cadastrados na tabela analytics.sellers.
 *
 * Tabela filha: analytics.order_items
 * Tabela pai: analytics.sellers
 *
 * Coluna de relacionamento: seller_id
 * Constraint: fk_order_items_sellers
 *
 * Validações anteriores:
 * - analytics.sellers possui 3.095 registros.
 * - seller_id possui chave primária validada.
 * - Nenhum item de pedido possui vendedor inexistente.
 *
 * Resultado esperado:
 * Garantir a integridade referencial entre
 * os itens dos pedidos e seus vendedores.
 */

ALTER TABLE analytics.order_items
ADD CONSTRAINT fk_order_items_sellers
FOREIGN key (seller_id)
REFERENCES analytics.sellers(seller_id);

-- validação de criação de chave estrageira
select constraint_name, constraint_type
from information_schema.table_constraints  
where table_schema = 'analytics'
and table_name  = 'order_items';