/*
============================================================
Projeto: Olist Brazilian E-Commerce Dataset
Etapa: 02 - Preparação do PostgreSQL
Arquivo: 03_create_raw_tables.sql

Objetivo:
Criar as tabelas da camada RAW para receber os dados
originais provenientes dos arquivos CSV do Olist.

Observação:
A camada RAW será mantida próxima à fonte, sem aplicação
inicial de regras de limpeza, PKs ou FKs.
============================================================
*/


-- =========================================================
-- CUSTOMERS
-- Fonte: olist_customers_dataset.csv
-- =========================================================

CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id              TEXT,
    customer_unique_id       TEXT,
    customer_zip_code_prefix TEXT,
    customer_city            TEXT,
    customer_state           TEXT
);