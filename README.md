# Olist E-Commerce | SQL, Analytics e Ciência de Dados

Projeto de portfólio de **engenharia, análise e ciência de dados** com o [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). O objetivo é transformar dados transacionais em indicadores de negócio, evoluindo de **PostgreSQL e SQL** para **Python, Power BI e Machine Learning**.

**Status:** preparação do banco e auditoria de qualidade concluídas no escopo definido. **Fase atual: análise exploratória com SQL.**

## Tecnologias

- **Utilizadas:** PostgreSQL 16, SQL, DBeaver, Docker, Ubuntu Server, Git e GitHub.
- **Planejadas para as próximas fases:** Python (pandas e bibliotecas de ML) e Power BI.

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
   Análise exploratória SQL
         |
         +--> Python / análises e validações
         +--> Power BI / dashboard
         `--> Machine Learning / experimento
```

A ingestão inicial foi realizada via DBeaver. O banco é executado em servidor próprio com Docker, com acesso remoto por túnel SSH. Os CSVs originais e as credenciais não são versionados.

## Resultados alcançados

- **9 tabelas** carregadas na camada `raw` (**1.550.922 linhas somadas**, não pedidos únicos) e transformadas na camada `analytics`.
- Tipos adequados, chaves primárias e relacionamentos implementados nas tabelas analíticas.
- **261.831 ocorrências excedentes** removidas de `geolocation` com deduplicação por combinação de cinco atributos; **738.332 registros** na camada analítica.
- **610 categorias vazias** em `products` normalizadas para `NULL`.
- **2 categorias** acrescentadas à referência analítica para preservar o relacionamento com produtos, com tradução não disponível mantida como `NULL`.
- Auditoria de **reconciliação e completude das 9 tabelas** documentada. Foram identificadas ausências em datas operacionais de pedidos e strings vazias em comentários de avaliações, sem correções arbitrárias.

> **Escopo da auditoria:** as verificações realizadas não equivalem a uma certificação completa de unicidade, consistência de negócio ou integridade de todos os atributos. Novas investigações ocorrerão apenas quando relevantes para os indicadores.

## Roadmap e entregáveis

| Fase | Entrega | Situação |
|---|---|---|
| 1. Banco e transformação | PostgreSQL, schemas, carga e modelagem relacional | Concluída |
| 2. Qualidade dos dados | Reconciliação RAW × Analytics e completude | Concluída no escopo definido |
| 3. EDA com SQL | **20 perguntas de negócio**, KPIs e insights documentados | **Em andamento — próxima execução** |
| 4. Python | Reproduzir e validar análises selecionadas | Planejada |
| 5. Power BI | Dashboard executivo com métricas consistentes | Planejada |
| 6. Machine Learning | Problema preditivo, avaliação e limitações | Planejada |

A EDA tem escopo fechado: pedidos, receita, produtos, clientes, vendedores, pagamentos, logística e avaliações. Os critérios de conclusão estão no [roadmap de EDA SQL](ROADMAP_EDA_SQL.md).

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
  05_eda_sql/             # consultas analíticas (planejado)
docs/                     # documentação e resultados
images/                   # diagramas e figuras
README.md
PLANO_PROJETO.md
ROADMAP_EDA_SQL.md
```

## Documentação

- [Plano geral do projeto](PLANO_PROJETO.md)
- [Roadmap e perguntas da EDA SQL](ROADMAP_EDA_SQL.md)
- [Relatório de qualidade dos dados](docs/data_quality_report.md)

## Reprodução do ambiente

1. Baixar os nove CSVs no [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) e armazená-los em `data/raw/`.
2. Executar os scripts de `sql/01_setup/` conforme suas dependências.
3. Importar os CSVs para `raw` via DBeaver e validar as cargas com `sql/02_profiling/`.
4. Executar `sql/03_transformation/` na ordem definida pelos scripts.
5. Consultar `sql/04_data_quality/` e a documentação para reproduzir as validações.

**Nota:** a automação da ingestão em Python e o dashboard ainda não foram implementados; constam das próximas fases do projeto.
