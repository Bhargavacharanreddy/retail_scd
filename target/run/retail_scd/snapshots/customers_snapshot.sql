
      update "retail_db"."snapshots"."customers_snapshot"
    set dbt_valid_to = DBT_INTERNAL_SOURCE.dbt_valid_to
    from "customers_snapshot__dbt_tmp174604102953" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_scd_id::text = "retail_db"."snapshots"."customers_snapshot".dbt_scd_id::text
      and DBT_INTERNAL_SOURCE.dbt_change_type::text in ('update'::text, 'delete'::text)
      
        and "retail_db"."snapshots"."customers_snapshot".dbt_valid_to is null;
      


    insert into "retail_db"."snapshots"."customers_snapshot" ("customer_id", "customer_name", "membership_status", "original_membership_status", "start_date", "current_flag", "last_updated", "dbt_updated_at", "dbt_valid_from", "dbt_valid_to", "dbt_scd_id")
    select DBT_INTERNAL_SOURCE."customer_id",DBT_INTERNAL_SOURCE."customer_name",DBT_INTERNAL_SOURCE."membership_status",DBT_INTERNAL_SOURCE."original_membership_status",DBT_INTERNAL_SOURCE."start_date",DBT_INTERNAL_SOURCE."current_flag",DBT_INTERNAL_SOURCE."last_updated",DBT_INTERNAL_SOURCE."dbt_updated_at",DBT_INTERNAL_SOURCE."dbt_valid_from",DBT_INTERNAL_SOURCE."dbt_valid_to",DBT_INTERNAL_SOURCE."dbt_scd_id"
    from "customers_snapshot__dbt_tmp174604102953" as DBT_INTERNAL_SOURCE
    where DBT_INTERNAL_SOURCE.dbt_change_type::text = 'insert'::text;

  