🌎 Language: **English** | [Português](README.pt-BR.md)


---

# ✈️ Data Pipeline & Air Accident Analysis (1908–2023)

<p align="center">
  <img src="https://img.shields.io/badge/Status-In_Development-yellow?style=for-the-badge&logo=appveyor" alt="Status">
  <img src="https://img.shields.io/badge/Python-3.10+-blue?style=for-the-badge&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/Jupyter-Notebook-orange?style=for-the-badge&logo=jupyter&logoColor=white" alt="Jupyter">
</p>

This project applies **Data Engineering** concepts and the **Medallion Architecture** to analyze a historical dataset of aviation accidents. The final goal is to transform raw data into an informative Power BI dashboard for aviation analysis.
Developed as part of the **Database Systems 2** course at the University of Brasília (UnB), taught by Professor **Thiago Luiz de Souza Gomes**.

---

<div align="center">
  <img src="https://media.giphy.com/media/yLPIupXMTIz8Q/giphy.gif" alt="Airplane Animation" width="600"/>
</div>

---

## Project Objectives

* **Data Architecture:** Implement a data pipeline (ETL) following the Medallion Architecture (Bronze, Silver, Gold) in a Data Warehouse.
* **Data Quality:** Handle null values, data typing, and cleaning of a historical dataset.
* **Dimensional Modeling:** Structure the Gold layer using a **Star Schema** (Facts and Dimensions) to optimize analytical queries.
* **Business Intelligence:** Build Power BI dashboards to monitor and analyze safety KPIs, manufacturers, and flight phases.

---

## Data Source

We use a historical aviation accident dataset made available on Kaggle. The dataset compiles records from the *National Transportation Safety Board* (NTSB).

* **Dataset:** Airplane Accidents up to 2022
* **Platform:** Kaggle
* **Original Link:** [Access the dataset here](https://www.kaggle.com/datasets/mos3santos/acidentes-de-aviao-at-2023)

---

## Repository Structure

```
Acidentes_Aviao/
├─ Data Layer/
│  ├─ raw/                                # Bronze Layer (raw data)
│  │  ├─ data_raw.csv/                 
│  │  ├─ analytics.ipynb           
│  │  └─ data_dictionary.pdf             
│  │
│  ├─ silver/                             # Silver Layer (processed data)                 
│  │  ├─ ddl_silver.sql
│  │  ├─ analytics.ipynb
│  │  └─ mer_der_dld.pdf
│  │
│  └─ gold/                               # Gold Layer (analytical data)
│     ├─ mer_der_dld.pdf
│     ├─ queries.sql
│     ├─ ddl.sql
│     └─ mnemonics.pdf           
│
├─ Transformer/                           # Transformation / ETL scripts
│  ├─ etl_raw_to_silver.ipynb
│  └─ etl_silver_to_gold.ipynb
│
├─ docker/                                # Docker
│  └─ docker-compose.yml
└─ README.md
```

---

## Technologies Used

* **Language & Analysis:**

  * ![Python](https://img.shields.io/badge/-Python-333?style=flat\&logo=python\&logoColor=yellow)
  * ![Jupyter](https://img.shields.io/badge/-Jupyter-333?style=flat\&logo=jupyter\&logoColor=orange)

* **Database:**

  * ![Postgres](https://img.shields.io/badge/-PostgreSQL-333?style=flat\&logo=postgresql\&logoColor=blue)

* **Infrastructure & Version Control:**

  * ![Docker](https://img.shields.io/badge/-Docker-333?style=flat\&logo=docker\&logoColor=blue)
  * ![Git](https://img.shields.io/badge/-Git-333?style=flat\&logo=git\&logoColor=red)

* **Business Intelligence:**

  * ![PowerBI](https://img.shields.io/badge/-Power%20BI-333?style=flat\&logo=powerbi\&logoColor=yellow)

---

## Team Members – Group 15

<table>
    <tr>
    <td align="center"><a href="https://github.com/CaioDuart3"><img src="https://avatars.githubusercontent.com/u/134105981?v=4" width="200px;" alt=""/><br/><sub><b>Caio Duarte</b></sub></a><br/>
    <td align="center"><a href="https://github.com/HenriqueFontenelle"><img src="https://avatars.githubusercontent.com/u/150608773?v=4" width="200px;" alt=""/><br /><sub><b>Henrique Fontenelle</b></sub></a><br />
    <td align="center"><a href="https://github.com/felixlaryssa"><img src="https://avatars.githubusercontent.com/u/143897458?v=4" width="200px;" alt=""/><br /><sub><b>Laryssa Felix</b></sub></a><br />
    <td align="center"><a href="https://github.com/luisa12ll"><img src="https://avatars.githubusercontent.com/u/194189725?v=4" width="200px;" alt=""/><br /><sub><b>Luisa de Souza</b></sub></a><br />
    <td align="center"><a href="https://github.com/Marjoriemitzi"><img src="https://avatars.githubusercontent.com/u/165108208?v=4" width="200px;" alt=""/><br /><sub><b>Marjorie Mitzi</b></sub></a><br />  
</table>

---

Se quiser, posso:

* adaptar o inglês para um tom **mais acadêmico** ou **mais comercial**,
* revisar termos técnicos (ex: BI / Data Engineering best practices),
* ou ajustar o README para **recrutadores internacionais** ✨
