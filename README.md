# Olist Brazilian E-Commerce — Projeto de Portfólio em SQL

Projeto de portfólio para construir, do zero, um banco de dados PostgreSQL a partir do **Brazilian E-Commerce Public Dataset by Olist** e praticar SQL com dados de um cenário real de comércio eletrônico. Após a etapa de modelagem e análise em SQL, o projeto pretende evoluir para análises complementares em Python.

> **Status:** em desenvolvimento. O projeto cria um banco PostgreSQL individual para o dataset Olist e prevê uma tabela correspondente a cada arquivo CSV. A estrutura inicial do banco, os schemas `raw` e `analytics`, a tabela RAW de clientes e um primeiro script de profiling já estão no repositório. As tabelas correspondentes aos demais CSVs e a carga completa ainda serão desenvolvidas.

## Objetivos

- Criar um banco PostgreSQL individual, dedicado aos dados do projeto Olist.
- Organizar os dados em schemas para separar a camada de origem (`raw`) da camada de análise (`analytics`).
- Criar uma tabela correspondente a cada CSV do dataset e carregar os dados na camada RAW, preservando a estrutura de origem.
- Validar qualidade, consistência e relacionamentos dos dados com SQL.
- Desenvolver consultas e análises de negócio em SQL.
- Em uma etapa futura, ampliar o projeto com análise de dados em Python.

## Dataset

O projeto utiliza o dataset público da Olist, que reúne dados de pedidos, clientes, itens, pagamentos, avaliações, produtos, vendedores, geolocalização e tradução de categorias.

Fonte: [Brazilian E-Commerce Public Dataset by Olist — Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).

Os CSVs locais ficam em `data/raw/`. Por serem dados de origem e potencialmente grandes, esse diretório está excluído do Git. Portanto, os arquivos devem ser obtidos separadamente e colocados nessa pasta para executar uma futura carga. O repositório mantém um `.gitkeep` para preservar a estrutura do diretório.

Cada CSV será carregado em sua própria tabela no banco `olist_ecommerce`, mantendo a correspondência entre os arquivos de origem e as tabelas da camada `raw`. A criação dessas tabelas está sendo feita gradualmente; até o momento, `raw.customers` é a tabela definida no projeto.

Arquivos esperados:

| Arquivo | Conteúdo |
| --- | --- |
| `olist_customers_dataset.csv` | Clientes e localização informada |
| `olist_orders_dataset.csv` | Pedidos e datas/status |
| `olist_order_items_dataset.csv` | Itens, produtos, vendedores, preços e frete |
| `olist_order_payments_dataset.csv` | Pagamentos e parcelas |
| `olist_order_reviews_dataset.csv` | Avaliações e comentários |
| `olist_products_dataset.csv` | Produtos, categorias e dimensões |
| `olist_sellers_dataset.csv` | Vendedores e localização |
| `olist_geolocation_dataset.csv` | Coordenadas geográficas por CEP |
| `product_category_name_translation.csv` | Tradução dos nomes de categoria |

## Ambiente

O banco de dados é desenvolvido em PostgreSQL e executado em um servidor doméstico, em um contêiner Docker. O acesso ao servidor é feito por meio de um túnel.

## O que já foi construído

1. `sql/01_setup/01_create_database.sql` cria o banco individual `olist_ecommerce`, dedicado ao projeto.
2. `sql/01_setup/02_create_schemas.sql` cria os schemas:
   - `raw`: destinado aos dados de origem;
   - `analytics`: reservado para transformações e estruturas analíticas futuras.
3. `sql/01_setup/03_create_raw_tables.sql` cria a tabela `raw.customers`, correspondente ao arquivo `olist_customers_dataset.csv`, com as colunas armazenadas inicialmente como `TEXT`. A tabela não define PKs ou FKs e não aplica limpeza, mantendo-se próxima à fonte. As tabelas correspondentes aos outros CSVs ainda serão acrescentadas.
4. `sql/02_profiling/01_customers_profiling.sql` contém verificações de nulos, valores vazios, representações textuais de ausências e registros duplicados para `raw.customers`.

O script de profiling registra como observações preliminares que `customer_id` possui 99.441 valores distintos em 99.441 registros e que os 96.096 valores distintos de `customer_unique_id` podem se repetir entre registros sem que isso signifique duplicidade completa. O script também aponta que não encontrou registros completamente duplicados em `raw.customers`. A relação com pedidos ainda precisa ser validada.

## Estrutura do repositório

```text
.
├── data/
│   ├── raw/                # CSVs originais (não versionados)
│   └── processed/          # espaço reservado para dados derivados
├── docs/                   # documentação futura
├── images/                 # imagens e diagramas futuros
├── sql/
│   ├── 01_setup/           # criação inicial do banco, schemas e tabelas
│   └── 02_profiling/       # consultas de profiling e qualidade
├── .gitignore
└── README.md
```

## Execução atual

Os scripts SQL devem ser executados na ordem abaixo:

1. Conecte-se ao servidor PostgreSQL com um usuário autorizado e execute `sql/01_setup/01_create_database.sql`. A conexão inicial deve estar em outro banco, como `postgres`, pois o banco `olist_ecommerce` ainda será criado.
2. Conecte-se ao banco `olist_ecommerce`.
3. Execute `sql/01_setup/02_create_schemas.sql`.
4. Execute `sql/01_setup/03_create_raw_tables.sql`.
5. Disponibilize os CSVs localmente e carregue `olist_customers_dataset.csv` em `raw.customers` usando a ferramenta de sua preferência.
6. Execute `sql/02_profiling/01_customers_profiling.sql` para inspecionar os dados carregados.

> A carga dos CSVs ainda não está automatizada neste repositório. O script de profiling depende de `raw.customers` já conter dados.

## Próximas etapas

- Criar as tabelas RAW restantes, uma para cada CSV do dataset.
- Definir e documentar uma estratégia reproduzível de carga dos arquivos.
- Conferir contagens, tipos, valores ausentes e consistência após a carga.
- Investigar chaves e relacionamentos entre as entidades.
- Desenvolver a camada `analytics` e consultas para responder perguntas de negócio.
- Acrescentar análises em Python em uma etapa posterior.

## Boas práticas de segurança e versionamento

- Não versionar o conteúdo de `data/raw/` nem credenciais ou arquivos locais de conexão.
- Manter apenas exemplos sem segredos em arquivos de configuração compartilhados.
- Usar um usuário PostgreSQL com permissões adequadas ao projeto, sem expor credenciais nos scripts.