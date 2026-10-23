# Dicionário de Métricas de Negócio — Olist E-Commerce

**Projeto:** Olist Brazilian E-Commerce Dataset  
**Ambiente:** PostgreSQL 16 · Banco `olist_ecommerce` · Schema `analytics`  
**Situação:** EDA SQL concluída — **20/20 questões**  
**Resultados detalhados:** [`eda_sql_resultados.md`](eda_sql_resultados.md) · **Consultas:** [`../sql/05_eda_sql/`](../sql/05_eda_sql/)

## 1. Critério de elegibilidade dos pedidos

**Regra adotada:** considerar elegíveis para os indicadores de pedidos concluídos, vendas, clientes, pagamentos, entregas e avaliações somente os pedidos com `order_status = 'delivered'`.

**Justificativa:** padronizar as análises com base em pedidos registrados como entregues, evitando misturar pedidos concluídos com cancelados, indisponíveis ou em outros estágios.

**Exceções:** a distribuição geral de status (Q01) considera todos os pedidos; o cadastro de vendedores por UF (Q15) considera todos os vendedores cadastrados, independentemente de vendas.

**Granularidade:** `analytics.orders` possui um registro por `order_id`, sem duplicidade identificada. Tabelas de itens, pagamentos e avaliações podem conter mais de um registro associado ao mesmo pedido; os relacionamentos exigem atenção à granularidade.

**Referência temporal:** `order_purchase_timestamp` (data e hora da compra). Os meses nas extremidades da série possuem cobertura parcial; comparações de crescimento devem considerar essa limitação.

## 2. Pedidos e evolução temporal — Q01–Q04

| Indicador | Definição e cálculo | Resultado de referência |
|---|---|---:|
| Total de pedidos (Q01) | `COUNT(*)` em `analytics.orders`, todos os status | **99.441** |
| Pedidos elegíveis (Q01) | Contagem de `order_id` com status `delivered` | **96.478** |
| Participação de pedidos elegíveis (Q01) | Pedidos elegíveis / total de pedidos × 100 | **97,02%** |
| Pedidos por ano/mês (Q02) | Contagem de pedidos elegíveis agrupados pelo período de `order_purchase_timestamp` | 2016: **267**; 2017: **43.428**; 2018: **52.783** |
| Meses de maior/menor volume (Q03) | Maior e menor contagem mensal no recorte comparável jan./2017–jul./2018 | Maior: **nov./2017 (7.289)**; menor: **jan./2017 (750)** |
| Pedidos por UF do cliente (Q04) | Contagem de pedidos elegíveis agrupados por `customers.customer_state`, após relacionamento por `customer_id` | SP: **40.501**; RJ: **12.350**; MG: **11.354** |

**Interpretação:** a participação de pedidos entregues é uma proporção de status no dataset, não uma taxa isolada de sucesso logístico. As contagens por UF utilizam a localização do **cliente**, não do vendedor.

## 3. Vendas e produtos — Q05–Q11

| Indicador | Definição e cálculo | Resultado de referência |
|---|---|---:|
| Valor bruto de produtos (Q05) | `SUM(order_items.price)` dos itens vinculados a pedidos elegíveis; **exclui frete** | **R$ 13.221.498,11** |
| Valor de frete (Q05) | `SUM(order_items.freight_value)` dos itens de pedidos elegíveis | **R$ 2.198.275,64** |
| Valor de produtos + frete (Q05) | Soma dos dois componentes anteriores | **R$ 15.419.773,75** |
| Quantidade de linhas de itens (Q06) | Contagem dos registros de `order_items` associados a pedidos elegíveis | **110.197** |
| Ticket médio (Q06) | (Valor de produtos + frete) / quantidade de pedidos elegíveis | **R$ 159,83** |
| Valor mensal de produtos (Q07) | Soma de `price` por mês de compra dos pedidos elegíveis | Pico: **nov./2017 — R$ 987.765,37** |
| Valor de produtos por UF (Q08) | Soma de `price` por `customers.customer_state` | SP: **R$ 5.067.633,16**; RJ: **R$ 1.759.651,13**; MG: **R$ 1.552.481,83** |
| Valor de produtos por categoria (Q09) | Soma de `price` agrupada por `products.product_category_name` | Líder: **beleza_saude — R$ 1.233.131,72** |
| Produtos líderes por valor (Q10) | Soma de `price` por `product_id`, ordenada de forma decrescente | Top 10: **R$ 442.814,82 (3,35%)** |
| Participação da categoria (Q11) | Valor bruto de produtos da categoria / valor bruto total de produtos × 100 | **beleza_saude: 9,33%**; top 5: **39,83%** |

**Regras e cuidados:**

- `price` representa valor de produtos, sem frete; não corresponde automaticamente a receita contábil reconhecida.
- O ticket médio desta EDA **inclui frete** e utiliza pedidos distintos como denominador, não linhas de itens.
- A categoria ausente (`NULL`) permanece como grupo analítico para preservar os totais: **74 grupos**, incluindo um grupo sem categoria.
- Os percentuais arredondados por categoria somam **99,96%** (diferença de arredondamento); as somas monetárias por mês, UF e categoria reconciliam com **R$ 13.221.498,11**.

## 4. Clientes, vendedores e pagamentos — Q12–Q17

| Indicador | Definição e cálculo | Resultado de referência |
|---|---|---:|
| Clientes únicos (Q12) | `COUNT(DISTINCT customers.customer_unique_id)` entre pedidos elegíveis | **93.358** |
| Clientes recorrentes (Q13) | Clientes com **dois ou mais** pedidos elegíveis, agrupados por `customer_unique_id` | **600 (0,64%)**; **1.252** pedidos entre esses clientes |
| Clientes únicos por UF (Q14) | `COUNT(DISTINCT customer_unique_id)` **dentro de cada** `customer_state` | SP: **39.156**; RJ: **11.917**; MG: **11.001** |
| Vendedores cadastrados por UF (Q15) | `COUNT(DISTINCT seller_id)` por `seller_state`, **sem filtro de pedidos** | **3.095** vendedores em **23 UFs**; máximo estadual: **1.849** |
| Pedidos por modalidade (Q16) | `COUNT(DISTINCT order_id)` dentro de cada `payment_type`, somente pedidos elegíveis | Crédito: **74.304**; boleto: **19.191**; voucher: **3.679**; débito: **1.485** |
| Valor por modalidade (Q17) | `SUM(order_payments.payment_value)` por `payment_type`, somente pedidos elegíveis | **R$ 15.422.461,77** no total |

**Definições e limites:**

- `customer_id` identifica o registro de cliente associado ao pedido; `customer_unique_id` identifica o comprador para análises de unicidade e recorrência.
- **Recorrência observada** = 600 / 93.358 ≈ **0,64%**; não é uma taxa de retenção por coorte.
- A soma de clientes distintos por UF é **93.396**, superior aos **93.358** clientes globais em **38 contagens estaduais adicionais**. Um comprador associado a mais de uma UF pode aparecer em mais de um grupo.
- O total de vendedores cadastrados (Q15) **não** representa vendedores ativos em pedidos entregues. A UF com 1.849 vendedores não foi identificada no resumo disponível.
- Em Q16, a soma por modalidade é **98.659** contagens, superior aos **96.478** pedidos entregues. Um pedido pode usar mais de uma modalidade; a participação de cada modalidade deve indicar claramente o denominador utilizado.
- Em Q17, os valores por modalidade são: cartão de crédito **R$ 12.101.094,88**; boleto **R$ 2.769.932,58**; voucher **R$ 343.013,19**; débito **R$ 208.421,12**.
- **Reconciliação financeira:** Q17 (pagamentos) supera Q05 (produtos + frete) em **R$ 2.688,02** (aproximadamente **0,0174%**). A causa não foi investigada; não tratar os dois indicadores como equivalentes.

## 5. Entregas e avaliações — Q18–Q20

| Indicador | Definição e cálculo | Resultado de referência |
|---|---|---:|
| Tempo médio de entrega (Q18) | Média de `(order_delivered_customer_date - order_purchase_timestamp)` convertida para dias por `EXTRACT(EPOCH FROM intervalo) / 86400`, arredondada a duas casas; somente pedidos `delivered` com data efetiva de entrega | **12,56 dias** |
| Pedidos entregues após a estimativa (Q19) | `COUNT(*)` dos pedidos `delivered` com ambas as datas preenchidas e `order_delivered_customer_date > order_estimated_delivery_date` | **7.826** |
| Avaliações por nota (Q20) | `COUNT(*)` de registros de `order_reviews` associados a pedidos `delivered`, agrupados por `review_score` | **96.361** registros |
| Avaliações positivas (Q20) | Registros com notas 4 ou 5 / total de registros de avaliação elegíveis × 100 | **76.053 (78,93%)** |
| Avaliações negativas (Q20) | Registros com notas 1 ou 2 / total de registros de avaliação elegíveis × 100 | **12.347 (12,81%)** |

**Distribuição Q20:** nota 1: **9.406**; nota 2: **2.941**; nota 3: **7.961**; nota 4: **18.987**; nota 5: **57.066**.

**Regras e cuidados:**

- O tempo médio de entrega utiliza **dias corridos com frações**, não dias úteis. A consulta de Q18 não excluiu explicitamente intervalos negativos.
- Na Q19, o atraso é definido por **comparação de timestamp completo**, inclusive horário; a taxa de atraso não foi calculada, pois o total de pedidos com ambas as datas preenchidas não foi informado.
- A Q20 conta **registros de avaliação**, não pedidos distintos. Portanto, a diferença entre **96.361 avaliações** e **96.478 pedidos entregues** não equivale necessariamente à quantidade de pedidos sem avaliação.
- A classificação positiva (notas 4–5) e negativa (notas 1–2) é uma convenção analítica; nota 3 permanece como categoria intermediária.

## 6. Limitações gerais e reprodutibilidade

- O dataset é histórico e tem cobertura temporal parcial nas extremidades.
- O status `delivered` representa entrega registrada, não comprovação de recebimento financeiro.
- Métricas de produtos, frete e pagamentos têm fontes e significados diferentes; diferenças devem ser documentadas, não ajustadas automaticamente.
- Percentuais e médias apresentados podem conter arredondamentos; comparações e reconciliações devem priorizar os valores não arredondados.
- Este documento define as métricas; os resultados consolidados estão em [`eda_sql_resultados.md`](eda_sql_resultados.md) e as consultas reproduzíveis em [`sql/05_eda_sql/`](../sql/05_eda_sql/).
