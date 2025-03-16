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
