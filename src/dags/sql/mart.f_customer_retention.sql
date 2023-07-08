begin;
-- select the target period for update
drop table if exists periods_temp;
create temp table periods_temp as
select date_id, to_char(date_actual, 'IYYY-IW') as period_id
from mart.d_calendar
where to_char(date_actual, 'IYYY-IW') = to_char(date '{{ ds }}', 'IYYY-IW');

-- delete data for this period in Удаляем данные в витрине за этот период
delete
from mart.f_customer_retention
where period_id = (select period_id from periods_temp limit 1);

insert into mart.f_customer_retention

-- shrinking the fact to target period
with sales as (select f.*, p.period_id
               from mart.f_sales f
                        join periods_temp p using (date_id)),
    -- stats on customer weekly period
    customer_stats_weekly as (select customer_id,
                                      period_id,
                                      item_id,
                                      count(*)                                             as order_cnt,
                                      sum(case when status = 'refunded' then 1 else 0 end) as refund_cnt,
                                      sum(payment_amount)                                  as revenue
                               from sales
                               group by customer_id, period_id, item_id)
select item_id,
       se.period_id,
       'weekly'                                                    as period_name,
       count(csw.customer_id) filter ( where csw.order_cnt = 1)    as new_customers_count,
       coalesce(sum(revenue) filter ( where csw.order_cnt = 1), 0) as new_customers_revenue,
       count(csw.customer_id) filter ( where csw.order_cnt > 1)    as returning_customers_count,
       coalesce(sum(revenue) filter ( where csw.order_cnt > 1), 0) as returning_customers_revenue,
       count(se.customer_id) filter ( where csw.refund_cnt > 0)    as refunded_customer_count,
       coalesce(sum(refund_cnt), 0)                                as customers_refunded
from sales se
         join customer_stats_weekly csw using (item_id, customer_id, period_id)
group by 1, 2
order by 1, 2;
commit;