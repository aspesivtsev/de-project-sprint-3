drop table
    if exists mart.f_customer_retention;

create table
    mart.f_customer_retention (
        item_id integer,
        period_id text,
        period_name text,
        new_customers_count bigint,
        new_customers_revenue bigint,
        returning_customers_count bigint,
        returning_customers_revenue bigint,
        refunded_customer_count bigint,
        customers_refunded bigint,
        primary key (item_id, period_id)
    );