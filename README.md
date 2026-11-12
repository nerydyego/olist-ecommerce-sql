# Olist E-Commerce | SQL, Analytics e Ciência de Dados

Projeto de portfólio de **engenharia, análise e ciência de dados** com o [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). O objetivo é transformar dados transacionais em indicadores de negócio, evoluindo de **PostgreSQL e SQL** para **Python, Power BI e Machine Learning**.

**Status:** banco, qualidade de dados, **EDA SQL (20/20 questões)** e **EDA Python (A01–A08 e conclusões C01)** concluídos no escopo definido. **Próxima fase:** dashboard Power BI.

## Tecnologias

- **Utilizadas:** PostgreSQL 16, SQL, DBeaver, Docker, Ubuntu Server, Python 3.12, Poetry, pandas, SQLAlchemy, Matplotlib, Jupyter, Git e GitHub.
- **Próximas fases:** Power BI e Machine Learning.

## Arquitetura de dados

```text
9 arquivos CSV (Olist)
         |
         v
PostgreSQL: olist_ecommerce
    |-- raw        Dados originais preservados (TEXT)
    `-- analytics  Tipagem, transformações e relacionamentos
         |
         v
   Análise exploratória SQL (concluída)
         |
         v
   Python / EDA e validação (concluída)
         |
         +--> Power BI / dashboard (planejado)
         `--> Machine Learning / experimento (planejado)
```

A ingestão inicial foi realizada via DBeaver. O banco é executado em servidor próprio com Docker, com acesso remoto por túnel SSH. Os CSVs originais e as credenciais não são versionados.

## Resultados alcançados

- **9 tabelas** carregadas na camada `raw` (**1.550.922 linhas somadas**, não pedidos únicos) e transformadas na camada `analytics`.
- Tipos adequados, chaves primárias e relacionamentos implementados nas tabelas analíticas.
- **261.831 ocorrências excedentes** removidas de `geolocation` com deduplicação por combinação de cinco atributos; **738.332 registros** na camada analítica.
- **610 categorias vazias** em `products` normalizadas para `NULL`.
- **2 categorias** acrescentadas à referência analítica para preservar o relacionamento com produtos, com tradução não disponível mantida como `NULL`.
- Auditoria de **reconciliação e completude das 9 tabelas** documentada. Foram identificadas ausências em datas operacionais de pedidos e strings vazias em comentários de avaliações, sem correções arbitrárias.
- **EDA SQL concluída:** 20 perguntas de negócio sobre pedidos, produtos, clientes, vendedores, pagamentos, entregas e avaliações.
- **Principais indicadores comerciais (pedidos entregues):** 96.478 pedidos; **110.197 itens**; **R$ 13,22 milhões** em produtos (sem frete); **R$ 159,83** de ticket médio (com frete); **93.358** clientes únicos.
- **Pagamentos e satisfação:** **R$ 15,42 milhões** em pagamentos registrados; **96.361** registros de avaliação, dos quais **78,93%** têm notas 4 ou 5.
- **EDA Python concluída (A01–A08):** análise comercial, evolução mensal, ranking e concentração de categorias, distribuição por UF, logística e relação entre atrasos e avaliações. Conexão ao PostgreSQL com SQLAlchemy e junções validadas conforme a granularidade.
- **Reconciliação SQL × Python:** **R$ 13.221.498,11** em produtos, **R$ 2.198.275,64** em frete, **R$ 15.419.773,75** em produtos + frete e **R$ 159,83** de ticket médio.
- **Destaques da EDA Python:** pico mensal de produtos em novembro/2017 (**R$ 987.765,37**); 10 categorias líderes respondem por **62,43%** da receita de produtos; São Paulo lidera o faturamento (**R$ 5.067.633,16**).
- **Logística e satisfação (EDA Python):** entre **96.470** pedidos entregues com datas válidas, tempo médio de entrega de **12,56 dias** e **6.534** atrasos (**6,77%**), pela comparação de **dias de calendário**. Entre **95.824** pedidos com avaliação associada, a nota média foi **4,29** no prazo e **2,27** com atraso. A associação observada não demonstra causalidade.
- **Atenção à comparabilidade:** a EDA SQL registrou **7.826** entregas após a data estimada; a EDA Python contou **6.534** após normalizar as datas para o dia de calendário e excluir 8 entregas sem data efetiva. As contagens usam critérios diferentes e não devem ser apresentadas como uma mesma métrica.

> **Escopo da auditoria:** as verificações realizadas não equivalem a uma certificação completa de unicidade, consistência de negócio ou integridade de todos os atributos. Novas investigações ocorrerão apenas quando relevantes para os indicadores.

## Roadmap e entregáveis

| Fase | Entrega | Situação |
|---|---|---|
| 1. Banco e transformação | PostgreSQL, schemas, carga e modelagem relacional | Concluída |
| 2. Qualidade dos dados | Reconciliação RAW × Analytics e completude | Concluída no escopo definido |
| 3. EDA com SQL | **20 perguntas de negócio**, KPIs e insights documentados | **Concluída (20/20)** |
| 4. Python | EDA A01–A08, validação de KPIs, gráficos e síntese C01 | **Concluída no escopo definido** |
| 5. Power BI | Dashboard executivo com métricas consistentes | Planejada |
| 6. Machine Learning | Problema preditivo, avaliação e limitações | Planejada |

As análises SQL e Python foram concluídas no escopo planejado. A próxima fase é o dashboard Power BI; a execução integral dos notebooks em kernel reiniciado permanece como verificação final de reprodutibilidade, se ainda não realizada.

## Organização do repositório

```text
data/
  raw/                    # CSVs locais, não versionados
  processed/              # dados derivados
sql/
  01_setup/               # estrutura do banco e tabelas
  02_profiling/           # inspeções iniciais
  03_transformation/      # camada analytics
  04_data_quality/        # reconciliação e completude
  05_eda_sql/             # consultas analíticas Q01–Q20
notebooks/                # 01_exploracao_inicial.ipynb e 02_analise_exploratoria.ipynb
src/                      # módulo de conexão ao PostgreSQL
docs/                     # documentação e resultados
images/                   # diagramas e figuras
pyproject.toml            # configuração e dependências Poetry
poetry.lock               # versões resolvidas das dependências
poetry.toml               # configuração local do ambiente Poetry
README.md
PLANO_PROJETO.md
ROADMAP_EDA_SQL.md
```

## Documentação

- [Plano geral do projeto](PLANO_PROJETO.md)
- [Roadmap e perguntas da EDA SQL](ROADMAP_EDA_SQL.md)
- [Relatório de qualidade dos dados](docs/data_quality_report.md)
- [Resultados da EDA SQL](docs/eda_sql_resultados.md)
- [Dicionário de métricas de negócio](docs/metricas_negocio.md)
- [Documentação técnica](docs/documentacao_tecnica_olist.md)
- [Roadmap da EDA Python](notebooks/roadmap_eda_python_02.md)

## Reprodução do ambiente

1. Baixar os nove CSVs no [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) e armazená-los em `data/raw/`.
2. Executar os scripts de `sql/01_setup/` conforme suas dependências.
3. Importar os CSVs para `raw` via DBeaver e validar as cargas com `sql/02_profiling/`.
4. Executar `sql/03_transformation/` na ordem definida pelos scripts.
5. Consultar `sql/04_data_quality/` e a documentação para reproduzir as validações.
6. Executar as consultas em `sql/05_eda_sql/` e conferir os resultados e as definições em `docs/`.
7. Para reproduzir a EDA Python, instalar as dependências com `poetry install`, configurar as variáveis de conexão em `.env`, manter o túnel SSH ativo e executar, em ordem, `notebooks/01_exploracao_inicial.ipynb` e `notebooks/02_analise_exploratoria.ipynb` com o kernel do Poetry.

**Nota:** `.env`, `.venv/` e os CSVs locais não são versionados. A ingestão automatizada em Python, o dashboard Power BI e o Machine Learning ainda não foram implementados. Os valores comerciais do dataset não representam receita contábil reconhecida.
