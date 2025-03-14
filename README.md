# Retail SCD (Slowly Changing Dimensions) Project

#### This project demonstrates the implementation and testing of various Slowly Changing Dimension (SCD) types using PostgreSQL, pgAdmin, and dbt on macOS.
---
**Slowly Changing Dimensions (SCD) Types**

Slowly Changing Dimensions (SCD) are techniques used in data warehousing to manage and track changes in dimension data over time. They ensure that historical data is accurately preserved, which is crucial for effective analysis and reporting. The primary SCD types include:​

- Type 0 (Retain Original): This method retains the original data without any changes, even if there are updates in the source system. It's suitable when historical accuracy is paramount, and changes are not expected or should be ignored.​

- Type 1 (Overwrite): In this approach, existing data is overwritten with new data, and no historical data is preserved. It's useful when corrections are needed, and historical accuracy is not required.​

- Type 2 (Add New Row): This technique adds a new row for each change, preserving the historical data by assigning a new surrogate key or using effective date ranges. It's commonly used when a full history of data changes is necessary.​

- Type 3 (Add New Attribute): Here, a new column is added to store the previous value of a changing attribute. This method tracks limited history and is useful when only the previous value needs to be retained.​

- Type 4 (Add History Table): This approach involves maintaining a separate history table to track changes, while the main dimension table holds only the current data. It's beneficial when changes are infrequent but historical data is still important.​

- Type 5 (Mini-Dimension with Type 1 Outrigger): This method combines a mini-dimension (Type 4) with a Type 1 reference (outrigger) to the mini-dimension in the base dimension table. It allows for accurate preservation of historical attribute values while enabling reporting of historical facts according to current attribute values. ​

- Type 6 (Hybrid Approach): Also known as a hybrid approach, this method combines techniques from Types 1, 2, and 3 to provide a comprehensive solution for tracking changes, capturing both current and historical data efficiently.

---
## Table of Contents
1. Project Overview
2. Architecture Diagram
3. Prerequisites
4. Setup Instructions
    1. Install PostgreSQL and pgAdmin
    2. Install Python and dbt
    3. Configure dbt
5. Project Structure
6. Initial Data Setup
7. SCD Type 0 Implementation
   - Step 1: Create dbt Model
   - Step 2: Run Initial Load
   - Step 3: Validate Initial Data
   - Step 4: Simulate Data Update
   - Step 5: Run Incremental Load
   - Step 6: Validate Post-Update Data

--- 
### Project Overview
The goal of this project is to practice and validate different Slowly Changing Dimension (SCD) types to manage and track changes in dimensional data over time. This is crucial for maintaining historical accuracy in data warehousing and business intelligence applications.


### Architecture Diagram


### Prerequisites
Before you begin, ensure you have the following installed on your macOS system:

- Homebrew
- PostgreSQL
- pgAdmin
- Python 3
- dbt (Data Build Tool)

  
### Setup Instructions
- Install PostgreSQL and pgAdmin
    Using Homebrew:
    
    ```
    brew update
    brew install postgresql
    brew install --cask pgadmin4
    ```

- Initialize and Start PostgreSQL:

    ```
    Initialize the database (if not already initialized)
    initdb /usr/local/var/postgres
    ```

- Start PostgreSQL service
    ```
    brew services start postgresql
    Set PostgreSQL Password:
    ```
    ```
    psql postgres
    \password postgres
    ```
- Create Database:
    ```
    CREATE DATABASE retail_db;
    ```
- Install Python and dbt
    Install Python 3:
    ```
    brew install python
    ```

- Set Up Virtual Environment:

    ```
    python3 -m venv dbt-env
    source dbt-env/bin/activate
    ```
- Upgrade pip and Install dbt:
    ```
    pip install --upgrade pip
    pip install dbt-postgres
    ```

- Verify dbt Installation:

    ```
    dbt --version
    ```
- Configure dbt
    Create a profiles.yml file in the ~/.dbt/ directory with the following content:
    ```
    retail_scd:
      outputs:
        dev:
          type: postgres
          host: localhost
          user: postgres
          password: your_postgres_password
          port: 5432
          dbname: retail_db
          schema: public
      target: dev
    ```
    Note: Replace your_postgres_password with the password you set for the PostgreSQL postgres user.

### Project Structure

```
retail_scd/
├── analysis/
├── macros/
├── models/
│   ├── dimensions/
│   │   └── customers_type0.sql
│   └── sources.yml
├── seeds/
│   └── customers.csv
├── snapshots/
│   └── .gitkeep
├── README.md
├── dbt_project.yml
└── packages.yml
```

### Initial Data Setup
Create and Populate customers Table:
```sql
      DROP TABLE IF EXISTS public.customers;
      
      CREATE TABLE public.customers (
          customer_id INT PRIMARY KEY,
          customer_name VARCHAR(100),
          membership_status VARCHAR(50),
          original_membership_status VARCHAR(50),
          start_date DATE,
          current_flag CHAR(1)
      );
```
```sql
      INSERT INTO public.customers (customer_id, customer_name, membership_status, original_membership_status, start_date, current_flag)
      VALUES
        (1, 'Alice Doe', 'Silver', 'Silver', '2023-01-01', 'Y'),
        (2, 'Bob Smith', 'Bronze', 'Bronze', '2023-01-05', 'Y'),
        (3, 'Jane Doe', 'Gold', 'Gold', '2023-01-07', 'Y');
```

### SCD Type 0 Implementation
- **Step 1: Create dbt Model**
    Create a file at models/dimensions/customers_type0.sql with the following content:

```sql
{{ config(materialized='incremental', unique_key='customer_id') }}

SELECT
  customer_id,
  customer_name,
  membership_status,
  original_membership_status,
  start_date,
  current_flag
FROM {{ source('public', 'customers') }}

{% if is_incremental() %}
WHERE customer_id NOT IN (SELECT customer_id FROM {{ this }})
{% endif %}
```
- **Step 2: Run Initial Load**
```shell
dbt run --models customers_type0 --full-refresh
```

- **Step 3: Validate Initial Data**
In pgAdmin, execute:

```sql
SELECT * FROM public.customers_type0;
```
Verify that the data matches the initial customers table.

- **Step 4: Simulate Data Update**
```sql
UPDATE public.customers
SET customer_name = 'Updated Alice Doe'
WHERE customer_id = 1;
```
- **Step 5: Run Incremental Load**
```
dbt run --models customers_type0
```

- **Step 6: Validate Post-Update Data**
In pgAdmin, execute:

```sql
SELECT * FROM public.customers_type0;
```
  Expected Outcome: The customer_name for customer_id = 1 should remain as 'Alice Doe', demonstrating that Type 0 SCD retains the original data.

---
