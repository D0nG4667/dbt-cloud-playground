{{config(materialized = 'table')}}

with
    customers as (
        select
            id as customer_id,
            first_name,
            last_name,
        from `altschool-455914.jaffle_shop.customers`
    ),

    orders as (
        select
            id as order_id,
            user_id as customer_id,
            order_date,
            status
        from `altschool-455914.jaffle_shop.orders`
    ),

    payments as (
        select
            id as payment_id,
            orderid as order_id,
            paymentmethod as payment_method,
            amount / 100 as amount,
        from `altschool-455914.stripe.payment`
    ),

    customer_orders as (
        select
            customer_id,
            min(order_date) as first_order_date,
            max(order_date) as last_order_date,
            count(order_id) as number_of_orders,
        from orders
        group by customer_id
    ),

    customer_payments as (
        select
            o.customer_id,
            sum(p.amount) as total_amount,
        from orders o
        left join payments p
        on o.order_id = p.order_id
        group by o.customer_id
    ),

    final as (
        select
            c.customer_id,
            c.first_name,
            c.last_name,
            co.first_order_date,
            co.last_order_date,
            co.number_of_orders,
            cp.total_amount,
        from customers c
        left join customer_orders co
            on c.customer_id = co.customer_id
        left join customer_payments cp
            on c.customer_id = cp.customer_id

    )

select * from final

