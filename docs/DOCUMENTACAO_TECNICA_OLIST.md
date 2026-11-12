# Olist Brazilian E-Commerce — Documentação técnica inicial

**Versão:** 0.3 · **Atualização:** 12/11/2026 · **Estado:** documentação evolutiva; EDA SQL e Python concluídas  
**Repositório:** https://github.com/nerydyego/olist-ecommerce-sql  
**Banco:** `olist_ecommerce` · **SGBD:** PostgreSQL 16 · **Ambiente:** PostgreSQL em Docker, servidor doméstico Ubuntu

> **Critério de confiabilidade:** os itens marcados **Confirmado** foram relatados como concluídos no projeto; itens **A validar** dependem de inspeção dos scripts ou do catálogo do banco. Não confundir relacionamentos conceituais do dataset com constraints efetivamente instaladas.

## 1. Objetivo e escopo

Construir um projeto de portfólio de ponta a ponta com o dataset público **Olist Brazilian E-Commerce**, demonstrando competências em ingestão, SQL, modelagem relacional, auditoria de dados, análise exploratória, Python, Power BI e, posteriormente, Machine Learning.

**Escopo desta versão:** arquitetura do banco, organização dos scripts, inventário de tabelas, relacionamentos de referência, dicionário de dados inicial, decisões técnicas e resultados das etapas de qualidade, EDA SQL e EDA Python. O catálogo físico completo de constraints permanece pendente de verificação.

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

**Camada analítica de consumo — parcialmente implementada.** As consultas de EDA SQL (Q01–Q20) e os notebooks de EDA Python já foram desenvolvidos. O modelo semântico Power BI e os experimentos de ML permanecem planejados. Não presumir que já exista um modelo dimensional em estrela.

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
├── 04_data_quality/     # Auditoria de qualidade concluída no escopo
└── 05_eda_sql/          # EDA SQL Q01–Q20 concluída
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
│   ├── 04_data_quality/
│   └── 05_eda_sql/
├── notebooks/            # EDA Python: notebooks 01 e 02
├── src/                  # Conexão PostgreSQL (database.py)
├── data/
│   ├── raw/
│   └── processed/
└── images/
```

**Diretriz de manutenção:** não criar `02_raw_tables`, `03_load_raw`, `04_analytics`, `05_data_quality` ou `06_eda` como substitutos dos diretórios atuais. Não mover nem renomear scripts já existentes apenas para seguir uma organização teórica: isso poderia invalidar referências, histórico e instruções anteriores.

**Como documentar os scripts:** dentro de cada pasta existente, manter um inventário dos arquivos efetivamente presentes, contendo nome, objetivo, objetos afetados, dependências, ordem de execução e validação. Registrar os scripts de criação e carga no diretório em que **já se encontram**, sem inferir sua localização a partir do assunto. Novas análises e scripts devem seguir a organização existente; eventual ampliação será decidida e registrada antes de criar novas pastas.

**Etapas concluídas:** `sql/04_data_quality/` (auditoria no escopo definido), `sql/05_eda_sql/` (20 questões) e EDA Python A01–A08. **Próxima fase:** Power BI.

## 7. Registro de decisões arquiteturais

| ID | Decisão | Justificativa | Estado |
|---|---|---|---|
| ADR-001 | Um banco `olist_ecommerce` com schemas `raw` e `analytics` | Separar ingestão e dados tratados sem multiplicar bancos | Adotada |
| ADR-002 | Preservar dados de origem na RAW | Rastreabilidade e reconciliação | Adotada |
| ADR-003 | Criar tabelas e carregar CSVs antes do profiling aprofundado | Desenvolvimento incremental e aprendizado orientado a etapas | Adotada |
| ADR-004 | Tipagem e constraints na Analytics | Integridade relacional e preparação analítica | Implementação reportada; detalhes a catalogar |
| ADR-005 | Manter scripts SQL no GitHub e CSVs brutos fora do versionamento | Reprodutibilidade com repositório leve | Adotada |
| ADR-006 | Realizar auditoria antes da EDA | Conhecer limitações e confiabilidade das análises | Concluída no escopo definido |
| ADR-007 | Construir dashboards e ML somente após análises e definição de métricas | Evitar modelagem prematura e retrabalho | EDA concluída; Power BI e ML pendentes |
| ADR-008 | Usar Poetry, `.venv` e `.env` não versionado na EDA Python | Reprodutibilidade e isolamento de dependências/segredos | Adotada |
| ADR-009 | Consolidar múltiplas avaliações por `order_id` pela média antes do merge | Preservar uma linha por pedido e evitar duplicações | Adotada na A08 |
| ADR-010 | Definir atraso pela comparação de datas normalizadas | Entrega no próprio dia previsto conta como no prazo | Adotada na A07 |

## 8. Critérios de qualidade e pontos de atenção

A auditoria complementar deve cobrir: (1) contagem e reconciliação RAW × Analytics; (2) nulos e unicidade; (3) órfãos e integridade referencial; (4) faixas e domínios válidos; (5) coerência temporal de pedidos, pagamentos e entregas; (6) valores monetários e possíveis duplicações por junções; (7) rastreabilidade de registros excluídos ou alterados. Cada achado deve incluir consulta, resultado quantitativo, impacto e decisão: aceitar, corrigir, excluir ou investigar.

**Regra:** anomalia não equivale automaticamente a erro. Não alterar dados sem justificar a regra de negócio e medir seu efeito.

## 9. Plano de atualização da documentação

| Marco | Evidência a acrescentar | Critério de conclusão |
|---|---|---|
| Auditoria (Etapa 5) | Contagens das 9 tabelas, indicadores de qualidade e exceções | Concluída no escopo definido; consultar relatório de qualidade |
| Catálogo físico | DDL efetiva, tipos, PK, FK, índices e constraints | Correspondência com o catálogo do PostgreSQL |
| EDA SQL | Perguntas de negócio, consultas e resultados | Concluída (Q01–Q20) |
| Python | Notebooks, dependências e fluxo de conexão/extração | EDA A01–A08 e C01 concluídas; execução limpa do notebook a confirmar |
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
- [x] Contagens reconciliadas das nove tabelas RAW e Analytics, com exceções documentadas.
- [ ] Diagrama entidade-relacionamento fiel ao banco implementado.
- [x] Resultados e recomendações da auditoria no escopo definido.

---

**Próxima ação:** preparar o dashboard Power BI a partir das métricas já definidas. Confirmar a execução limpa do notebook 02 e catalogar constraints físicas apenas quando necessário, sem reabrir a auditoria.

## 11. EDA SQL e Python — implementação e resultados (12/11/2026)

### 11.1 Etapas concluídas

- **EDA SQL:** 20 questões de negócio concluídas, com consultas em `sql/05_eda_sql/` e resultados documentados em `docs/eda_sql_resultados.md`.
- **EDA Python:** `notebooks/01_exploracao_inicial.ipynb` e `notebooks/02_analise_exploratoria.ipynb`, utilizando Python 3.12, Poetry, pandas, SQLAlchemy e Matplotlib/Seaborn.
- **Conexão:** `src/database.py` cria o `engine` SQLAlchemy com variáveis de ambiente lidas do `.env`. O PostgreSQL permanece acessível por túnel SSH.
- **Escopo do notebook 02:** A01 indicadores comerciais; A02 evolução mensal; A03 top 10 categorias; A04 concentração de categorias; A05 vendas por UF do cliente; A06 tempo de entrega; A07 atrasos; A08 atrasos versus avaliações; C01 síntese final.

### 11.2 Indicadores e regras de negócio

| Indicador | Resultado | Definição / base |
|---|---:|---|
| Pedidos entregues | 96.478 | `orders.order_status = 'delivered'` |
| Itens vendidos | 110.197 | Registros de `order_items` associados a pedidos entregues |
| Valor dos produtos | R$ 13.221.498,11 | Soma de `order_items.price`, sem frete |
| Frete | R$ 2.198.275,64 | Soma de `order_items.freight_value` |
| Produtos + frete | R$ 15.419.773,75 | Soma dos dois componentes |
| Ticket médio com frete | R$ 159,83 | (Produtos + frete) / pedidos entregues |
| Maior mês de vendas de produtos | 2017-11: R$ 987.765,37 | Agregação por mês da compra |
| Participação das 10 categorias líderes | 62,43% | Participação na receita de produtos |
| Maior UF por receita de produtos | SP: R$ 5.067.633,16 | UF do cliente |
| Pedidos entregues com datas logísticas válidas | 96.470 | Excluídos 8 sem data efetiva de entrega |
| Tempo médio de entrega | 12,56 dias | Data de entrega menos data da compra |
| Atrasos (critério Python) | 6.534 (6,77%) | Data efetiva normalizada > data estimada normalizada |
| Pedidos com avaliação na base logística | 95.824 | Junção por `order_id`, após consolidação |
| Nota média — no prazo | 4,29 | Média de `review_score` dos pedidos avaliados |
| Nota média — com atraso | 2,27 | Média de `review_score` dos pedidos avaliados |

**Reconciliação e comparabilidade:** a EDA SQL registrou 7.826 entregas posteriores à data estimada, enquanto a A07 Python encontrou 6.534 atrasos usando **dias de calendário** e 96.470 registros com data de entrega válida. Não tratar os dois valores como equivalentes sem alinhar o predicado temporal e a população elegível.

### 11.3 Granularidade, qualidade e limitações

- `orders` tem grão de **pedido**; `order_items`, de **item**; `order_reviews`, de **avaliação**. As junções devem respeitar essa diferença.
- `analytics.order_reviews` contém 99.224 registros e 98.673 `order_id` distintos, ou seja, 551 avaliações excedentes em relação à unicidade por pedido. A A08 agregou `review_score` por `order_id` com `mean()`, obtendo 98.673 linhas únicas.
- A junção `df_logistica` (96.470 linhas) × avaliações consolidadas foi realizada com `how='left'` e `validate='one_to_one'`; manteve 96.470 pedidos e identificou 646 sem avaliação.
- O cálculo de médias ignora `review_score` ausente. A associação entre atraso e nota inferior é **descritiva**, não causal.
- A análise não certifica todos os atributos do banco, não constitui demonstração contábil de receita e não inclui testes de inferência causal.
- **Reprodutibilidade:** verificar a execução sequencial do notebook 02 em kernel reiniciado com conexão PostgreSQL ativa; essa verificação não foi confirmada nesta atualização.

### 11.4 Artefatos e sequência futura

A documentação comercial permanece em `docs/metricas_negocio.md`; o histórico SQL em `docs/eda_sql_resultados.md`; o roteiro Python em `notebooks/roadmap_eda_python_02.md`. A próxima fase é a modelagem e visualização no Power BI; Machine Learning continua no planejamento.
