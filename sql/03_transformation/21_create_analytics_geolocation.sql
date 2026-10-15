-- ============================================================
-- ETAPA 21: CRIAÇÃO DA TABELA ANALYTICS.GEOLOCATION
-- Objetivo: criar a estrutura tipada da tabela de geolocalização,
-- utilizando uma chave primária artificial (surrogate key).
-- A carga dos registros distintos será realizada posteriormente.
-- Origem dos dados: raw.geolocation.
-- ============================================================

CREATE TABLE analytics.geolocation( 
	geolocation_id	BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY key,
	geolocation_zip_code_prefix text,
	geolocation_lat NUMERIC,
	geolocation_lng NUMERIC,
	geolocation_city text,
 	geolocation_state text);
 FROM raw.geolocation;

-- validação
select * from information_schema.columns;
select column_name, data_type, is_nullable, is_identity 
from information_schema.columns 
where table_schema = 'analytics'
and table_name = 'geolocation'
order by ordinal_position;