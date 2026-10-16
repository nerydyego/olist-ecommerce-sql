# Olist Brazilian E-Commerce \| SQL & PostgreSQL

Projeto de portfólio em **SQL, modelagem relacional e preparação de
dados**, utilizando o [Brazilian E-Commerce Public Dataset by
Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). A
base foi implantada em PostgreSQL, com separação entre dados originais e
dados tratados para futuras análises de negócio.

**Status:** ingestão, transformação e relacionamentos das nove tabelas
concluídos. Projeto em desenvolvimento: qualidade de dados e análises
exploratórias são as próximas etapas.

## Tecnologias e competências

-   **PostgreSQL 16 / SQL:** criação de banco e schemas, conversão de
    tipos, `JOIN`, agregações, chaves primárias e estrangeiras.
-   **DBeaver:** importação de CSVs, execução e validação de scripts.
-   **Docker / Ubuntu Server:** PostgreSQL em servidor próprio, acessado
    remotamente por túnel SSH.
-   **Qualidade de dados:** verificação de contagens, tratamento de
    valores ausentes, deduplicação e integridade referencial.
-   **Git / GitHub:** versionamento dos scripts e documentação.

## Dataset e arquitetura

**Fonte:** [Olist ---
Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
São nove arquivos CSV sobre pedidos, clientes, itens, pagamentos,
avaliações, produtos, vendedores, geolocalização e categorias.

``` text
CSVs Olist
    |
    v
PostgreSQL: olist_ecommerce
    |
    +-- raw        -> dados originais preservados (colunas importadas como TEXT)
    +-- analytics  -> tipos adequados, tratamentos e integridade relacional
```

A camada `raw` permite auditoria e reprocessamento; `analytics`
concentra as transformações, sem alterar os arquivos de origem.

## Etapas realizadas

1.  Criação do banco `olist_ecommerce`, dos schemas `raw` e `analytics`
    e importação dos nove CSVs via DBeaver.
2.  Validação das cargas, inspeção de identificadores, valores ausentes
    e duplicidades.
3.  Criação das **nove tabelas** em `analytics`, com conversão de tipos
    (`INTEGER`, `NUMERIC`, `TIMESTAMP` e texto, conforme o atributo).
4.  Definição de **chaves primárias simples e compostas** e **chaves
    estrangeiras** para os relacionamentos entre as tabelas pertinentes.
5.  Deduplicação de `geolocation`: **1.000.163** linhas na origem e
    **738.332** registros distintos em `analytics` (**261.831**
    ocorrências duplicadas removidas); criação de identificador
    `BIGINT GENERATED ALWAYS AS IDENTITY`.
6.  Normalização de **610** categorias vazias de produtos para `NULL`
    exclusivamente em `analytics`.
7.  Complementação da referência de categorias com **duas categorias
    existentes nos produtos**, mantendo a tradução em inglês como
    `NULL`, sem inventar traduções.
8.  Validação de **zero produtos com categoria não nula sem
    correspondência** e criação da chave estrangeira entre produtos e
    categorias.

### Volumes da ingestão

  Tabela (`raw`)                              Registros
  ------------------------------------- ---------------
  `customers`                                    99.441
  `orders`                                       99.441
  `order_items`                                 112.650
  `order_payments`                              103.886
  `order_reviews`                                99.224
  `products`                                     32.951
  `sellers`                                       3.095
  `geolocation`                               1.000.163
  `product_category_name_translation`                71
  **Total**                               **1.550.922**

*O total é a soma de linhas das tabelas de origem, não a quantidade de
pedidos únicos. A camada `analytics` apresenta volumes diferentes nas
tabelas tratadas.*

### Indicadores de validação

  Indicador                                               Resultado
  ----------------------------------------------------- -----------
  Produtos preservados em `analytics.products`               32.951
  Categorias de produtos normalizadas para `NULL`               610
  Categorias na referência após complementação                   73
  Produtos com categoria não nula sem correspondência             0
  Registros distintos em `analytics.geolocation`            738.332

## Estrutura do repositório

``` text
.
├── data/
│   ├── raw/                  # CSVs originais (não versionados)
│   └── processed/            # reservado para dados derivados
├── docs/                     # documentação complementar
├── images/                   # diagramas e imagens
├── sql/
│   ├── 01_setup/             # banco, schemas e tabelas raw
│   ├── 02_profiling/         # validações iniciais
│   └── 03_transformation/    # tabelas analytics, tratamento e restrições
├── .gitignore
└── README.md
```

## Como reproduzir

1.  Baixe os CSVs do
    [Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
    e coloque-os em `data/raw/`.
2.  Execute os scripts de `sql/01_setup/` para criar banco, schemas e
    tabelas de origem.
3.  Importe os CSVs para `raw` utilizando o DBeaver e valide as
    contagens com `sql/02_profiling/`.
4.  Execute os scripts de `sql/03_transformation/` **em ordem
    numérica**, respeitando dependências entre tabelas, cargas,
    tratamentos e restrições.

**Nota:** a ingestão foi manual via DBeaver; sua automação ainda não foi
implementada. CSVs e credenciais não são versionados.

## Próximas etapas

-   Aprofundar verificações de qualidade e documentar regras de negócio.
-   Desenvolver consultas analíticas com `JOIN`, agregações, CTEs e
    funções de janela.
-   Analisar vendas, clientes, produtos, pagamentos e entregas.
-   Expandir o projeto com Python e dashboards em Power BI.
