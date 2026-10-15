/*
 * ETAPA 19 - CRIAÇÃO DA CHAVE PRIMÁRIA DE SELLERS
 *
 * Objetivo:
 * Definir seller_id como chave primária
 * da tabela analytics.sellers.
 *
 * Validações realizadas:
 * - 3.095 registros na tabela.
 * - seller_id sem valores nulos ou vazios na origem.
 * - seller_id sem identificadores duplicados na origem.
 * - Quatro colunas preservadas como TEXT.
 *
 * Constraint: pk_sellers
 *
 * Resultado esperado:
 * Garantir unicidade e obrigatoriedade de seller_id.
 */

ALTER TABLE analytics.sellers
ADD CONSTRAINT pk_sellers
PRIMARY KEY (seller_id);

-- validação de criação de chave primaria
select constraint_name, constraint_type
from information_schema.table_constraints  
where table_schema = 'analytics'
and table_name  = 'sellers';