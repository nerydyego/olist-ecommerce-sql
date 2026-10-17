# Olist Brazilian E-Commerce — Documentação técnica inicial

**Versão:** 0.2 · **Atualização:** 17/10/2026 · **Estado:** parcial / contínuo  
**Repositório:** https://github.com/nerydyego/olist-ecommerce-sql  
**Banco:** `olist_ecommerce` · **SGBD:** PostgreSQL 16 · **Ambiente:** PostgreSQL em Docker, servidor doméstico Ubuntu

> **Critério de confiabilidade:** os itens marcados **Confirmado** foram relatados como concluídos no projeto; itens **A validar** dependem de inspeção dos scripts ou do catálogo do banco. Não confundir relacionamentos conceituais do dataset com constraints efetivamente instaladas.

## 1. Objetivo e escopo

Construir um projeto de portfólio de ponta a ponta com o dataset público **Olist Brazilian E-Commerce**, demonstrando competências em ingestão, SQL, modelagem relacional, auditoria de dados, análise exploratória, Python, Power BI e, posteriormente, Machine Learning.

**Escopo desta versão:** arquitetura do banco, organização dos scripts, inventário de tabelas, relacionamentos de referência, dicionário de dados inicial e registro de decisões técnicas. A auditoria complementar é a próxima etapa, não um resultado já concluído.

## 2. Arquitetura de dados

```text
Arquivos CSV originais (9 datasets)
             |
             v
      PostgreSQL / raw
  Ingestão e preservação dos dados
             |
             v
    PostgreSQL / analytics
 Tipagem, transformação e integridade
             |
       +-----+------------------+
       |                        |
       v                        v
  Auditoria e EDA SQL      Análise em Python
       |                        |
       +------------+-----------+
                    |
                    v
           Power BI / indicadores
                    |
                    v
         Machine Learning (fase futura)
```

### 2.1 Ambiente e acesso

| Componente | Configuração / função | Situação |
|---|---|---|
| Host | Servidor doméstico Ubuntu 24.04 LTS | Confirmado |
| Banco | `olist_ecommerce`, PostgreSQL 16 | Confirmado |
| Container | `postgres_lab` | Confirmado |
| Schemas | `raw` e `analytics` | Confirmado |
| Cliente SQL | DBeaver | Confirmado |
| Acesso remoto | Túnel SSH com encaminhamento local da porta 5433 para `127.0.0.1:5433` no servidor | Confirmado |
| Controle de versão | Git + GitHub, branch `main` | Confirmado |

**Segurança:** não registrar senhas, tokens, credenciais SSH nem arquivos `.env` com segredos no repositório. O acesso ao PostgreSQL ocorre por túnel SSH, sem necessidade de expor a porta do banco à internet.

### 2.2 Responsabilidades das camadas

**`raw` — ingestão e rastreabilidade.** Guarda os registros importados dos CSVs com mínima intervenção. A tabela `raw.customers`, por exemplo, foi criada com cinco colunas `text`, todas inicialmente anuláveis. A preservação dos dados de origem permite reconciliar volumes e investigar alterações.

**`analytics` — dados tipados e relacionáveis.** Contém as tabelas transformadas e preparadas para consultas. A criação das nove tabelas, conversão de tipos e implementação de chaves primárias e estrangeiras foram reportadas como concluídas. A definição exata de cada constraint e seus nomes devem ser extraídos do catálogo PostgreSQL e registrados na próxima revisão.

**Camada analítica de consumo — planejada.** Consultas SQL, notebooks Python, modelo semântico Power BI e experimentos de ML serão desenvolvidos após auditoria e EDA. Não presumir que já exista um modelo dimensional em estrela.

## 3. Inventário das fontes e tabelas

O projeto utiliza nove arquivos CSV do dataset Olist. A correspondência de nomes abaixo representa a convenção lógica de tabelas; confirmar os nomes físicos e o número de registros em ambas as camadas durante a auditoria.

| Tabela lógica | Conteúdo | Chave lógica principal / observação |
|---|---|---|
| `customers` | Identificação e localização dos clientes | `customer_id`; `customer_unique_id` pode repetir |
| `orders` | Pedidos, status e datas | `order_id` |
| `order_items` | Itens, vendedores, preços e frete | Chave composta conceitual: `order_id`, `order_item_id` |
| `order_payments` | Pagamentos por pedido | Um pedido pode ter múltiplas parcelas/registros de pagamento |
| `order_reviews` | Avaliações de pedidos | Verificar cardinalidade real antes de definir unicidade |
| `products` | Produtos e atributos | `product_id` |
| `sellers` | Vendedores e localização | `seller_id` |
| `geolocation` | Coordenadas e CEPs | CEP não é identificador único da tabela |
| `product_category_name_translation` | Tradução de categorias | `product_category_name` como referência lógica |

**Evidência quantitativa já documentada:** `raw.customers` possui **99.441 registros**; `customer_id` apresenta **99.441 valores distintos**; `customer_unique_id` apresenta **96.096 valores distintos**. A repetição de `customer_unique_id` é esperada na interpretação de clientes com pedidos diferentes e não deve ser tratada automaticamente como erro.

## 4. Relacionamentos conceituais

```text
customers (customer_id) 1 ─── N orders (customer_id)
orders (order_id)       1 ─── N order_items (order_id)
orders (order_id)       1 ─── N order_payments (order_id)
orders (order_id)       1 ─── N order_reviews (order_id) [validar]
products (product_id)   1 ─── N order_items (product_id)
sellers (seller_id)     1 ─── N order_items (seller_id)
product_category_name_translation (product_category_name)
                        1 ─── N products (product_category_name) [validar cobertura]
```

**Observações de modelagem:**

- `customer_id` identifica o registro de cliente vinculado ao pedido; `customer_unique_id` representa a identidade recorrente do consumidor. Não substituir uma chave pela outra sem avaliar o grão.
- `order_items` tem grão de item do pedido, não de pedido; agregações por pedido devem considerar essa diferença.
- `order_payments` e `order_reviews` podem apresentar multiplicidade por pedido. Junções simultâneas entre tabelas de detalhe podem multiplicar linhas e inflar valores.
- `geolocation` pode ter várias linhas para o mesmo prefixo de CEP. Uma junção direta com clientes ou vendedores pode gerar duplicação; definir previamente uma regra de agregação ou deduplicação.
- As ligações acima são **referências conceituais**; as FKs efetivamente existentes e suas ações (`ON DELETE`, `ON UPDATE`) serão catalogadas a partir do banco.

## 5. Dicionário de dados — versão inicial

### 5.1 `raw.customers` — estrutura confirmada

| Campo | Tipo em RAW | Nulabilidade em RAW | Significado |
|---|---|---|---|
| `customer_id` | `text` | `YES` | Identificador do registro de cliente associado ao pedido |
| `customer_unique_id` | `text` | `YES` | Identificador recorrente do consumidor |
| `customer_zip_code_prefix` | `text` | `YES` | Prefixo do CEP do cliente |
| `customer_city` | `text` | `YES` | Cidade informada |
| `customer_state` | `text` | `YES` | UF informada |

**Nota:** `YES` descreve a definição inicial da tabela RAW, não a presença efetiva de nulos. Tipos e restrições da versão `analytics.customers` precisam ser conferidos no banco.

### 5.2 Campos de referência das demais entidades — a validar

| Entidade | Campos relevantes para a documentação |
|---|---|
| `orders` | `order_id`, `customer_id`, `order_status`, `order_purchase_timestamp`, `order_approved_at`, `order_delivered_carrier_date`, `order_delivered_customer_date`, `order_estimated_delivery_date` |
| `order_items` | `order_id`, `order_item_id`, `product_id`, `seller_id`, `shipping_limit_date`, `price`, `freight_value` |
| `order_payments` | `order_id`, `payment_sequential`, `payment_type`, `payment_installments`, `payment_value` |
| `order_reviews` | `review_id`, `order_id`, `review_score`, `review_comment_title`, `review_comment_message`, `review_creation_date`, `review_answer_timestamp` |
| `products` | `product_id`, `product_category_name`, `product_name_lenght`, `product_description_lenght`, `product_photos_qty`, `product_weight_g`, `product_length_cm`, `product_height_cm`, `product_width_cm` |
| `sellers` | `seller_id`, `seller_zip_code_prefix`, `seller_city`, `seller_state` |
| `geolocation` | `geolocation_zip_code_prefix`, `geolocation_lat`, `geolocation_lng`, `geolocation_city`, `geolocation_state` |
| `product_category_name_translation` | `product_category_name`, `product_category_name_english` |

Os nomes acima são referências usuais dos arquivos Olist, **não um inventário validado das colunas implementadas**. Preservar a grafia original de `lenght` nos arquivos de origem; se houver renomeação em `analytics`, documentar o mapeamento origem → destino.

**Para completar o dicionário**, registrar por coluna: schema, tabela, nome, tipo SQL, nulabilidade, chave, descrição de negócio, transformação aplicada, regra de qualidade e exemplo não sensível.

## 6. Organização dos scripts SQL

### 6.1 Estrutura atual do projeto (confirmada pelo responsável)

A estrutura de diretórios SQL **já existe** e deve ser preservada, inclusive sua numeração:

```text
sql/
├── 01_setup/             # Configuração inicial do banco e objetos de infraestrutura
├── 02_profiling/         # Exploração inicial e perfilamento dos dados
├── 03_transformation/    # Transformações e estruturação da camada analytics
└── 04_data_quality/     # Auditoria complementar de qualidade — etapa atual
```

O script `01_create_database.sql` foi registrado na etapa de setup. Os demais nomes de arquivos devem ser inventariados diretamente no repositório; esta documentação não presume nomes ou caminhos não verificados.

### 6.2 Organização existente — manter sem renumeração

```text
olist-ecommerce-sql/
├── README.md
├── docs/
│   └── DOCUMENTACAO_TECNICA_OLIST.md
├── sql/
│   ├── 01_setup/
│   ├── 02_profiling/
│   ├── 03_transformation/
│   └── 04_data_quality/
├── data/
│   ├── raw/
│   └── processed/
└── images/
```

**Diretriz de manutenção:** não criar `02_raw_tables`, `03_load_raw`, `04_analytics`, `05_data_quality` ou `06_eda` como substitutos dos diretórios atuais. Não mover nem renomear scripts já existentes apenas para seguir uma organização teórica: isso poderia invalidar referências, histórico e instruções anteriores.

**Como documentar os scripts:** dentro de cada pasta existente, manter um inventário dos arquivos efetivamente presentes, contendo nome, objetivo, objetos afetados, dependências, ordem de execução e validação. Registrar os scripts de criação e carga no diretório em que **já se encontram**, sem inferir sua localização a partir do assunto. Novas análises e scripts devem seguir a organização existente; eventual ampliação será decidida e registrada antes de criar novas pastas.

**Etapa atual:** `sql/04_data_quality/`, destinada às verificações complementares de qualidade após a transformação e aplicação de restrições em `analytics`.

## 7. Registro de decisões arquiteturais

| ID | Decisão | Justificativa | Estado |
|---|---|---|---|
| ADR-001 | Um banco `olist_ecommerce` com schemas `raw` e `analytics` | Separar ingestão e dados tratados sem multiplicar bancos | Adotada |
| ADR-002 | Preservar dados de origem na RAW | Rastreabilidade e reconciliação | Adotada |
| ADR-003 | Criar tabelas e carregar CSVs antes do profiling aprofundado | Desenvolvimento incremental e aprendizado orientado a etapas | Adotada |
| ADR-004 | Tipagem e constraints na Analytics | Integridade relacional e preparação analítica | Implementação reportada; detalhes a catalogar |
| ADR-005 | Manter scripts SQL no GitHub e CSVs brutos fora do versionamento | Reprodutibilidade com repositório leve | Adotada |
| ADR-006 | Realizar auditoria antes da EDA | Conhecer limitações e confiabilidade das análises | Próxima etapa |
| ADR-007 | Construir dashboards e ML somente após análises e definição de métricas | Evitar modelagem prematura e retrabalho | Planejada |

## 8. Critérios de qualidade e pontos de atenção

A auditoria complementar deve cobrir: (1) contagem e reconciliação RAW × Analytics; (2) nulos e unicidade; (3) órfãos e integridade referencial; (4) faixas e domínios válidos; (5) coerência temporal de pedidos, pagamentos e entregas; (6) valores monetários e possíveis duplicações por junções; (7) rastreabilidade de registros excluídos ou alterados. Cada achado deve incluir consulta, resultado quantitativo, impacto e decisão: aceitar, corrigir, excluir ou investigar.

**Regra:** anomalia não equivale automaticamente a erro. Não alterar dados sem justificar a regra de negócio e medir seu efeito.

## 9. Plano de atualização da documentação

| Marco | Evidência a acrescentar | Critério de conclusão |
|---|---|---|
| Auditoria (Etapa 5) | Contagens das 9 tabelas, indicadores de qualidade e exceções | Resultados reprodutíveis e decisões registradas |
| Catálogo físico | DDL efetiva, tipos, PK, FK, índices e constraints | Correspondência com o catálogo do PostgreSQL |
| EDA SQL | Perguntas de negócio, consultas e resultados | Insights verificáveis e sem duplicação de métricas |
| Python | Notebooks, dependências e fluxo de conexão/extração | Execução reproduzível |
| Power BI | Modelo semântico, medidas DAX e páginas | Indicadores conciliados com SQL |
| Machine Learning | Problema, target, features, split, baseline e métricas | Experimento documentado e avaliação sem vazamento |
| Encerramento | README final, arquitetura atualizada e limitações | Portfólio navegável e reproduzível |

## 10. Checklist de documentação mínima

- [x] Objetivo do projeto e tecnologias principais.
- [x] Diagrama lógico RAW → Analytics → consumo.
- [x] Inventário conceitual das nove tabelas.
- [x] Relacionamentos conceituais e alertas de cardinalidade.
- [x] Dicionário confirmado de `raw.customers`.
- [x] Estrutura real dos diretórios SQL preservada e documentada.
- [x] Registro inicial das decisões arquiteturais.
- [ ] Inventário físico completo de todas as colunas e tipos de `analytics`.
- [ ] Listagem verificada de PKs, FKs, índices e ações referenciais.
- [ ] Contagens reconciliadas das nove tabelas RAW e Analytics.
- [ ] Diagrama entidade-relacionamento fiel ao banco implementado.
- [ ] Resultados e recomendações da auditoria da Etapa 5.

---

**Próxima ação:** iniciar a Etapa 5 pela reconciliação de registros RAW × Analytics. Atualizar esta documentação após cada bloco validado; não antecipar como concluídas atividades ainda não executadas.
