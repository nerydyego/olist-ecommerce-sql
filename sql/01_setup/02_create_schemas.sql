/*
============================================================
Projeto: Olist Brazilian E-Commerce Dataset
Etapa: 02 - Preparação do PostgreSQL
Arquivo: 02_create_schema.sql

Objetivo:
Criar 2 schema no banco de dados exclusivo do projeto Olist, raw - dados brutos, analytics - transformação.
============================================================
*/
create schema if not exists raw;

create schema if not exists analytics;