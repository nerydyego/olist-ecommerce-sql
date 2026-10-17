# Relatório de Qualidade dos Dados — Olist Brazilian E-Commerce

**Projeto:** Olist Brazilian E-Commerce | SQL & PostgreSQL  
**Banco de dados:** `olist_ecommerce`  
**Schemas:** `raw` e `analytics`  
**Etapa:** 5 — Auditoria complementar de qualidade dos dados  
**Situação:** Etapa 5.1 concluída quanto à reconciliação quantitativa; etapas 5.2–5.6 pendentes  
**Data do registro:** 17/10/2026

## 1. Objetivo e escopo

Documentar a reconciliação quantitativa entre as nove tabelas dos schemas `raw` e `analytics`, verificando diferenças de volume após a transformação e justificando as alterações previstas. A auditoria foi realizada por meio de consultas SQL no PostgreSQL, com revisão de scripts de transformação para os casos em que as contagens diferiram.

**Limite da conclusão:** igualdade de contagens não comprova igualdade de identificadores, atributos ou conjuntos de registros. As verificações de completude, duplicidade, integridade e plausibilidade pertencem às etapas seguintes.

## 2. Resultado consolidado — Etapa 5.1

**Convenção:** diferença = `Analytics − RAW`.

| Tabela | RAW | Analytics | Diferença | Conclusão quantitativa |
|---|---:|---:|---:|---|
| `customers` | 99.441 | 99.441 | 0 | Contagens iguais |
| `orders` | 99.441 | 99.441 | 0 | Contagens iguais |
| `order_items` | 112.650 | 112.650 | 0 | Contagens iguais |
| `order_payments` | 103.886 | 103.886 | 0 | Contagens iguais |
| `order_reviews` | 99.224 | 99.224 | 0 | Contagens iguais |
| `products` | 32.951 | 32.951 | 0 | Contagens iguais |
| `sellers` | 3.095 | 3.095 | 0 | Contagens iguais |
| `geolocation` | 1.000.163 | 738.332 | -261.831 | Redução explicada quantitativamente pela deduplicação |
| `product_category_name_translation` | 71 | 73 | +2 | Inclusões adicionais identificadas e justificadas |

**Síntese:** 9 de 9 tabelas tiveram contagens verificadas; 7 apresentaram diferença zero e 2 apresentaram diferenças previstas e investigadas.

## 3. Investigação das divergências

### 3.1. `geolocation` — Deduplicação

- **RAW:** 1.000.163 registros.
- **Analytics:** 738.332 registros.
- **Diferença:** -261.831 registros (redução de aproximadamente 26,18% do volume RAW).
- **Regra identificada no script de transformação:** `INSERT INTO analytics.geolocation ... SELECT DISTINCT` das cinco colunas `geolocation_zip_code_prefix`, `geolocation_lat`, `geolocation_lng`, `geolocation_city` e `geolocation_state`, com `CAST(... AS NUMERIC)` aplicado à latitude e longitude antes da deduplicação.
- **Validação executada:** uma consulta de contagem sobre a seleção distinta dessas cinco expressões em `raw.geolocation` retornou **738.332 combinações distintas**, igual à contagem de Analytics.
- **Conclusão:** a redução quantitativa observada corresponde ao volume esperado pela regra de deduplicação identificada. O procedimento **não** consistiu em manter um único registro por CEP: CEPs iguais podem coexistir quando outra coluna difere.
- **Limitação:** a equivalência exata do conteúdo entre as combinações distintas de RAW e os registros de Analytics não foi testada nesta etapa.

### 3.2. `product_category_name_translation` — Inclusão de categorias

- **RAW:** 71 registros.
- **Analytics:** 73 registros.
- **Diferença:** +2 registros.
- **Investigação executada:** comparação com `EXCEPT` entre as tabelas identificou os registros presentes apenas em Analytics.

| `product_category_name` | `product_category_name_english` |
|---|---|
| `pc_gamer` | `NULL` |
| `portateis_cozinha_e_preparadores_de_alimentos` | `NULL` |

- **Evidência da transformação:** o script contém um `INSERT INTO analytics.product_category_name_translation ... VALUES` com exatamente essas duas categorias e o campo de tradução definido explicitamente como `NULL`.
- **Conclusão:** as duas inclusões explicam a diferença de contagem. A ausência das traduções será considerada na Etapa 5.2 (completude).
- **Limitação:** o teste realizado identifica linhas presentes apenas em Analytics; não substitui uma comparação bidirecional completa do conteúdo.

## 4. Metodologia e rastreabilidade

1. Executar contagens `COUNT(*)` para cada tabela em `raw` e `analytics`.
2. Calcular a diferença `Analytics − RAW`.
3. Confrontar os resultados com as referências históricas da transformação.
4. Para divergências, consultar os scripts em `sql/03_transformation/` e executar verificações específicas.
5. Registrar conclusões, limitações e pendências sem alterar os dados de origem.

**Script de auditoria:** `sql/04_data_quality/01_reconciliation.sql` (caminho previsto no repositório; manter ali as consultas executadas).  
**Scripts de origem das regras:** `sql/03_transformation/`.

## 5. Conclusão da Etapa 5.1

A reconciliação **quantitativa** RAW × Analytics foi concluída para as nove tabelas. As sete tabelas sem variação mantiveram a contagem de registros. As diferenças em `geolocation` e `product_category_name_translation` foram compatíveis com as regras de transformação identificadas e tiveram sua justificativa documentada.

**Decisão:** não realizar correções nesta etapa. Preservar o schema `raw` e prosseguir com a auditoria complementar.

## 6. Próximas verificações

- [x] 5.1 — Reconciliar contagens das nove tabelas.
- [x] 5.1 — Investigar e justificar quantitativamente a deduplicação de `geolocation`.
- [x] 5.1 — Identificar as duas categorias adicionadas e localizar sua inserção.
- [ ] 5.2 — Quantificar `NULL`, strings vazias e espaços em branco, inclusive traduções ausentes.
- [ ] 5.3 — Investigar duplicidades e unicidade das chaves de negócio.
- [ ] 5.4 — Verificar consistência entre entidades e relacionamentos.
- [ ] 5.5 — Testar regras de negócio, cronologia e plausibilidade monetária.
- [ ] 5.6 — Consolidar achados, decisões, limitações e relatório final.

> **Nota de auditoria:** os números acima são resultados de consultas executadas e compartilhadas durante a Etapa 5.1. Não representam nova execução automática do banco de dados no momento de geração deste documento.
