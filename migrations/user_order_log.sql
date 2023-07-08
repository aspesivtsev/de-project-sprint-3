alter table
    staging.user_order_log
add
    column if not exists status varchar(20) not null default 'shipped';
