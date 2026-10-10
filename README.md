# Olist Brazilian E-Commerce | SQL & PostgreSQL

Projeto de portfólio voltado à **Análise de Dados com SQL**, utilizando o [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). O objetivo é estruturar uma base relacional no PostgreSQL, preparar os dados para análises e, nas próximas etapas, explorar indicadores de negócio e integrar Python e Power BI.

**Status:** em desenvolvimento — ingestão e validação inicial da camada `raw` concluídas; preparação da camada `analytics` é a próxima etapa.

## Tecnologias e competências

- **PostgreSQL 16 e SQL:** criação de banco de dados, schemas e tabelas; consultas de validação e exploração.
- **DBeaver:** conexão ao banco, execução de scripts e importação de arquivos CSV.
- **Docker e servidor Linux:** utilização de instância PostgreSQL em ambiente próprio de estudos.
- **Git e GitHub:** versionamento de scripts SQL e documentação técnica.
- **Qualidade de dados:** contagem de registros, investigação inicial de valores ausentes e inspeção de identificadores.

## Dataset

A base pública da Olist reúne informações de pedidos de e-commerce brasileiro, clientes, itens, pagamentos, avaliações, produtos, vendedores, geolocalização e categorias de produtos.

**Fonte:** [Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

Os nove arquivos CSV são mantidos localmente em `data/raw/` e não são versionados neste repositório.

## Arquitetura de dados

```text
CSVs Olist
    |
    v
PostgreSQL: olist_ecommerce
    |
    +-- raw        -> dados de origem preservados, colunas inicialmente em TEXT
    |
    +-- analytics  -> conversão de tipos, tratamento e estruturas para análise (planejado)
```

A camada `raw` preserva os dados importados sem impor chaves ou transformações. A preparação será realizada em tabelas separadas no schema `analytics`, mantendo a origem disponível para conferência e reprocessamento.

## Etapas realizadas

1. Criação do banco dedicado `olist_ecommerce` e dos schemas `raw` e `analytics`.
2. Definição das nove tabelas de origem, com atributos correspondentes aos CSVs e tipo `TEXT`.
3. Importação dos nove arquivos CSV para o PostgreSQL por meio do DBeaver.
4. Validação das cargas com `COUNT(*)` e `UNION ALL`, incluindo identificação da tabela de origem e ordenação com `ORDER BY`.
5. Exploração inicial com `SELECT`, `WHERE`, `LIMIT` e verificações de valores ausentes usando `IS NULL`, `TRIM()` e `IN`.
6. Registro dos scripts SQL e da documentação no repositório.

### Resultado das cargas

| Tabela (`raw`) | Registros |
|---|---:|
| `customers` | 99.441 |
| `orders` | 99.441 |
| `order_items` | 112.650 |
| `order_payments` | 103.886 |
| `order_reviews` | 99.224 |
| `products` | 32.951 |
| `sellers` | 3.095 |
| `geolocation` | 1.000.163 |
| `product_category_name_translation` | 71 |
| **Total** | **1.550.922** |

As contagens foram conferidas após a importação. **Essa validação confirma o volume de linhas, não a integridade completa dos dados.** O total representa a soma dos registros de todas as tabelas, e não pedidos únicos.

### Primeiras verificações de qualidade

- Em `raw.customers`, foram observados **99.441** registros, **99.441** identificadores `customer_id` distintos e **96.096** identificadores `customer_unique_id` distintos; não foram encontradas linhas inteiramente duplicadas nas verificações iniciais.
- Em `raw.orders`, a verificação de `order_delivered_customer_date` com `IS NULL` retornou **0** registros; ao considerar também strings vazias, espaços e representações textuais de ausência, foram identificados **2.965** registros (**aproximadamente 2,98%**). A interpretação desses casos ainda será aprofundada.

## Estrutura do repositório

```text
.
├── data/
│   ├── raw/                  # CSVs originais (não versionados)
│   └── processed/            # reservado para dados derivados
├── docs/                     # documentação complementar
├── images/                   # diagramas e imagens
├── sql/
│   ├── 01_setup/
│   │   ├── 01_create_database.sql
│   │   ├── 02_create_schemas.sql
│   │   └── 03_create_raw_tables.sql
│   └── 02_profiling/         # validações e exploração inicial
├── .gitignore
└── README.md
```

## Como reproduzir a etapa de ingestão

1. Obtenha os CSVs no [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) e coloque-os em `data/raw/`.
2. Execute `sql/01_setup/01_create_database.sql` conectado a um banco administrativo, como `postgres`.
3. Conecte-se ao banco `olist_ecommerce` e execute, na ordem, `02_create_schemas.sql` e `03_create_raw_tables.sql`.
4. Importe cada CSV para a tabela correspondente do schema `raw` utilizando o DBeaver, conferindo cabeçalhos, codificação UTF-8, delimitador e mapeamento de colunas.
5. Execute as consultas de validação em `sql/02_profiling/` e confira as contagens apresentadas acima.

**Nota:** a carga dos CSVs foi realizada manualmente no DBeaver; a automação da ingestão ainda não foi implementada. Os arquivos CSV e as credenciais de acesso não são incluídos no Git.

## Próximas etapas

- Construir tabelas no schema `analytics` com tipos adequados (`TIMESTAMP`, numéricos e texto), preservando `raw`.
- Tratar valores ausentes e inconsistências, avaliar duplicidades e validar relacionamentos.
- Desenvolver consultas analíticas com `JOIN`, agregações, CTEs e funções de janela.
- Investigar indicadores de vendas, clientes, produtos, pagamentos e entregas.
- Evoluir o projeto com visualizações em Power BI e análises em Python.
