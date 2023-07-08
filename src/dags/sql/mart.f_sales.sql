delete from
    mart.f_sales
where
    date_id = translate('{{ ds }}', '-', ''):: int; --The DAG run’s logical date as YYYY-MM-DD with dashes removed: 20230703


insert into
    mart.f_sales (
        date_id,
        item_id,
        customer_id,
        city_id,
        quantity,
        payment_amount,
        status
    )
select
    dc.date_id,
    item_id,
    customer_id,
    city_id,
    quantity,
    payment_amount,
    case
        when payment_amount < 0 then 'refunded'
        else status
    end as status
from
    staging.user_order_log uol
    left join mart.d_calendar as dc on uol.date_time:: Date = dc.date_actual
where
    uol.date_time:: Date = '{{ds}}';