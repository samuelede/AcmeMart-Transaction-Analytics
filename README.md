# AcmeMart Transaction Analytics

A centralized, end-to-end data warehouse pipeline to ingest, transform, and analyse retail transaction data. Built for **AcmeMart**, a mid-sized retail and e-commerce company operating both physical stores and an online shopping platform. This project leverages a modern data stack to consolidate fragmented data sources into a single source of truth, enabling self-service analytics and proactive decision-making.

![Google Drive](https://img.shields.io/badge/Google_Drive-4285F4?style=for-the-badge&logo=googledrive&logoColor=white)
![Airbyte](https://img.shields.io/badge/Airbyte-615EFF?style=for-the-badge&logo=airbyte&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

---

## Table of Contents

- [AcmeMart Transaction Analytics](#acmemart-transaction-analytics)
  - [Table of Contents](#table-of-contents)
  - [Project Overview](#project-overview)
    - [Expected Outcomes](#expected-outcomes)
  - [Business Context](#business-context)
  - [Architecture](#architecture)
    - [Data Flow](#data-flow)
  - [Tech Stack](#tech-stack)
  - [Project Structure](#project-structure)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
    - [Step 1 - Clone the repository](#step-1---clone-the-repository)
    - [Step 2 - Configure environment variables](#step-2---configure-environment-variables)
    - [Step 3 - Set up Snowflake](#step-3---set-up-snowflake)
    - [Step 4 - Configure Airbyte](#step-4---configure-airbyte)
      - [4a: Create Google Drive source](#4a-create-google-drive-source)
      - [4b: Create Snowflake destination](#4b-create-snowflake-destination)
      - [4c: Create the connection](#4c-create-the-connection)
      - [4d: Configure the stream](#4d-configure-the-stream)
      - [4e: Set the schedule and finish](#4e-set-the-schedule-and-finish)
      - [4f: Verify first sync](#4f-verify-first-sync)
    - [Step 5 - Install dbt and dependencies](#step-5---install-dbt-and-dependencies)
      - [Install dependencies](#install-dependencies)
      - [Set up dbt profile](#set-up-dbt-profile)
      - [Verify the connection](#verify-the-connection)
    - [Step 6 - Install dbt dependencies](#step-6---install-dbt-dependencies)
  - [Running the Pipeline](#running-the-pipeline)
    - [Step 1 - Trigger Airbyte sync](#step-1---trigger-airbyte-sync)
    - [Step 2 - Run dbt models](#step-2---run-dbt-models)
    - [Step 3 - Run dbt tests](#step-3---run-dbt-tests)
    - [Step 4 - Generate dbt docs](#step-4---generate-dbt-docs)
  - [Data Models](#data-models)
    - [Staging layer](#staging-layer)
    - [Gold layer](#gold-layer)
    - [Aggregate layer](#aggregate-layer)
  - [Environment Variables](#environment-variables)
  - [Learning Outcomes](#learning-outcomes)
  - [Contributing](#contributing)
    - [How to contribute](#how-to-contribute)
    - [Guidelines](#guidelines)
    - [Reporting issues](#reporting-issues)
  - [License](#license)

---

## Project Overview

AcmeMart generates large volumes of transaction data daily across in-store and online channels. This data was previously fragmented across multiple source files in Google Drive with no unified schema, making consistent reporting difficult.

This project addresses those challenges by building a structured batch data pipeline that:

- **Ingests** raw CSV files from Google Drive into Snowflake using Airbyte on a daily schedule
- **Transforms** raw data through staged cleaning, typing, and renaming using dbt
- **Models** data into fact and dimension tables following a star schema
- **Aggregates** key business metrics - sales by product, store performance, customer behaviour trends
- **Validates** data quality through dbt tests at every layer
- **Documents** all models, columns, and lineage via the dbt docs site

### Expected Outcomes

- **Centralised data warehouse** - single source of truth for all retail transaction data
- **Clean fact and dimension tables** - structured, query-ready gold layer
- **Aggregated datasets** - pre-built summaries for reporting and dashboards
- **Improved data quality** - validated through automated dbt tests
- **Faster insight generation** - self-service SQL analytics on Snowflake
- **Reduced manual reporting** - replaces spreadsheet-based processes

---

## Business Context

**Company:** AcmeMart  
**Industry:** Retail & E-commerce  
**Core services:** In-store retail sales, online platform, customer management, supplier & product management

AcmeMart sells a wide range of consumer goods including groceries, household items, and personal care products. With growing transaction volume across multiple channels, the company needed a scalable data foundation to move from reactive reporting to proactive, data-driven decision-making.

**Key challenges this project solves:**

- **Data silos** - source files logically isolated in Google Drive with no integration layer
- **Limited analytics capability** - no unified view of sales by product, store, or customer
- **Manual reporting** - teams relying on spreadsheets causing delays and inconsistencies
- **Poor data quality** - inconsistent data types and formats across source files
- **No scalable data model** - no structured warehouse layer to support analytics

---

## Architecture

![DataMart Architecture](img/dw_arch_diagram.svg)

### Data Flow

| Layer | Tool | Description |
|---|---|---|
| **Source** | Google Drive | Raw CSV files: transactions, customers, products, stores |
| **Ingestion** | Airbyte | Batch connector syncing CSVs to Snowflake BRONZE schema daily |
| **Bronze** | Snowflake | Raw landing zone - untransformed, all columns as VARCHAR |
| **Staging** | dbt | Cleaned, typed, renamed, deduplicated models |
| **Gold** | dbt | Fact and dimension tables following star schema |
| **Aggregates** | dbt | Pre-summarised metrics: sales by store, product, customer |
| **Validation** | dbt tests | not_null, unique, accepted_values, referential integrity |
| **Documentation** | dbt docs | Auto-generated lineage graph and data dictionary |
| **Version control** | Git / GitHub | All dbt models, tests, and schema YAML files |

---

## Tech Stack

| Tool | Purpose |
|---|---|
| **Google Drive** | Source file storage (CSV) |
| **Airbyte** | Data ingestion - Google Drive → Snowflake |
| **Snowflake** | Cloud data warehouse |
| **dbt** | Data transformation, modelling, testing, documentation |
| **Python** | Scripting and pipeline utilities |
| **Git / GitHub** | Version control |

---

## Project Structure

```
acmemart-dbt/
├── models/
│   ├── staging/
│   │   ├── stg_transactions.sql
│   │   ├── stg_customers.sql
│   │   ├── stg_products.sql
│   │   ├── stg_stores.sql
│   │   └── schema.yml
│   ├── gold/
│   │   ├── fct_sales.sql
│   │   ├── dim_customers.sql
│   │   ├── dim_products.sql
│   │   ├── dim_stores.sql
│   │   └── schema.yml
│   └── aggregates/
│       ├── agg_sales_by_store.sql
│       ├── agg_sales_by_product.sql
│       ├── agg_customer_summary.sql
│       └── schema.yml
├── macros/
│   └── clean_string.sql
├── tests/
│   └── assert_positive_amounts.sql
├── dbt_project.yml
├── packages.yml
├── profiles.yml.example       ← template only, never commit real credentials
├── .env.example
├── .gitignore
└── README.md
```

---

## Prerequisites

Ensure the following are in place before proceeding:

- [Snowflake account](https://signup.snowflake.com/) (free trial available)
- [Airbyte Cloud](https://airbyte.com/) account or self-hosted Airbyte instance
- [Google Drive](https://drive.google.com/) folder containing the source CSV files
- [dbt Core](https://docs.getdbt.com/docs/core/installation) installed locally (`pip install dbt-snowflake`)
- [Python 3.9+](https://www.python.org/) with pip
- [Git](https://git-scm.com/)
- [dbt-snowflake](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup) 
  (installed via `requirements.txt` in Step 5)

Verify your dbt installation:

```bash
dbt --version
```

---

## Getting Started

### Step 1 - Clone the repository

```bash
git clone https://github.com/samuelede/AcmeMart-Transaction-Analytics.git
cd acmemart-transaction-analytics
```

### Step 2 - Configure environment variables

Copy the example env file and populate it with your credentials:

```bash
cp .env.example .env
```

Edit `.env` with your Snowflake and Airbyte details:

```
SNOWFLAKE_ACCOUNT=your_account_identifier
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=ACMEMART_DW
SNOWFLAKE_SCHEMA=BRONZE
SNOWFLAKE_ROLE=TRANSFORMER_ROLE
```

> **Important:** Never commit your `.env` file to version control. It is listed in `.gitignore` by default.

### Step 3 - Set up Snowflake

Run the following in a Snowflake worksheet to create the required objects:

```sql
-- Create database and schemas
CREATE DATABASE IF NOT EXISTS ACMEMART_DW;
CREATE SCHEMA IF NOT EXISTS ACMEMART_DW.BRONZE;
CREATE SCHEMA IF NOT EXISTS ACMEMART_DW.STAGING;
CREATE SCHEMA IF NOT EXISTS ACMEMART_DW.GOLD;

-- Create a dedicated role and user for dbt
CREATE ROLE TRANSFORMER_ROLE;
CREATE USER DBT_USER
  PASSWORD = '<strong-password>'
  DEFAULT_ROLE = TRANSFORMER_ROLE;
GRANT ROLE TRANSFORMER_ROLE TO USER DBT_USER;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE TRANSFORMER_ROLE;
GRANT ALL ON DATABASE ACMEMART_DW TO ROLE TRANSFORMER_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE ACMEMART_DW TO ROLE TRANSFORMER_ROLE;
```

### Step 4 - Configure Airbyte

#### 4a: Create Google Drive source

```
1. In Airbyte → Sources → New Source
2. Connector  : Google Drive
3. Name       : AcmeMart - Google Drive
4. Auth       : paste service account JSON key
5. Folder URL : paste the shared Drive folder URL
6. File type  : CSV
7. Click "Test and Save" → confirm green checkmark
```

#### 4b: Create Snowflake destination

```
1. In Airbyte → Destinations → New Destination
2. Connector      : Snowflake
3. Name           : AcmeMart - Snowflake
4. Credentials    : use values from your .env file
5. Database       : ACMEMART_DW
6. Default schema : BRONZE
7. Click "Test and Save" → confirm green checkmark
```

#### 4c: Create the connection

```
1. In Airbyte → Connections → New Connection
2. Source      : AcmeMart - Google Drive
3. Destination : AcmeMart - Snowflake
```

#### 4d: Configure the stream

Airbyte automatically detects all store CSV files from the Drive folder
and combines them into a single stream called **`csv_sales`**.

In the **Select streams** step, configure the stream as follows:

| Setting | Value |
|---|---|
| Stream name | `csv_sales` |
| Sync mode | `Incremental \| Append + Deduped` |
| Primary key | `transaction_id`, `store_id`, `customer_id` |
| Cursor field | `_ab_source_file_last_modified` |

**How to set the primary key:**
```
1. Click the Fields column (13/13) on the csv_sales row
2. In the field panel, tick the primary key checkbox for:
      ✅ transaction_id
      ✅ store_id
      ✅ customer_id
3. Confirm cursor is set to: _ab_source_file_last_modified
4. Click Next → Configure connection
```

> The cursor field `_ab_source_file_last_modified` tells Airbyte which
> files in Google Drive are new since the last sync. Only new or updated
> store files are pulled on each run — not the entire folder every time.

#### 4e: Set the schedule and finish

```
1. Sync schedule : Every 24 hours
2. Destination namespace : ACMEMART_DW.BRONZE
3. Normalisation : Off  (dbt handles all transformation)
4. Click "Set up connection"
```

#### 4f: Verify first sync

Trigger a manual sync and confirm it succeeds:

```
1. Click "Sync Now" on the connection page
2. Wait for status → Succeeded
3. In Snowflake, verify data landed:
```

```sql
SELECT COUNT(*) FROM ACMEMART_DW.BRONZE.CSV_SALES;
```

> Screenshot the Airbyte dashboard showing **Succeeded** status
> and the Snowflake query result showing a non-zero row count.
> These are your **Week 1 deliverables**.

### Step 5 - Install dbt and dependencies

#### Install dependencies

```bash
pip install -r requirements.txt
```

Verify the installation:

```bash
dbt --version
```

---

#### Set up dbt profile

Create the `.dbt` folder and copy the template in one command:

```bash
mkdir -p ~/.dbt && cp profiles.yml.example ~/.dbt/profiles.yml
```

Open the file and fill in your Snowflake credentials:

**Windows (Git Bash):**
```bash
notepad "C:/Users/<YourUsername>/.dbt/profiles.yml"
```

**Mac / Linux:**
```bash
open ~/.dbt/profiles.yml
```

> **`profiles.yml` must never be committed to version control.** Only `profiles.yml.example` lives in the repository. The real file is excluded via `.gitignore`.

---

#### Verify the connection

```bash
dbt debug
```

A successful connection ends with:
```
Connection test: [OK connection ok]
All checks passed!
```


### Step 6 - Install dbt dependencies

```bash
dbt deps
```

---

## Running the Pipeline

### Step 1 - Trigger Airbyte sync

Run a manual sync from the Airbyte UI, or wait for the scheduled daily run. Verify data landed in Snowflake:

```sql
SELECT 'transactions' AS table_name, COUNT(*) AS row_count FROM BRONZE.TRANSACTIONS
UNION ALL
SELECT 'customers', COUNT(*) FROM BRONZE.CUSTOMERS
UNION ALL
SELECT 'products',  COUNT(*) FROM BRONZE.PRODUCTS
UNION ALL
SELECT 'stores',    COUNT(*) FROM BRONZE.STORES;
```

### Step 2 - Run dbt models

```bash
# Run all models (staging → gold → aggregates)
dbt run

# Run a specific layer only
dbt run --select staging
dbt run --select gold
dbt run --select aggregates
```

### Step 3 - Run dbt tests

```bash
# Run all tests
dbt test

# Run tests for a specific model
dbt test --select fct_sales
```

### Step 4 - Generate dbt docs

```bash
dbt docs generate
dbt docs serve
```

Open `http://localhost:8080` in your browser to explore the lineage graph and data dictionary.

---

## Data Models

### Staging layer

| Model | Source | Description |
|---|---|---|
| `stg_transactions` | `BRONZE.TRANSACTIONS` | Cleaned transaction records - typed, deduplicated |
| `stg_customers` | `BRONZE.CUSTOMERS` | Cleaned customer profiles |
| `stg_products` | `BRONZE.PRODUCTS` | Cleaned product catalogue |
| `stg_stores` | `BRONZE.STORES` | Cleaned store reference data |

### Gold layer

| Model | Type | Description |
|---|---|---|
| `fct_sales` | Fact | One row per transaction line item with foreign keys to all dimensions |
| `dim_customers` | Dimension | Customer profiles with loyalty tier and registration data |
| `dim_products` | Dimension | Product catalogue with category, brand, pricing |
| `dim_stores` | Dimension | Store details including type (physical / online), region |

### Aggregate layer

| Model | Description |
|---|---|
| `agg_sales_by_store` | Total revenue, transaction count, and average order value per store |
| `agg_sales_by_product` | Units sold, revenue, and margin per product and category |
| `agg_customer_summary` | Purchase frequency, total spend, and recency per customer |

---

## Environment Variables

The following variables are required in your `.env` file:

| Variable | Description | Example |
|---|---|---|
| `SNOWFLAKE_ACCOUNT` | Snowflake account identifier | `xyz12345.us-east-1` |
| `SNOWFLAKE_USER` | Snowflake username | `dbt_user` |
| `SNOWFLAKE_PASSWORD` | Snowflake password | `securepassword` |
| `SNOWFLAKE_WAREHOUSE` | Compute warehouse name | `COMPUTE_WH` |
| `SNOWFLAKE_DATABASE` | Target database | `ACMEMART_DW` |
| `SNOWFLAKE_SCHEMA` | Default schema | `BRONZE` |
| `SNOWFLAKE_ROLE` | Role with appropriate grants | `TRANSFORMER_ROLE` |

---

## Learning Outcomes

Working through this project builds practical skills in:

- **Data engineering** - designing and operating batch ETL pipelines with Airbyte and Snowflake
- **Data modelling** - applying star schema principles to build fact and dimension tables
- **dbt** - writing staging, gold, and aggregate models; applying tests; generating documentation
- **Data quality** - implementing automated validation using dbt's built-in and custom tests
- **Warehouse design** - structuring bronze / staging / gold layers in Snowflake
- **Version control** - managing a dbt project with Git feature branches and pull requests

---

## Contributing

Contributions are welcome. If you'd like to improve the models, fix a bug, or extend the project with new features, please follow the steps below.

### How to contribute

1. **Fork the repository** - click the Fork button at the top of the GitHub page
2. **Create a feature branch** from `main`:

```bash
git checkout -b feature/your-feature-name
```

3. **Make your changes** and ensure all dbt tests pass before committing:

```bash
dbt run && dbt test
```

4. **Commit with a clear message:**

```bash
git commit -m "feat: describe what your change does"
```

5. **Push your branch:**

```bash
git push origin feature/your-feature-name
```

6. **Open a Pull Request** against `main` with a description of what you changed and why

### Guidelines

- Keep pull requests focused - one feature or fix per PR
- Follow the existing model naming conventions (`stg_`, `fct_`, `dim_`, `agg_`)
- Add or update `schema.yml` tests and column descriptions for any new models
- Do not commit `.env` files or any credentials

### Reporting issues

Found a bug or have a suggestion? Open an issue on the Issues page with as much detail as possible, including steps to reproduce if applicable.

---

## License

This project is licensed under the [MIT License](LICENSE)