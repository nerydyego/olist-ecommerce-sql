/*
 * ETAPA 16 - CRIAÇÃO DA CHAVE PRIMÁRIA DE PRODUCTS
 *
 * Objetivo:
 * Definir a coluna product_id como chave primária
 * da tabela analytics.products.
 *
 * Validações realizadas:
 * - Total de registros: 32.951.
 * - product_id sem valores nulos ou vazios.
 * - product_id sem identificadores duplicados.
 * - Restrição pk_products criada com sucesso.
 * - Constraint validada no information_schema.
 *
 * Resultado:
 * A tabela analytics.products possui chave primária
 * definida, garantindo unicidade e obrigatoriedade
 * dos identificadores dos produtos.
 */

ALTER TABLE analytics.products
ADD CONSTRAINT pk_products
PRIMARY KEY (product_id);

-- consulta a criação da chave primaria

select constraint_name, constraint_type 
from information_schema.table_constraints
where table_schema = 'analytics'
and table_name = 'products';