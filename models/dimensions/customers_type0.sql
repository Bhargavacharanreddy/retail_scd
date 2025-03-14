{{ config(materialized='incremental', unique_key='customer_id') }}

SELECT
    customer_id,
    customer_name,
    membership_status,
    original_membership_status,
    start_date,
    current_flag
FROM public.customers

{% if is_incremental() %}
WHERE customer_id NOT IN (SELECT customer_id FROM {{ this }})
{% endif %}
