Resultados da Análise Exploratória de Dados em SQL — Olist E-Commerce
Projeto: Olist Brazilian E-Commerce Dataset
Banco: olist_ecommerce | SGBD: PostgreSQL 16 | Schema: analytics
Fase: EDA SQL — Bloco A: Pedidos e evolução temporal
Situação: Q01–Q04 concluídas e validadas (4/20 questões)
Scripts: sql/05_eda_sql/01_orders.sql
Regras de negócio: docs/metricas_negocio.md

1. Objetivo e metodologia
Documentar as respostas às perguntas de negócio da EDA SQL, com métricas reproduzíveis, resultados, validações e interpretações. As consultas utilizam as tabelas tratadas do schema analytics, sem alterar os dados originais.

Critérios aplicados neste bloco:
- Pedido total: qualquer registro em analytics.orders, independentemente do status.
- Pedido elegível para análises comerciais: pedido cujo order_status = 'delivered'.
- Data de referência: order_purchase_timestamp (data de compra, não data de entrega).
- Unidade de contagem: pedido (order_id), com unicidade previamente validada na tabela de pedidos.
- Distribuição geográfica: estado do cliente (analytics.customers.customer_state), não estado do vendedor.
- Percentuais: arredondados a duas casas; pequenas diferenças de soma podem decorrer do arredondamento.
Nota: a elegibilidade por status não implica comprovação de pagamento, reconhecimento contábil de receita ou conclusão da entrega no mesmo mês da compra.

2. Q01 — Quantidade de pedidos por status
Pergunta: Quantos pedidos existem por order_status e qual a participação percentual de cada status?

Fonte: analytics.orders
Granularidade: uma linha por status
Denominador percentual: todos os 99.441 pedidos.
SQL validado
SELECT
    order_status,
    COUNT(*) AS quantidade_pedidos,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM analytics.orders),
        2
    ) AS percentual
FROM analytics.orders
GROUP BY order_status
ORDER BY quantidade_pedidos DESC;
Resultados
Status	Quantidade de pedidos	Participação (%)
delivered	96.478	97,02
shipped	1.107	1,11
canceled	625	0,63
unavailable	609	0,61
invoiced	314	0,32
processing	301	0,30
created	5	0,01
approved	2	0,00
Total	99.441	100,00


Validação
- Total de linhas em analytics.orders: 99.441.
- COUNT(order_id): 99.441.
- COUNT(DISTINCT order_id): 99.441.
- Diferença entre quantidade total e IDs distintos: 0.
- A soma das contagens por status corresponde ao total de pedidos.
Interpretação e decisão
A maior parte dos pedidos da base está classificada como entregue (97,02%). Foi adotada a regra de negócio de considerar somente delivered nas análises comerciais subsequentes, totalizando 96.478 pedidos elegíveis. Os demais status permanecem relevantes para análises operacionais específicas.
3. Q02 — Evolução mensal e anual dos pedidos elegíveis
Pergunta: Como evoluiu o número de pedidos elegíveis por ano e mês?

Fonte: analytics.orders
Filtro: order_status = 'delivered'
Data: order_purchase_timestamp
Granularidade: mês e ano da compra.
SQL — evolução mensal
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS ano_mes,
    COUNT(*) AS quantidade_pedidos
FROM analytics.orders
WHERE order_status = 'delivered'
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY ano_mes;
Resultados mensais
Ano-mês	Pedidos elegíveis
2016-09	1
2016-10	265
2016-12	1
2017-01	750
2017-02	1.653
2017-03	2.546
2017-04	2.303
2017-05	3.546
2017-06	3.135
2017-07	3.872
2017-08	4.193
2017-09	4.150
2017-10	4.478
2017-11	7.289
2017-12	5.513
2018-01	7.069
2018-02	6.555
2018-03	7.003
2018-04	6.798
2018-05	6.749
2018-06	6.099
2018-07	6.159
2018-08	6.351
Total	96.478


Cobertura observada: setembro/2016 a agosto/2018, com 23 meses contendo pedidos elegíveis. Novembro/2016 não aparece porque não houve registros elegíveis agrupados nesse mês.
SQL — evolução anual
SELECT
    DATE_TRUNC('year', order_purchase_timestamp) AS ano,
    COUNT(*) AS quantidade_pedidos
FROM analytics.orders
WHERE order_status = 'delivered'
GROUP BY DATE_TRUNC('year', order_purchase_timestamp)
ORDER BY ano;
Resultados anuais
Ano	Pedidos elegíveis	Participação no total elegível (%)
2016	267	0,28
2017	43.428	45,01
2018	52.783	54,71
Total	96.478	100,00


Observação: a participação percentual anual foi calculada a partir dos totais informados; a consulta anual com subconsulta percentual foi desenvolvida como exercício complementar, mas não há resultado de sua execução confirmado no histórico apresentado.
Validação e insights
- Soma mensal = soma anual = total de pedidos elegíveis da Q01: 96.478.
- Novembro/2017 apresentou o maior volume mensal observado: 7.289 pedidos.
- Os registros indicam expansão do volume mensal ao longo de 2017 e patamar elevado entre janeiro e agosto de 2018.
- Os 52.783 pedidos registrados de janeiro a agosto de 2018 superam os 43.428 registrados em todo o ano de 2017; contudo, os períodos não têm a mesma duração.
Limitação: 2016 e 2018 possuem cobertura parcial. Os totais anuais não devem ser utilizados isoladamente como taxa de crescimento anual, e os dados não permitem afirmar causalidade ou sazonalidade.
4. Q03 — Meses com maior e menor volume de pedidos elegíveis
Pergunta: Quais são os meses com maior e menor volume de pedidos elegíveis, respeitando meses incompletos?

Fonte: analytics.orders
Filtro de elegibilidade: order_status = 'delivered'
Recorte de comparação: de 01/01/2017 (inclusive) a 01/08/2018 (exclusive), isto é, janeiro/2017 a julho/2018.
Critério: excluir os meses iniciais de 2016 e o último mês observado (agosto/2018) do ranking principal, por cautela com a cobertura temporal.
SQL — três maiores volumes
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS mes,
    COUNT(*) AS quantidade
FROM analytics.orders AS o
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-08-01'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY quantidade DESC
LIMIT 3;
SQL — três menores volumes
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS mes,
    COUNT(*) AS quantidade
FROM analytics.orders AS o
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2017-01-01'
  AND o.order_purchase_timestamp < '2018-08-01'
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY quantidade ASC
LIMIT 3;
Resultados — maiores volumes
Posição	Mês	Pedidos elegíveis
1º	Novembro/2017	7.289
2º	Janeiro/2018	7.069
3º	Março/2018	7.003


Resultados — menores volumes
Posição	Mês	Pedidos elegíveis
1º	Janeiro/2017	750
2º	Fevereiro/2017	1.653
3º	Abril/2017	2.303


Validação e interpretação
Os rankings são coerentes com a série mensal obtida na Q02. A ordenação decrescente (DESC) identifica os maiores volumes; a crescente (ASC) identifica os menores. LIMIT 3 retorna os três primeiros registros de cada ranking.

Atenção à reprodutibilidade: nas últimas execuções compartilhadas, o filtro superior ainda estava diferente do recorte acordado (< '2018-07-31' no ranking de maiores e < '2018-08-31' no de menores). Os resultados exibidos permanecem os mesmos quando se aplica o limite correto, de acordo com os totais mensais já verificados na Q02. Os SQLs acima registram a versão final padronizada, que deve ser mantida no repositório.

Limitação: a exclusão de agosto/2018 é uma decisão conservadora; não constitui prova de que todos os meses incluídos estejam integralmente cobertos. Meses de baixo volume não devem ser automaticamente interpretados como baixo desempenho comercial.
5. Q04 — Distribuição geográfica dos pedidos elegíveis
Pergunta: Como os pedidos elegíveis se distribuem por UF do cliente?

Fontes: analytics.orders (o) e analytics.customers (c)
Relacionamento: o.customer_id = c.customer_id
Filtro: o.order_status = 'delivered'
Granularidade: uma linha por UF do cliente.
SQL validado
SELECT
    c.customer_state AS estado,
    COUNT(*) AS quantidade
FROM analytics.orders AS o
INNER JOIN analytics.customers AS c
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY quantidade DESC;
Resultados por estado
UF	Pedidos elegíveis
SP	40.501
RJ	12.350
MG	11.354
RS	5.345
PR	4.923
SC	3.546
BA	3.256
DF	2.080
ES	1.995
GO	1.957
PE	1.593
CE	1.279
PA	946
MT	886
MA	717
MS	701
PB	517
PI	476
RN	474
AL	397
SE	335
TO	274
RO	243
AM	145
AC	80
AP	67
RR	41
Total	96.478


Indicadores e validação
Indicador	Resultado
Pedidos elegíveis por UF (soma)	96.478
Pedidos elegíveis da Q01	96.478
Diferença	0
UFs representadas	27
Maior volume	SP: 40.501
Menor volume	RR: 41
Participação de SP	41,98%
Participação de SP + RJ + MG	66,55%


Interpretação
Há forte concentração de pedidos elegíveis no Sudeste, especialmente em São Paulo. Os três estados com maior volume — SP, RJ e MG — somam 64.205 pedidos, aproximadamente 66,55% dos pedidos elegíveis.

Limitação: a distribuição considera a UF do cliente, não a localização do vendedor nem o destino logístico comprovado. Volumes absolutos não equivalem a taxas per capita ou participação de mercado regional.
6. Síntese executiva do Bloco A
1. A base possui 99.441 pedidos, dos quais 96.478 (97,02%) estão classificados como entregues e foram definidos como elegíveis para análises comerciais.
2. A série de compras elegíveis cobre registros de setembro/2016 a agosto/2018, com cobertura parcial nas extremidades.
3. O maior volume mensal observado foi novembro/2017, com 7.289 pedidos; no recorte comparável da Q03, janeiro/2017 foi o menor, com 750.
4. São Paulo concentra 41,98% dos pedidos elegíveis; SP, RJ e MG, juntos, concentram 66,55%.
5. As contagens por status, por mês, por ano e por UF reconciliam com seus respectivos totais de referência, sem diferenças nos resultados apresentados.
7. Situação e continuidade
Questão	Tema	Situação
Q01	Pedidos por status e participação	Concluída
Q02	Evolução mensal e anual	Concluída
Q03	Meses de maior e menor volume	Concluída
Q04	Distribuição por UF do cliente	Concluída
Q05–Q11	Receita, ticket e catálogo	Pendente
Q12–Q17	Clientes, vendedores e pagamentos	Pendente
Q18–Q20	Entregas e avaliações	Pendente


Progresso: 4/20 questões (20%).
Bloco A: concluído.
Próxima questão: Q05 — Receita bruta de itens e valor total de frete para pedidos elegíveis, no arquivo sql/05_eda_sql/02_sales_products.sql.
Este documento registra os resultados observados e as consultas consolidadas para o portfólio. Atualizar apenas as seções correspondentes às próximas questões, preservando as definições de métricas em docs/metricas_negocio.md.