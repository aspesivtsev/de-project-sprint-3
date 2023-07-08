alter table
    mart.f_sales
add
    column if not exists status varchar(20) not null default 'shipped';