/*
 * ETAPA 18 - TRANSFORMAÇÃO DA TABELA SELLERS
 *
 * Objetivo:
 * Criar analytics.sellers a partir de raw.sellers,
 * preservando as quatro colunas como TEXT.
 *
 * Validações realizadas:
 * - Total de registros na origem: 3.095.
 * - seller_id único e sem valores nulos ou vazios.
 * - Nenhum item de pedido possui vendedor inexistente.
 *
 * Observações:
 * - Preservar os dados originais na camada raw.
 * - Manter seller_zip_code_prefix como TEXT.
 * - A chave primária será criada em etapa posterior.
 */

CREATE TABLE analytics.sellers AS
SELECT 
	seller_id,
	seller_zip_code_prefix,
	seller_city,
	seller_state
from raw.sellers;

-- validação de transformação 
select * from analytics.sellers limit 5;

-- validação de transformação - quantidade de registros
select count(*) from analytics.sellers;

-- validação de transformação - tipo de dados
select column_name, data_type
from information_schema.columns 
where table_schema = 'analytics'
and table_name = 'sellers'
order by ordinal_position;