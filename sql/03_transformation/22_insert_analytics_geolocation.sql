-- ============================================================
-- ETAPA 22: CARGA DA TABELA ANALYTICS.GEOLOCATION
-- Objetivo: inserir as combinações distintas de geolocalização
-- provenientes da camada RAW, convertendo latitude e longitude
-- para NUMERIC e preservando os demais campos como TEXT.
-- A chave geolocation_id será gerada automaticamente.
-- ============================================================

INSERT INTO analytics.geolocation (
	geolocation_zip_code_prefix,
	geolocation_lat,
	geolocation_lng,
	geolocation_city,
 	geolocation_state)
SELECT DISTINCT
	geolocation_zip_code_prefix,
	CAST(geolocation_lat AS NUMERIC) AS geolocation_lat,
	CAST(geolocation_lng AS NUMERIC) AS geolocation_lng,
	geolocation_city,
 	geolocation_state
FROM raw.geolocation;

--validação
select count(*) from analytics.geolocation;

-- Verificação da integridade dos dados
select 
	count(*) as total_registros,
	count(geolocation_id) as ids_preenchido,
	count(distinct geolocation_id) as ids_distintos
from analytics.geolocation;


--confirmação de chave primeria
select constraint_name, constraint_type
from information_schema.table_constraints
where table_schema = 'analytics'
and table_name = 'geolocation';