# Resultados da EDA SQL — Olist E-Commerce

**Projeto:** Olist Brazilian E-Commerce Dataset  
**Ambiente:** PostgreSQL 16 · Banco `olist_ecommerce` · Schema `analytics`  
**Progresso:** **20/20 questões concluídas (100%)**  
**Consultas:** [`sql/05_eda_sql/`](../sql/05_eda_sql/) · **Regras de negócio:** [`metricas_negocio.md`](metricas_negocio.md)

## Escopo e critérios

- **Pedidos elegíveis:** `order_status = 'delivered'`.
- **Referência temporal:** `order_purchase_timestamp` (data da compra).
- **Localização:** UF do cliente, não do vendedor.
- **Valor bruto de produtos:** soma de `order_items.price`, **sem frete**; frete analisado separadamente.
- **Interpretação:** valores comerciais do dataset, não receita contábil reconhecida. O período possui cobertura parcial nas extremidades.

## Bloco A — Pedidos e evolução temporal (Q01–Q04)

| Questão | Resultado principal |
|---|---|
| **Q01 — Status dos pedidos** | **99.441** pedidos; **96.478 entregues (97,02%)**. |
| **Q02 — Evolução temporal** | **23 meses com pedidos entregues**, entre set./2016 e ago./2018; **267** em 2016, **43.428** em 2017 e **52.783** em 2018. |
| **Q03 — Meses extremos** | Maior volume: **nov./2017 (7.289)**; menor no recorte comparável: **jan./2017 (750)**. |
| **Q04 — Distribuição por UF** | **27 UFs**; SP (**40.501**), RJ (**12.350**) e MG (**11.354**) somam **66,55%** dos pedidos entregues. |

**Nota temporal:** a Q03 compara jan./2017 a jul./2018, excluindo os meses das extremidades por cautela quanto à cobertura. Totais anuais de períodos parciais não são taxas de crescimento equivalentes.

## Bloco B — Vendas e produtos (Q05–Q11)

| Questão | Resultado principal |
|---|---|
| **Q05 — Produtos e frete** | Produtos: **R$ 13.221.498,11 (85,74%)**; frete: **R$ 2.198.275,64 (14,26%)**; total combinado: **R$ 15.419.773,75**. |
| **Q06 — Ticket médio** | **R$ 159,83** por pedido entregue, incluindo produtos e frete; **110.197** linhas de itens para **96.478** pedidos. |
| **Q07 — Vendas mensais** | Maior valor bruto mensal de produtos: **nov./2017 — R$ 987.765,37**. |
| **Q08 — Vendas por UF do cliente** | SP: **R$ 5.067.633,16**; RJ: **R$ 1.759.651,13**; MG: **R$ 1.552.481,83**. Juntos, aproximadamente **63,38%** do total de produtos. |
| **Q09 — Categorias** | Lideram **beleza_saude (R$ 1.233.131,72)**, **relogios_presentes (R$ 1.166.176,98)** e **cama_mesa_banho (R$ 1.023.434,76)**. Top 5: aproximadamente **39,83%** do valor bruto. |
| **Q10 — Produtos líderes** | Produto de maior valor bruto: `bb50f2e236e5eea0100680137654686c` (**R$ 63.560,00**). Top 10: **R$ 442.814,82 (3,35%)** do valor bruto de produtos. |
| **Q11 — Participação por categoria** | **74 grupos** (incluindo `NULL`); liderança de **beleza_saude (9,33%)**. As cinco maiores categorias somam **39,83%** do valor bruto. |

**Categorias (Q09):** 73 categorias identificadas e um grupo sem categoria (`NULL`), com **R$ 170.726,63** em produtos. O grupo foi mantido na análise para preservar os totais.

### Validações e consistência

- **Pedidos:** totais por status, período e UF reconciliados com os **96.478** pedidos entregues.
- **Valor bruto de produtos:** somas mensais (Q07), por UF (Q08) e por categoria (Q09 e Q11) reconciliadas com a Q05: **R$ 13.221.498,11**, sem diferença.
- **Q11 — Percentuais:** soma das participações arredondadas = **99,96%** (diferença de **0,04 p.p.** por arredondamento); soma dos valores por categoria = **R$ 13.221.498,11**.
- **Top 10 de produtos (Q10):** representa somente uma parcela do total; não deve ser reconciliado isoladamente com o valor global.

## Bloco C — Clientes, vendedores e pagamentos (Q12–Q17)

| Questão | Resultado principal |
|---|---|
| **Q12 — Clientes únicos** | **93.358** clientes distintos (`customer_unique_id`) com ao menos um pedido entregue. |
| **Q13 — Clientes recorrentes** | **600** clientes realizaram pelo menos dois pedidos entregues (**0,64%** dos clientes únicos); somam **1.252** pedidos, com máximo de **7** por cliente. |
| **Q14 — Clientes únicos por UF** | **27 UFs**; SP (**39.156**), RJ (**11.917**) e MG (**11.001**). Soma das contagens estaduais: **93.396**. |
| **Q15 — Vendedores cadastrados por UF** | **3.095** vendedores distribuídos por **23 UFs**; maior concentração estadual: **1.849 vendedores** (**59,74%** do cadastro). UF líder não informada no resultado consolidado. |
| **Q16 — Pedidos por forma de pagamento** | `credit_card`: **74.304**; `boleto`: **19.191**; `voucher`: **3.679**; `debit_card`: **1.485**. Soma das contagens por modalidade: **98.659**. |
| **Q17 — Valor por forma de pagamento** | Total de **R$ 15.422.461,77**; cartão de crédito **R$ 12.101.094,88**, boleto **R$ 2.769.932,58**, voucher **R$ 343.013,19** e débito **R$ 208.421,12**. |

### Validações e cuidados de interpretação — Bloco C

- **Q12–Q13:** recorrência observada = **600 / 93.358 ≈ 0,64%**; não representa taxa de retenção por coorte.
- **Q14:** a soma de clientes distintos por UF (**93.396**) supera o total de clientes distintos globalmente (**93.358**) em **38 contagens**. Um identificador presente em mais de uma UF pode ser contado em cada uma delas; o número de pessoas envolvidas não foi apurado separadamente.
- **Q15:** a soma por UF (**3.095**) coincide com a contagem de vendedores cadastrados. O máximo estadual é **1.849**, mas a UF correspondente ainda não foi registrada.
- **Q16:** cada modalidade contabiliza `COUNT(DISTINCT order_id)` apenas entre pedidos `delivered`. A soma por modalidade (**98.659**) supera os **96.478** pedidos entregues em **2.181**; pedidos com múltiplas modalidades podem explicar contagens adicionais. Não foi realizada uma reconciliação específica de cobertura dos pagamentos.
- **Q16 — Participação na soma por modalidade:** cartão de crédito **75,31%**; boleto **19,45%**; voucher **3,73%**; débito **1,51%**. O denominador é **98.659 contagens por modalidade**, não o total global de pedidos entregues.
- **Q17 — Reconciliação financeira:** os pagamentos somam **R$ 15.422.461,77**, enquanto produtos + frete (Q05) somam **R$ 15.419.773,75**; diferença de **R$ 2.688,02 (aprox. 0,0174%)**. As medidas vêm de tabelas distintas e a causa da diferença não foi investigada.
- **Q17 — Composição do valor pago:** cartão de crédito representa aproximadamente **78,46%** dos pagamentos registrados.

## Bloco D — Entregas e avaliações (Q18–Q20)

| Questão | Resultado principal |
|---|---|
| **Q18 — Tempo médio de entrega** | **12,56 dias** entre compra e entrega efetiva, considerando pedidos `delivered` com data de entrega preenchida. |
| **Q19 — Pedidos entregues após o prazo estimado** | **7.826** pedidos com entrega efetiva posterior à data/hora estimada. |
| **Q20 — Distribuição das avaliações** | **96.361** registros de avaliação de pedidos entregues: nota 1 (**9.406**), 2 (**2.941**), 3 (**7.961**), 4 (**18.987**) e 5 (**57.066**). |

### Validações e cuidados de interpretação — Bloco D

- **Q18:** a duração é calculada pela diferença entre os timestamps de entrega e compra, convertida em dias corridos com frações; o resultado não mede dias úteis nem cumprimento do prazo prometido.
- **Q19:** o critério de atraso compara os timestamps completos (`entrega efetiva > entrega estimada`); a taxa exata de atraso não foi calculada, pois não foi apurado separadamente o denominador de pedidos entregues com ambas as datas preenchidas.
- **Q20:** avaliações positivas (notas 4 e 5) totalizam **76.053 (78,93%)**; negativas (notas 1 e 2), **12.347 (12,81%)**. A nota média ponderada é de aproximadamente **4,16**.
- **Q20 — Unidade de contagem:** o total de **96.361** corresponde a **registros de avaliação**, não a pedidos distintos. A diferença para os **96.478** pedidos entregues não permite concluir diretamente quantos pedidos ficaram sem avaliação.

## Síntese dos achados

As compras elegíveis concentram-se no Sudeste, especialmente em São Paulo, e o pico de pedidos e de valor bruto mensal de produtos ocorreu em **novembro de 2017**. As cinco principais categorias representam cerca de **39,83%** do valor bruto de produtos, enquanto os dez produtos líderes representam **3,35%**. Entre os clientes únicos, **0,64%** realizaram mais de um pedido entregue. O cartão de crédito predomina tanto nas contagens por modalidade (**75,31%**) quanto no valor dos pagamentos (**78,46%**). Na logística, o tempo médio entre compra e entrega é de **12,56 dias**, e **7.826** pedidos ultrapassaram o prazo estimado segundo a comparação de timestamps. Nas avaliações, **78,93%** dos registros receberam notas 4 ou 5.

## Andamento

| Bloco | Questões | Situação |
|---|---|---|
| A — Pedidos | Q01–Q04 | Concluído |
| B — Vendas e produtos | Q05–Q11 | Concluído |
| C — Clientes, vendedores e pagamentos | Q12–Q17 | Concluído |
| D — Entregas e avaliações | Q18–Q20 | Concluído |

**Status:** EDA SQL concluída — **20/20 questões (100%)**.  
**Próximos passos:** revisar `docs/metricas_negocio.md`, atualizar resumidamente o `README.md` e versionar a conclusão da etapa no GitHub.  
**Reprodutibilidade:** consultas e transformações permanecem versionadas na pasta `sql/`; este documento registra apenas os resultados consolidados.
