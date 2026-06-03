with 

source as (

    select * from {{ source('google_sales_data', 'csv_sales') }}

),

renamed as (

    select
        _airbyte_raw_id,
        _airbyte_extracted_at,
        _airbyte_meta,
        _airbyte_generation_id,
        category,
        quantity,
        store_id,
        product_id,
        unit_price,
        customer_id,
        product_name,
        total_amount,
        payment_method,
        transaction_id,
        _ab_source_file_url,
        transaction_timestamp,
        _ab_source_file_last_modified

    from source

)

select * from renamed