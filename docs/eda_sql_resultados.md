# Resultados da EDA SQL — Olist E-Commerce

**Projeto:** Olist Brazilian E-Commerce Dataset  
**Ambiente:** PostgreSQL 16 · Banco `olist_ecommerce` · Schema `analytics`  
**Progresso:** **10/20 questões concluídas (50%)**  
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

## Bloco B — Vendas e produtos (Q05–Q10)

| Questão | Resultado principal |
|---|---|
| **Q05 — Produtos e frete** | Produtos: **R$ 13.221.498,11 (85,74%)**; frete: **R$ 2.198.275,64 (14,26%)**; total combinado: **R$ 15.419.773,75**. |
| **Q06 — Ticket médio** | **R$ 159,83** por pedido entregue, incluindo produtos e frete; **110.197** linhas de itens para **96.478** pedidos. |
| **Q07 — Vendas mensais** | Maior valor bruto mensal de produtos: **nov./2017 — R$ 987.765,37**. |
| **Q08 — Vendas por UF do cliente** | SP: **R$ 5.067.633,16**; RJ: **R$ 1.759.651,13**; MG: **R$ 1.552.481,83**. Juntos, aproximadamente **63,38%** do total de produtos. |
| **Q09 — Categorias** | Lideram **beleza_saude (R$ 1.233.131,72)**, **relogios_presentes (R$ 1.166.176,98)** e **cama_mesa_banho (R$ 1.023.434,76)**. Top 5: aproximadamente **39,83%** do valor bruto. |
| **Q10 — Produtos líderes** | Produto de maior valor bruto: `bb50f2e236e5eea0100680137654686c` (**R$ 63.560,00**). Top 10: **R$ 442.814,82 (3,35%)** do valor bruto de produtos. |

**Categorias (Q09):** 73 categorias identificadas e um grupo sem categoria (`NULL`), com **R$ 170.726,63** em produtos. O grupo foi mantido na análise para preservar os totais.

### Validações e consistência

- **Pedidos:** totais por status, período e UF reconciliados com os **96.478** pedidos entregues.
- **Valor bruto de produtos:** somas mensais (Q07), por UF (Q08) e por categoria (Q09) reconciliadas com a Q05: **R$ 13.221.498,11**, sem diferença.
- **Top 10 de produtos (Q10):** representa somente uma parcela do total; não deve ser reconciliado isoladamente com o valor global.

## Síntese dos achados

As compras elegíveis concentram-se geograficamente no Sudeste, sobretudo em São Paulo. O pico de pedidos e de valor bruto mensal de produtos ocorreu em **novembro de 2017**. As cinco principais categorias respondem por cerca de **39,83%** do valor bruto de produtos, enquanto os dez produtos líderes representam **3,35%**, indicando concentração distinta entre categorias e itens individuais.

## Andamento

| Bloco | Questões | Situação |
|---|---|---|
| A — Pedidos | Q01–Q04 | Concluído |
| B — Vendas e produtos | Q05–Q11 | Q05–Q10 concluídas; **Q11 pendente** |
| C — Clientes, vendedores e pagamentos | Q12–Q17 | Pendente |
| D — Entregas e avaliações | Q18–Q20 | Pendente |

**Próxima questão:** Q11 — participação percentual das categorias no valor bruto total de produtos.  
**Reprodutibilidade:** consultas e transformações permanecem versionadas na pasta `sql/`; este documento registra apenas os resultados consolidados.
