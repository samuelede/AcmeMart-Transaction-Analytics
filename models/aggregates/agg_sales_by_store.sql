{{ config(materialized='table') }}

with sales as (

    select * from {{ ref('fct_sales') }}

),

final as (

    select
        store_id,
        transaction_year,
        transaction_month,

        -- volume
        count(distinct transaction_id)              as total_transactions,
        sum(quantity)                               as total_units_sold,

        -- revenue
        sum(total_amount)                           as total_revenue,
        round(avg(total_amount), 2)                 as avg_order_value,

        -- customers
        count(distinct customer_id)                 as unique_customers,

        -- product mix
        count(distinct product_id)                  as unique_products_sold,

        -- payment breakdown
        count_if(payment_method = 'Cash')           as cash_transactions,
        count_if(payment_method = 'Card')           as card_transactions,
        count_if(payment_method = 'Transfer')       as transfer_transactions,

        -- peak hour
        mode(transaction_hour)                      as peak_hour

    from sales
    group by store_id, transaction_year, transaction_month

)

select * from final
