/*
Conclusão preliminar:
- customer_id possui 99.441 valores distintos em 99.441 registros.
- customer_unique_id possui 96.096 valores distintos.
- Um mesmo customer_unique_id pode estar associado a vários customer_id.
- As repetições de customer_unique_id não devem ser tratadas
  automaticamente como duplicidades.
- A relação deverá ser validada posteriormente com raw.orders.
*/

SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL)
        AS customer_id_null,

    COUNT(*) FILTER (WHERE customer_unique_id IS NULL)
        AS customer_unique_id_null,

    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL)
        AS customer_zip_code_prefix_null,

    COUNT(*) FILTER (WHERE customer_city IS NULL)
        AS customer_city_null,

    COUNT(*) FILTER (WHERE customer_state IS NULL)
        AS customer_state_null
FROM raw.customers;

-- =========================================================
-- Verificação de valores vazios
-- =========================================================

SELECT
    COUNT(*) FILTER (
        WHERE TRIM(customer_id) = ''
    ) AS customer_id_vazio,

    COUNT(*) FILTER (
        WHERE TRIM(customer_unique_id) = ''
    ) AS customer_unique_id_vazio,

    COUNT(*) FILTER (
        WHERE TRIM(customer_zip_code_prefix) = ''
    ) AS customer_zip_code_prefix_vazio,

    COUNT(*) FILTER (
        WHERE TRIM(customer_city) = ''
    ) AS customer_city_vazio,
    
    COUNT(*) FILTER (
        WHERE TRIM(customer_state) = ''
    ) AS customer_state_vazio

FROM raw.customers;
    
-- =========================================================
-- Verificação de representações textuais de valores ausentes
-- =========================================================

SELECT
    COUNT(*) FILTER (
        WHERE UPPER(TRIM(customer_id))
            IN ('N/A', 'NA', 'NULL', 'NONE', 'NAN')
    ) AS customer_id_ausente_texto,

    COUNT(*) FILTER (
        WHERE UPPER(TRIM(customer_unique_id))
            IN ('N/A', 'NA', 'NULL', 'NONE', 'NAN')
    ) AS customer_unique_id_ausente_texto,

    COUNT(*) FILTER (
        WHERE UPPER(TRIM(customer_zip_code_prefix))
            IN ('N/A', 'NA', 'NULL', 'NONE', 'NAN')
    ) AS customer_zip_code_prefix_ausente_texto,

    COUNT(*) FILTER (
        WHERE UPPER(TRIM(customer_city))
            IN ('N/A', 'NA', 'NULL', 'NONE', 'NAN')
    ) AS customer_city_ausente_texto,

    COUNT(*) FILTER (
        WHERE UPPER(TRIM(customer_state))
            IN ('N/A', 'NA', 'NULL', 'NONE', 'NAN')
    ) AS customer_state_ausente_texto

FROM raw.customers;

-- =========================================================
-- Verificação de registros completamente duplicados
-- =========================================================

SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    COUNT(*) AS quantidade
FROM raw.customers
GROUP BY
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
HAVING COUNT(*) > 1
ORDER BY quantidade DESC;

/*
Conclusão:
- Não foram encontrados registros completamente duplicados
  em raw.customers.
- A repetição de customer_unique_id observada anteriormente
  não representa duplicação completa de registros.
*/

-- =========================================================
-- Análise do domínio de customer_state
-- =========================================================

SELECT
    customer_state,
    COUNT(*) AS quantidade
FROM raw.customers
GROUP BY customer_state
ORDER BY customer_state;

-- =========================================================
-- Validação do domínio de customer_state
-- =========================================================

SELECT
    customer_state,
    COUNT(*) AS quantidade
FROM raw.customers
WHERE customer_state NOT IN (
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF',
    'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
    'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS',
    'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
)
GROUP BY customer_state
ORDER BY customer_state;

/*
Conclusão:
- Foram encontrados 27 valores distintos em customer_state.
- Todos correspondem a UFs brasileiras válidas.
- Não foram encontrados valores fora do domínio esperado.
*/

-- =========================================================
-- Validação do formato de customer_zip_code_prefix
-- =========================================================

SELECT
    customer_zip_code_prefix,
    COUNT(*) AS quantidade
FROM raw.customers
WHERE customer_zip_code_prefix !~ '^[0-9]{5}$'
GROUP BY customer_zip_code_prefix
ORDER BY customer_zip_code_prefix;

/*
Conclusão:
- Não foram encontrados valores de customer_zip_code_prefix
  fora do formato esperado.
- Todos os valores possuem exatamente 5 caracteres numéricos.
- Esta validação verifica apenas o formato do prefixo.
- A existência/consistência geográfica será validada posteriormente
  utilizando os dados de geolocalização.
*/

-- =========================================================
-- Análise de cardinalidade de customer_city
-- =========================================================

SELECT
    COUNT(DISTINCT customer_city) AS cidades_distintas
FROM raw.customers;

-- =========================================================
-- Verificação de padronização de customer_city
-- =========================================================

SELECT
    COUNT(DISTINCT customer_city) AS cidades_originais,
    COUNT(DISTINCT LOWER(TRIM(customer_city))) AS cidades_normalizadas
FROM raw.customers;

/*
Conclusão:
- customer_city possui 4.119 valores distintos.
- Após normalização básica com LOWER() e TRIM(),
  permanecem 4.119 valores distintos.
- Não foram identificadas diferenças de cardinalidade
  provocadas apenas por capitalização ou espaços nas extremidades.
*/

-- =========================================================
-- Verificação de cidades associadas a múltiplas UFs
-- =========================================================

SELECT
    customer_city,
    COUNT(DISTINCT customer_state) AS quantidade_estados
FROM raw.customers
GROUP BY customer_city
HAVING COUNT(DISTINCT customer_state) > 1
ORDER BY quantidade_estados DESC, customer_city;

/*
Conclusão:
- Foram encontrados nomes de cidades associados a múltiplas UFs.
- Isso não representa necessariamente inconsistência, pois municípios
  de diferentes estados podem possuir o mesmo nome.
- customer_city isoladamente não deve ser considerada uma identificação
  geográfica única.
- Para análises geográficas, deve-se considerar pelo menos a combinação
  customer_city + customer_state.
- A consistência geográfica poderá ser aprofundada posteriormente
  utilizando raw.geolocation.
*/

-- =========================================================
-- Resumo do profiling de customers
-- =========================================================

SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT customer_id) AS customer_ids_distintos,
    COUNT(DISTINCT customer_unique_id) AS clientes_unicos,
    COUNT(DISTINCT customer_zip_code_prefix) AS ceps_distintos,
    COUNT(DISTINCT customer_city) AS cidades_distintas,
    COUNT(DISTINCT customer_state) AS estados_distintos
FROM raw.customers;