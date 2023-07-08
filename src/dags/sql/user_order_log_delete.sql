-- delete all records on the execution date
delete
from staging.user_order_log
where date_time::date = '{{ ds }}';
