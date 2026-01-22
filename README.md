
# ✈️ Pipeline de Dados & Análise de Acidentes Aéreos (1908-2023)

<p align="center">
  <img src="https://img.shields.io/badge/Status-Em_Desenvolvimento-yellow?style=for-the-badge&logo=appveyor" alt="Status">
  <img src="https://img.shields.io/badge/Python-3.10+-blue?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/Jupyter-Notebook-orange?style=for-the-badge&logo=jupyter&logoColor=white" alt="Jupyter">
</p>

Este projeto aplica conceitos de **Engenharia de Dados** e **Arquitetura de Medalhão (Medallion Architecture)** para analisar um conjunto histórico de dados sobre acidentes de aviação. O objetivo final é transformar dados brutos em um Power BI informativo para análise aérea.
Desenvolvido como parte da disciplina de **Sistemas de Banco de Dados 2** na Universidade de Brasília (UnB), ministrada pelo professor: **Thiago Luiz de Souza Gomes**

---
<div align="center">
  <img src="https://media.giphy.com/media/yLPIupXMTIz8Q/giphy.gif" alt="Animação Avião" width="600"/>
</div>


---

## Objetivos do projeto

- **Arquitetura de Dados:** Implementar pipeline de dados (ETL) seguindo a arquitetura Medallion (Bronze, Silver, Gold) em um Data Warehouse.
- **Qualidade de Dados:** Tratamento de nulos, tipagem e limpeza de um dataset histórico.
- **Modelagem Dimensional:** Estruturação da camada Gold em **Star Schema** (Fatos e Dimensões) para otimizar consultas analíticas.
- **Business Intelligence:** Construção de dashboards no Power BI para monitoramento e análise de KPIs de segurança, fabricantes e fases de voo.

----

## Fonte dos Dados

Utilizamos a base de dados histórica de acidentes aéreos disponibilizada no Kaggle. O dataset compila registros do *National Transportation Safety Board* (NTSB)

* **Dataset:** Acidentes de Avião até 2022
* **Plataforma:** Kaggle
* **Link Original:** [Acesse aqui a base de dados](https://www.kaggle.com/datasets/mos3santos/acidentes-de-aviao-at-2023)
----

## Estrutura do repositório
```
Acidentes_Aviao/
├─ Data Layer/
│  ├─ raw/                                # Camada Bronze (dados brutos)
│  │  ├─ data_raw.csv/                 
│  │  ├─ analytics.ipynb           
│  │  └─ dicionario_de_dados.pdf             
│  │
│  ├─ silver/                             # Camada Silver (dados tratados)                 
|  |  ├─ ddl_silver.sql
|  |  ├─ analytics.ipynb
|  |  └─ mer_der_dld.pdf
│  │
│  └─ gold/                               # Camada Gold (dados analíticos)
│     ├─ mer_der_dld.pdf
|     ├─ consultas.sql
|     ├─ ddl.sql
|     └─ mnemonicos.pdf           
│
├─ Transformer/                           # Scripts de transformação/ETL
│  ├─ etl_raw_to_silver.ipynb
│  └─ etl_silver_to_gold.ipynb
│
├─ docker/                                # Docker
│  └─ docker-compose.yml
└─ README.md

```
----

## Tecnologias Utilizadas

* **Linguagem & Análise:**
    * ![Python](https://img.shields.io/badge/-Python-333?style=flat&logo=python&logoColor=yellow) 
    * ![Jupyter](https://img.shields.io/badge/-Jupyter-333?style=flat&logo=jupyter&logoColor=orange)

* **Banco de Dados:**
    * ![Postgres](https://img.shields.io/badge/-PostgreSQL-333?style=flat&logo=postgresql&logoColor=blue) 

* **Infraestrutura & Versionamento:**
    * ![Docker](https://img.shields.io/badge/-Docker-333?style=flat&logo=docker&logoColor=blue)
    * ![Git](https://img.shields.io/badge/-Git-333?style=flat&logo=git&logoColor=red) 

* **Business Intelligence:**
    * ![PowerBI](https://img.shields.io/badge/-Power%20BI-333?style=flat&logo=powerbi&logoColor=yellow)

----
## Membros da Equipe - Grupo 15

<table>
    <tr>
    <td align="center"><a href="https://github.com/CaioDuart3 "><img src="https://avatars.githubusercontent.com/u/134105981?v=4" width="200px;" alt=""/><br/><sub><b>Caio Duarte</b></sub></a><br/>
            <td align="center"><a href="https://github.com/HenriqueFontenelle"><img src="https://avatars.githubusercontent.com/u/150608773?v=4" width="200px;" alt=""/><br /><sub><b>Henrique Fontenelle</b></sub></a><br />
    <td align="center"><a href="https://github.com/felixlaryssa"><img src="https://avatars.githubusercontent.com/u/143897458?v=4" width="200px;" alt=""/><br /><sub><b>⁠Laryssa Felix</b></sub></a><br />
      <td align="center"><a href="https://github.com/luisa12ll"><img src="https://avatars.githubusercontent.com/u/194189725?v=4" width="200px;" alt=""/><br /><sub><b>Luisa de Souza</b></sub></a><br />
    <td align="center"><a href="https://github.com/Marjoriemitzi"><img src="https://avatars.githubusercontent.com/u/165108208?v=4" width="200px;" alt=""/><br /><sub><b>⁠Marjorie Mitzi</b></sub></a><br />  
</table>




