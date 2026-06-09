{{ config(materialized='table') }}

with sales as (

    select * from {{ ref('fct_sales') }}

),

final as (

    select
        product_id,
        product_name,
        category,
        transaction_year,
        transaction_month,

        -- volume
        count(distinct transaction_id)              as total_transactions,
        sum(quantity)                               as total_units_sold,

        -- revenue
        sum(total_amount)                           as total_revenue,
        round(avg(unit_price), 2)                   as avg_unit_price,
        round(avg(total_amount), 2)                 as avg_transaction_value,

        -- reach
        count(distinct store_id)                    as stores_selling,
        count(distinct customer_id)                 as unique_buyers

    from sales
    group by product_id, product_name, category, transaction_year, transaction_month

)

select * from final
