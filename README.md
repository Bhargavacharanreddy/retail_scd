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
2. Prerequisites
3. Setup Instructions
   - Install PostgreSQL and pgAdmin
   - Install Python and dbt
   - Configure dbt
4. Project Structure
5. Initial Data Setup
6. SCD Type 0 Implementation
7. SCD Type 1 Implementation (Overwrite)
8. SCD Type 2 Implementation (Historical Tracking)

--- 
### Project Overview
The goal of this project is to practice and validate different Slowly Changing Dimension (SCD) types to manage and track changes in dimensional data over time. This is crucial for maintaining historical accuracy in data warehousing and business intelligence applications.





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
.
├── README.md
├── analysis
├── dbt_project.yml
├── logs
│   └── dbt.log
├── macros
├── models
│   ├── dimensions
│   │   ├── customers_type0.sql
│   │   └── customers_type1.sql
│   └── sources.yml
├── seeds
│   └── customers.csv
├── snapshots
│   └── customers_snapshot.sql
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
- **Create dbt Model**
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
- **Run Initial Load**
```shell
dbt run --models customers_type0 --full-refresh
```

- **Validate Initial Data**
In pgAdmin, execute:

```sql
SELECT * FROM public.customers_type0;
```
Verify that the data matches the initial customers table.

- **Simulate Data Update**
```sql
UPDATE public.customers
SET customer_name = 'Updated Alice Doe'
WHERE customer_id = 1;
```
- **Run Incremental Load**
```
dbt run --models customers_type0
```

- **Validate Post-Update Data**
In pgAdmin, execute:

```sql
SELECT * FROM public.customers_type0;
```
  Expected Outcome: The customer_name for customer_id = 1 should remain as 'Alice Doe', demonstrating that Type 0 SCD retains the original data.

---

### SCD Type 1 Implementation

- **create dbt model**
    ```
    {{ config(materialized='table') }}
    
    SELECT
        customer_id,
        customer_name,
        membership_status,
        original_membership_status,
        start_date,
        current_flag,
        last_updated
    FROM public.customers
    ```
- **Initial Run**

    ```
    dbt run --models customers_type1 --full-refresh
    ```

- **Validate Initial Data**

    ```sql
    SELECT * FROM public.customers_type1;
    ```

- **Simulate Data Update**

    ```sql
    UPDATE public.customers
    SET membership_status = 'Gold'
    WHERE customer_id = 1;
    ```

- **Run Incremental Load**

    ```
    dbt run --models customers_type1
    ```

- **Validate**

    ```sql
    SELECT * FROM public.customers_type1;
    ```

    Validation: membership_status for customer_id=1 should be updated.

---

### SCD Type 2 Implementation (Historical Tracking)

   Clearly preserves historical data by inserting new rows.


- **Create Snapshot (snapshots/customers_snapshot.sql)**
    ```
    {% snapshot customers_snapshot %}
    {{
        config(
            target_schema='snapshots',
            unique_key='customer_id',
            strategy='check',
            check_cols=['customer_name', 'membership_status']
        )
    }}
    
    SELECT
        customer_id,
        customer_name,
        membership_status,
        original_membership_status,
        start_date,
        current_flag,
        last_updated
    FROM public.customers
    {% endsnapshot %}
    ```
    
- **Run Initial Snapshot**
    ```
    dbt snapshot
    ```

- **Validate Initial Data**
    ```sql
    SELECT * FROM snapshots.customers_snapshot;
    ```
- **Simulate Data Change**
    ```sql
    UPDATE public.customers
    SET customer_name = 'Alice Johnson'
    WHERE customer_id = 1;
    ```
- **Run Snapshot again**
    ```
    dbt snapshot
    ```
- **Validate Historical Data**
    ```sql
    SELECT
        customer_id,
        customer_name,
        membership_status,
        dbt_valid_from,
        dbt_valid_to
    FROM snapshots.customers_snapshot
    WHERE customer_id = 1
    ORDER BY dbt_valid_from;
    ```
    Expected: Two rows with historical and current values clearly defined.
