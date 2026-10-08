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
