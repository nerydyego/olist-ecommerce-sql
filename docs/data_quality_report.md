# Relatório de Qualidade dos Dados — Olist Brazilian E-Commerce

**Projeto:** Olist Brazilian E-Commerce | SQL & PostgreSQL  
**Banco de dados:** `olist_ecommerce`  
**Schemas:** `raw` e `analytics`  
**Etapa:** 5 — Auditoria complementar de qualidade dos dados  
**Situação:** Encerrada no escopo definido — reconciliação (5.1), completude (5.2) e documentação dos achados concluídas; auditorias adicionais dispensadas nesta fase  
**Data do registro inicial:** 17/10/2026  
**Atualização de encerramento:** 18/10/2026

## 1. Objetivo e escopo

Documentar a reconciliação quantitativa e a auditoria de completude das nove tabelas dos schemas `raw` e `analytics`, verificando diferenças de volume, valores ausentes e exceções conhecidas da transformação. A auditoria foi realizada por meio de consultas SQL no PostgreSQL e revisão das regras de transformação nos casos relevantes.

**Limite da conclusão:** igualdade de contagens ou de totais de valores ausentes não comprova equivalência integral de identificadores, atributos ou conjuntos de registros. Foram feitas comparações adicionais específicas quando descritas abaixo. A auditoria não constitui certificação integral de qualidade, unicidade, integridade ou plausibilidade de negócio.

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
- **Conclusão:** as duas inclusões explicam a diferença de contagem. A ausência das traduções foi confirmada e registrada na Etapa 5.2 (completude).
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

**Decisão:** não realizar correções durante a reconciliação; preservar o schema `raw`. A auditoria de completude foi realizada na sequência, conforme a seção 6.

## 6. Etapa 5.2 — Auditoria de completude

**Situação: concluída para as nove tabelas, conforme verificações realizadas.** Foram comparados valores `NULL` na camada `analytics` com representações de ausência (`''`) na camada `raw`. Na tabela `order_reviews`, também foram verificadas strings vazias na própria `analytics`. As conclusões abaixo são restritas às colunas e aos testes efetivamente executados.

### 6.1. Resumo por tabela

| Tabela | Resultado e interpretação |
|---|---|
| `orders` | 99.441 pedidos; 160 sem aprovação, 1.783 sem data de envio à transportadora e 2.965 sem data de entrega ao cliente. Ausências na origem verificadas. |
| `products` | 32.951 produtos nas duas camadas; contagens de ausência equivalentes nos sete atributos numéricos/descritivos examinados. Categorias ausentes conferidas por `product_id` com `EXCEPT` nos dois sentidos, sem divergências. |
| `order_items` | 112.650 registros nas duas camadas; zero ausências nos seis campos examinados (`order_item_id`, `product_id`, `seller_id`, `shipping_limit_date`, `price`, `freight_value`). **A verificação de `order_id` não foi apresentada e deve ser incluída no script quando houver manutenção.** |
| `order_payments` | 103.886 registros em ambas as camadas; zero ausências nos cinco campos examinados. |
| `order_reviews` | 99.224 registros em ambas as camadas; zero `NULL` nos sete campos examinados da Analytics; 87.656 títulos e 58.247 mensagens vazias (`''`) em ambas as camadas. |
| `customers` | 99.441 registros em ambas as camadas; zero ausências nos cinco campos examinados. |
| `sellers` | 3.095 registros em ambas as camadas; zero ausências nos quatro campos examinados. |
| `geolocation` | 1.000.163 registros RAW e 738.332 Analytics; zero ausências nos cinco campos examinados em cada camada. A diferença de volume decorre da deduplicação descrita na seção 3.1. |
| `product_category_name_translation` | 71 registros RAW sem campos vazios; 73 Analytics, com dois `NULL` em `product_category_name_english` referentes às categorias adicionadas na transformação. |

### 6.2. `orders` — Datas operacionais e achados

| Campo de data | Registros ausentes | Percentual dos 99.441 pedidos |
|---|---:|---:|
| `order_approved_at` | 160 | 0,16% |
| `order_delivered_carrier_date` | 1.783 | 1,79% |
| `order_delivered_customer_date` | 2.965 | 2,98% |

A distribuição por `order_status` foi analisada para distinguir ausências compatíveis com o estágio operacional dos pedidos de situações que merecem ressalva. Para pedidos com `order_status = 'delivered'`, foram registrados:

| ID | Achado | Registros |
|---|---|---:|
| DQ-001 | Pedido entregue sem `order_approved_at` | 14 |
| DQ-002 | Pedido entregue sem `order_delivered_carrier_date` | 2 |
| DQ-003 | Pedido entregue sem `order_delivered_customer_date` | 8 |

Os conjuntos podem se sobrepor; **não somar as três contagens como se representassem pedidos distintos**. Os campos ausentes foram verificados na RAW, e comparações de identificadores com `EXCEPT` não indicaram divergência para esses casos. A transformação das datas usa a normalização de valores vazios para `NULL` antes da conversão para `TIMESTAMP`.

**Decisão:** preservar as ausências e registrar sua implicação para métricas de prazo de aprovação, expedição e entrega; não imputar datas.

### 6.3. `products` — Atributos e categoria

| Atributo | Ausências RAW | Ausências Analytics |
|---|---:|---:|
| `product_name_lenght` | 610 | 610 |
| `product_description_lenght` | 610 | 610 |
| `product_photos_qty` | 610 | 610 |
| `product_weight_g` | 2 | 2 |
| `product_length_cm` | 2 | 2 |
| `product_height_cm` | 2 | 2 |
| `product_width_cm` | 2 | 2 |

Os testes bidirecionais com `EXCEPT` sobre `product_id` não encontraram diferenças entre os produtos cuja categoria está vazia na RAW e aqueles cuja categoria está `NULL` na Analytics. A igualdade de contagens dos demais atributos não prova, isoladamente, identidade registro a registro.

### 6.4. `order_reviews` — Ausências textuais preservadas

- `review_comment_title`: **87.656** strings vazias na RAW e **87.656** na Analytics.
- `review_comment_message`: **58.247** strings vazias na RAW e **58.247** na Analytics.
- Nos outros cinco campos analisados, não foram identificados valores ausentes pelos testes executados.

**Interpretação:** título e mensagem são campos opcionais do ponto de vista analítico; a ausência de comentário não implica necessariamente avaliação inválida. A manutenção de `''` na Analytics é uma **diferença de padronização** em relação a outros campos convertidos para `NULL`.

**Decisão:** não modificar os dados nesta auditoria; ao analisar comentários em SQL, Python ou Power BI, tratar explicitamente tanto `NULL` quanto strings vazias quando aplicável.

### 6.5. `product_category_name_translation` — Exceção conhecida

As duas linhas adicionais em Analytics têm `product_category_name_english = NULL`:

- `pc_gamer`
- `portateis_cozinha_e_preparadores_de_alimentos`

As inclusões permitiram estabelecer o relacionamento entre produtos e categorias sem excluir produtos nem atribuir traduções não validadas. **Decisão:** manter `NULL` e documentar a limitação em análises por nome de categoria em inglês.

## 7. Encerramento da auditoria — Decisão de escopo

**Etapa 5 encerrada no escopo definido em 18/10/2026.** O objetivo foi produzir evidência suficiente sobre reconciliação de volumes e completude para iniciar a exploração analítica, sem transformar a auditoria em um projeto indefinido.

| Atividade | Situação final |
|---|---|
| 5.1 — Reconciliação quantitativa RAW × Analytics | **Concluída** |
| 5.2 — Completude dos campos examinados nas nove tabelas | **Concluída**, com ressalva de `order_id` em `order_items` |
| 5.3 — Nova auditoria sistemática de duplicidades | **Dispensada nesta fase**; tratamento já realizado na transformação onde necessário |
| 5.4 — Nova auditoria sistemática de integridade referencial | **Dispensada nesta fase**; chaves e relacionamentos planejados já implementados |
| 5.5 — Nova bateria de regras de negócio e plausibilidade | **Não executada nesta fase**; avaliar pontualmente durante a EDA quando impactar indicadores |
| 5.6 — Consolidação do relatório e decisões | **Concluída** |

**Ressalvas:** os tratamentos prévios e a presença de PK/FK não substituem testes completos de unicidade e consistência de negócio. Não se afirma que o conjunto esteja livre de todas as anomalias. A verificação de `order_id` em `order_items` permanece como pequena pendência documental/técnica, sem reabrir toda a auditoria.

## 8. Rastreabilidade e próximos passos

- `sql/04_data_quality/01_reconciliation.sql` — consultas de reconciliação RAW × Analytics.
- `sql/04_data_quality/02_qtn_null.sql` — consultas de completude; consolidar as versões definitivas e incluir `order_id` em `order_items` quando atualizar o script.
- `sql/03_transformation/` — regras de transformação e decisões de modelagem.
- `docs/data_quality_report.md` — este relatório.
- `ROADMAP_EDA_SQL.md` — plano da próxima fase, **análise exploratória com SQL**, com perguntas e critérios de conclusão.
- `PLANO_PROJETO.md` — planejamento geral, seguido de Python, Power BI e Machine Learning.

**Próxima fase:** executar a EDA com SQL conforme o roadmap aprovado, documentando regras de indicadores, granularidade dos `JOINs` e achados de qualidade somente quando relevantes às perguntas analíticas. Não reabrir a auditoria geral sem evidência concreta de problema que comprometa os resultados.

> **Nota de rastreabilidade:** os resultados registrados foram fornecidos a partir das consultas executadas no PostgreSQL durante o projeto. Este documento não representa nova execução automática do banco de dados.
