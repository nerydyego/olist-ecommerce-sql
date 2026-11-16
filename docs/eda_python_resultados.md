# Olist Brazilian E-Commerce — Documentação consolidada da EDA Python

**Projeto:** Olist E-Commerce | SQL, Python, Power BI e Machine Learning  
**Etapa:** Análise Exploratória de Dados (EDA) com Python  
**Status:** análises A01–A08 e síntese C01 concluídas no escopo definido  
**Atualização:** 16/11/2026  
**Repositório:** https://github.com/nerydyego/olist-ecommerce-sql

## 1. Objetivo e escopo

Explorar os dados transacionais do conjunto *Brazilian E-Commerce Public Dataset by Olist* por meio de Python, reutilizando as definições de negócio e os dados tratados na etapa SQL. A análise cobre indicadores comerciais, evolução mensal das vendas, categorias de produtos, distribuição geográfica, desempenho logístico e associação entre atrasos e avaliações de clientes.

O escopo foi limitado a oito análises (A01–A08), com consolidação de resultados no próprio notebook (C01). Não inclui modelagem preditiva, inferência causal, auditoria exaustiva ou criação de dashboard Power BI.

## 2. Arquitetura e ambiente

```text
CSV Olist (9 fontes)
       |
       v
PostgreSQL 16 — olist_ecommerce
       |-- raw       (dados de origem)
       `-- analytics (dados transformados)
                 |
          SQLAlchemy / psycopg
                 |
       Python / pandas / notebooks
                 |
         EDA A01–A08 + C01
                 |
        Power BI (próxima fase)
```

- **Infraestrutura:** PostgreSQL 16 em container Docker no servidor Ubuntu; acesso remoto por túnel SSH, com encaminhamento local da porta 5433.
- **Ambiente Python:** Python 3.12 gerenciado por Poetry, com ambiente virtual do projeto (`.venv`).
- **Bibliotecas utilizadas:** pandas, NumPy, SQLAlchemy, psycopg, python-dotenv, Matplotlib e Seaborn.
- **Conexão:** módulo `src/database.py`, que configura um `engine` SQLAlchemy a partir de variáveis em `.env`.
- **Segurança:** `.env`, `.venv` e CSVs locais não devem ser versionados.

**Artefatos principais:**

| Arquivo | Responsabilidade |
|---|---|
| `notebooks/01_exploracao_inicial.ipynb` | Exploração inicial de tabelas, tipos, valores ausentes e status dos pedidos |
| `notebooks/02_analise_exploratoria.ipynb` | Indicadores, transformações analíticas, visualizações e conclusões A01–A08/C01 |
| `src/database.py` | Criação da conexão com PostgreSQL |
| `notebooks/roadmap_eda_python_02.md` | Planejamento, critérios de encerramento e acompanhamento das atividades |
| `docs/eda_sql_resultados.md` | Referência para resultados e definições da EDA SQL |
| `docs/metricas_negocio.md` | Definições de indicadores comerciais |

## 3. Premissas metodológicas

1. **Elegibilidade comercial:** pedidos com `order_status = 'delivered'`, salvo indicação em contrário.
2. **Receita de produtos:** soma de `order_items.price`, sem frete. Não equivale à receita contábil líquida da plataforma.
3. **Valor total dos pedidos:** soma de preços dos itens e respectivos fretes; o ticket médio divide esse valor pela quantidade de pedidos entregues distintos.
4. **Granularidade:** `orders` contém pedidos; `order_items`, itens de pedido; `order_reviews`, registros de avaliação. As junções respeitam essas diferenças para evitar multiplicação de valores.
5. **Evolução temporal:** utiliza o mês de `order_purchase_timestamp`; períodos incompletos não devem ser comparados como se tivessem a mesma cobertura.
6. **Atraso:** na EDA Python, uma entrega é atrasada quando o **dia de calendário** da entrega efetiva é posterior ao dia estimado, após `.dt.normalize()` nas duas datas.
7. **Avaliações:** quando há mais de uma avaliação associada a um pedido, calcula-se a média de `review_score` para representar esse pedido uma única vez.
8. **Interpretação:** resultados descritivos e associações observacionais não estabelecem causalidade.

## 4. Preparação e verificações

O notebook inicial inspecionou `analytics.orders`, incluindo seus tipos e valores ausentes. A tabela contém **99.441 pedidos**, dos quais **96.478** apresentam status `delivered`.

Para a análise logística, foram removidos apenas os pedidos entregues sem data efetiva de entrega: **8 registros**, resultando em **96.470 pedidos**. As datas de compra e de entrega foram utilizadas para calcular a duração em dias; a data estimada foi usada para classificar atrasos.

Para a análise de avaliações, `analytics.order_reviews` apresentou **99.224 registros** e **98.673 pedidos distintos**: existem **551 registros excedentes** em relação à unicidade de `order_id` (não necessariamente 551 pedidos distintos com múltiplas avaliações). Após o agrupamento por pedido, a junção com a base logística, com `how='left'` e `validate='one_to_one'`, preservou **96.470 linhas** e identificou **646 pedidos sem avaliação**. Assim, **95.824 pedidos** contribuíram para a comparação de notas.

## 5. Resultados das análises A01–A08

### A01 — Indicadores comerciais

| Indicador | Resultado |
|---|---:|
| Pedidos entregues | 96.478 |
| Itens comercializados | 110.197 |
| Valor de produtos (sem frete) | R$ 13.221.498,11 |
| Valor de frete | R$ 2.198.275,64 |
| Valor de produtos + frete | R$ 15.419.773,75 |
| Ticket médio por pedido entregue (com frete) | R$ 159,83 |

**Interpretação:** esses indicadores descrevem a escala das operações e servem de referência para as demais análises. Os totais comerciais foram conciliados com a EDA SQL.

### A02 — Evolução mensal de vendas

A agregação mensal de `order_items.price`, pelo mês da compra, identificou **novembro de 2017** como o maior mês de faturamento de produtos no recorte analisado, com **R$ 987.765,37**. A série temporal foi apresentada em gráfico de linhas.

**Interpretação:** a visualização permite identificar variações mensais de demanda, respeitando as diferenças de cobertura entre os períodos do dataset.

### A03 — Categorias de maior faturamento

Foi elaborado um ranking das **10 categorias de produtos com maior faturamento**, mediante relacionamento entre itens, produtos e tradução de categorias, preservando a granularidade dos itens. O resultado foi apresentado em gráfico de barras.

**Limite de registro:** os valores individuais e a ordem completa das 10 categorias não estão reproduzidos nesta consolidação; devem ser consultados no notebook, sem inferir posições ou valores não documentados aqui.

### A04 — Concentração de faturamento por categoria

As **10 categorias líderes concentraram 62,43%** do faturamento de produtos. A participação foi representada por gráfico de composição.

**Interpretação:** parcela relevante do faturamento está concentrada em um conjunto restrito de categorias, informação útil para monitoramento do portfólio comercial.

### A05 — Distribuição geográfica das vendas

A receita de produtos e a quantidade de pedidos entregues foram agregadas por **UF do cliente**, não do vendedor, cobrindo 27 unidades federativas.

| UF | Faturamento de produtos | Pedidos entregues |
|---|---:|---:|
| SP | R$ 5.067.633,16 | 40.501 |
| RJ | R$ 1.759.651,13 | 12.350 |
| MG | R$ 1.552.481,83 | 11.354 |

**Interpretação:** São Paulo lidera o volume de pedidos e o faturamento de produtos; a distribuição evidencia concentração comercial no Sudeste.

### A06 — Tempo de entrega

**Base elegível:** 96.470 pedidos entregues com datas válidas. O prazo foi calculado como a diferença entre `order_delivered_customer_date` e `order_purchase_timestamp`, em dias.

| Estatística | Dias |
|---|---:|
| Média | 12,56 |
| Mediana | 10,22 |
| 1º quartil (25%) | 6,77 |
| 3º quartil (75%) | 15,72 |
| Mínimo | 0,53 |
| Máximo | 209,63 |

**Interpretação:** a média superior à mediana e o histograma indicam assimetria à direita, com uma cauda de entregas de duração elevada.

### A07 — Taxa de entregas atrasadas

Para evitar classificar como atrasada uma entrega feita no próprio dia previsto, as datas efetiva e estimada foram normalizadas para meia-noite **antes** da comparação.

| Situação | Pedidos | Participação |
|---|---:|---:|
| No prazo | 89.936 | 93,23% |
| Com atraso | 6.534 | 6,77% |
| **Total** | **96.470** | **100%** |

**Interpretação:** aproximadamente 7 em cada 100 pedidos entregues com data válida chegaram depois do dia previsto.

**Nota de comparabilidade:** a EDA SQL registrou **7.826** entregas após a data estimada, enquanto a EDA Python registrou **6.534** com comparação por **dia de calendário** e exclusão de oito pedidos sem data efetiva. Os números não devem ser tratados como equivalentes sem alinhar critérios e populações. A diferença exata entre os predicados SQL e Python não foi revalidada nesta documentação.

### A08 — Atrasos e avaliações dos clientes

As avaliações foram previamente consolidadas por `order_id` mediante média de `review_score`, preservando uma observação por pedido. A comparação utiliza **95.824 pedidos avaliados**.

| Situação | Pedidos avaliados | Nota média (1–5) |
|---|---:|---:|
| No prazo | 89.443 | 4,29 |
| Com atraso | 6.381 | 2,27 |
| **Total** | **95.824** | — |

**Resultado principal:** a diferença entre as notas médias é de aproximadamente **2,02 pontos** na escala de 1 a 5. A comparação foi representada em gráfico de barras com eixo vertical de 0 a 5.

**Interpretação:** entregas atrasadas estão associadas a avaliações médias mais baixas. O resultado não demonstra que o atraso, isoladamente, tenha causado a redução das notas.

## 6. Síntese executiva — C01

A EDA Python reproduziu os principais indicadores comerciais definidos na etapa SQL e ampliou a exploração por categoria, UF, prazo de entrega e satisfação. O faturamento de produtos concentrou-se em determinadas categorias e estados, especialmente São Paulo. A maioria das entregas ocorreu até o dia estimado; porém, pedidos atrasados receberam notas médias substancialmente inferiores.

Esses achados sustentam quatro eixos para o futuro dashboard Power BI: **desempenho comercial**, **evolução temporal e categorias**, **distribuição geográfica** e **logística/satisfação**. A seleção final de visuais e medidas deve preservar os filtros e a granularidade de cada indicador.

## 7. Qualidade, limitações e decisões registradas

- **Dados ausentes:** oito pedidos `delivered` sem data efetiva de entrega foram excluídos somente das análises que exigem essa data; 646 pedidos logísticos sem avaliação permaneceram no resultado da junção, mas não contribuíram para médias de `review_score`.
- **Duplicidade lógica em avaliações:** múltiplas avaliações por pedido foram agregadas pela média antes do relacionamento com entregas. A consolidação atribui peso igual a cada pedido, mas pode produzir notas fracionárias.
- **Definição de atraso:** a classificação por dia de calendário difere da comparação direta de timestamps; documentar a regra ao implementar o KPI no Power BI.
- **Métricas monetárias:** valor de itens e frete não equivalem automaticamente a receita contábil reconhecida, lucro ou pagamentos efetivamente recebidos.
- **Período histórico:** as análises descrevem o recorte disponível no dataset e não devem ser generalizadas para operações atuais.
- **Causalidade:** a associação entre atraso e avaliação não foi ajustada por outras variáveis nem submetida a experimento causal.
- **Auditoria:** esta etapa não substitui o relatório de qualidade de dados nem comprova integridade exaustiva de todos os campos.

## 8. Reprodutibilidade e encerramento

**Concluído no escopo analítico:** A01–A08, visualizações previstas e síntese C01. O notebook utiliza o banco `olist_ecommerce`, schema `analytics`, com `engine` de `src/database.py`.

**Verificação técnica ainda não confirmada:** reiniciar o kernel e executar `02_analise_exploratoria.ipynb` do início ao fim, com túnel SSH ativo, validando ausência de erros e consistência dos resultados. Esta documentação não declara essa verificação como executada.

**Próxima fase:** planejamento e desenvolvimento do dashboard Power BI, com reconciliação dos KPIs SQL/Python e explicitação da regra de atraso adotada. Machine Learning permanece como etapa posterior.

---

**Documentos relacionados:** `README.md`, `docs/documentacao_tecnica_olist.md`, `docs/data_quality_report.md`, `docs/eda_sql_resultados.md`, `docs/metricas_negocio.md` e `notebooks/roadmap_eda_python_02.md`.
