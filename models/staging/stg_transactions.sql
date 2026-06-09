{{ config(materialized='view') }}

/*
    Source: Airbyte syncs all store CSV files from Google Drive into
    a single Snowflake table: ACMEMART_DW.BRONZE.CSV_SALES
    Stream name: csv_sales
    All store files share the same 11 columns — one row per transaction.

    For local development using dbt seed, files are named:
    store_S001.csv, store_S002.csv etc. and unioned via union_seeds('store')

    Columns from source:
        transaction_id, transaction_timestamp, store_id, product_id,
        product_name, category, quantity, unit_price, total_amount,
        payment_method, customer_id
*/

with source as (

    {# --- Production: data loaded by Airbyte into BRONZE.CSV_SALES --- #}
    {# select * from {{ source('bronze', 'csv_sales') }} #}

    {# --- Development: seed files loaded via dbt seed --- #}
    {{ union_seeds('store') }}

),

renamed as (

    select
        -- identifiers
        cast(transaction_id      as varchar)    as transaction_id,
        cast(store_id            as varchar)    as store_id,
        cast(product_id          as varchar)    as product_id,
        cast(customer_id         as varchar)    as customer_id,

        -- dates & times
        try_cast(transaction_timestamp as timestamp)        as transaction_timestamp,
        cast(transaction_timestamp as date)                 as transaction_date,
        date_part('year',  try_cast(transaction_timestamp as timestamp))   as transaction_year,
        date_part('month', try_cast(transaction_timestamp as timestamp))   as transaction_month,
        date_part('hour',  try_cast(transaction_timestamp as timestamp))   as transaction_hour,

        -- product attributes
        {{ clean_string('product_name') }}      as product_name,
        {{ clean_string('category') }}          as category,

        -- measures
        try_cast(quantity        as integer)    as quantity,
        try_cast(unit_price      as float)      as unit_price,
        try_cast(total_amount    as float)      as total_amount,

        -- descriptors
        {{ clean_string('payment_method') }}    as payment_method

    from source
    where transaction_id is not null

)

select * from renamed