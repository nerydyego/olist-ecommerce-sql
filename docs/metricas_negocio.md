# Dicionário de Métricas de Negócio — Olist E-Commerce

## 1. Critério de elegibilidade dos pedidos

**Regra adotada:** considerar elegíveis para os indicadores comerciais somente os pedidos com `order_status = 'delivered'`.

**Justificativa:** padronizar as análises comerciais com base em pedidos registrados como entregues, evitando misturar pedidos concluídos com pedidos cancelados, indisponíveis ou em outros estágios.

**Aplicação:** evolução de pedidos elegíveis, receita bruta de itens, ticket médio, produtos, categorias, clientes e vendedores.

**Exceção:** análises operacionais de distribuição de status considerarão todos os pedidos, independentemente da elegibilidade.

## 2. Indicadores iniciais

| Indicador | Definição | Resultado Q01 |
|---|---|---:|
| Total de pedidos | Contagem de todos os pedidos | 99.441 |
| Pedidos elegíveis | Pedidos com status `delivered` | 96.478 |
| Participação de pedidos elegíveis | Pedidos elegíveis / total de pedidos × 100 | 97,02% |

**Granularidade:** um registro por `order_id` em `analytics.orders`, validado sem identificadores nulos ou duplicados.

**Data-base para análises temporais futuras:** `order_purchase_timestamp`.

## 3. Limitações

- O status `delivered` representa entrega registrada no dataset, não comprovação de pagamento recebido.
- O percentual de pedidos entregues não deve ser interpretado isoladamente como taxa de sucesso logístico.
- A definição de receita bruta de itens será aplicada e validada nas perguntas financeiras posteriores.