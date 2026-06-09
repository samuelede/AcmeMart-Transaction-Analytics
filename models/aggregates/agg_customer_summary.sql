{{ config(materialized='table') }}

with sales as (

    select * from {{ ref('fct_sales') }}

),

customers as (

    select * from {{ ref('dim_customers') }}

),

monthly_spend as (

    select
        customer_id,
        transaction_year,
        transaction_month,
        count(distinct transaction_id)              as monthly_orders,
        sum(total_amount)                           as monthly_spend,
        count(distinct store_id)                    as stores_visited_that_month

    from sales
    group by customer_id, transaction_year, transaction_month

),

final as (

    select
        c.customer_id,
        c.first_purchase_date,
        c.last_purchase_date,
        c.days_since_last_purchase,
        c.total_transactions,
        c.lifetime_value,
        c.avg_order_value,
        c.stores_visited,
        c.unique_products_bought,
        c.preferred_payment_method,
        c.recency_band,
        c.frequency_band,
        c.monetary_band,

        -- monthly averages
        round(avg(m.monthly_orders), 1)             as avg_monthly_orders,
        round(avg(m.monthly_spend), 2)              as avg_monthly_spend,
        round(avg(m.stores_visited_that_month), 1)  as avg_stores_per_month

    from customers c
    left join monthly_spend m on c.customer_id = m.customer_id
    group by
        c.customer_id,
        c.first_purchase_date,
        c.last_purchase_date,
        c.days_since_last_purchase,
        c.total_transactions,
        c.lifetime_value,
        c.avg_order_value,
        c.stores_visited,
        c.unique_products_bought,
        c.preferred_payment_method,
        c.recency_band,
        c.frequency_band,
        c.monetary_band

)

select * from final
