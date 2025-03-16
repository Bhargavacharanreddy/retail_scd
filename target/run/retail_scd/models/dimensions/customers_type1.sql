
  
    

  create  table "retail_db"."public"."customers_type1__dbt_tmp"
  
  
    as
  
  (
    

SELECT
    customer_id,
    customer_name,
    membership_status,
    original_membership_status,
    start_date,
    current_flag,
    last_updated
FROM public.customers
  );
  