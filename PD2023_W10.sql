with transactions as
(
select 
    p.account_to
    , p.account_from
    , d.transaction_date
    , d.value
from pd2023_wk07_transaction_detail as d
join pd2023_wk07_transaction_path as p
    on d.transaction_id = p.transaction_id
where cancelled_='N'
)
,
transactions_union as
(
-- incoming transactions
select
    account_to as account_nm
    , transaction_date as date_
    , value
from transactions

union all by name

-- outgoing transactions
select
    account_from as account_nm
    , transaction_date as date_
    , - value as value
from transactions

union all by name

-- starting balance 
select
    account_number as account_nm
    , balance_date as date_
    , balance
from pd2023_wk07_account_information
)
, running_calc as
(
select 
    account_nm
    , date_
    , value
    , sum(value) over(
        order by date_ asc
        rows between unbounded preceding and current row
    ) as running_change
    ,  iff(balance is null, 0, balance) as balance
from transactions_union
order by date_ asc, value desc 
)
, pd2023_w9_final as
(
select 
    account_nm
    , to_date(date_) as balance_date
    , value as transaction_value
    , balance + iff(running_change is null, 0, running_change) as balance
from running_calc
order by account_nm asc, balance_date asc, transaction_value desc
)




-- week 10: what is balance on set day?
-- carrying on CTEs:
, agg_transactions as
(
select 
    account_nm
    , balance_date
    , sum(transaction_value) as value
    , sum(balance) as balance
from pd2023_w9_final
group by account_nm, balance_date
)
-- scaffolding dates
, generated_dates as
(
select 
    account_nm
    , to_date(dateadd('day', f.value, '2023-01-31')) as dates
from pd2023_w9_final,
    table(flatten(array_generate_range(0, datediff('day', '2023-01-31', '2023-02-14') + 1))) as f
)
, scaff_transactions as
(
select 
    d.account_nm
    , d.dates
    , avg(t.value) as value
    , avg(t.balance) as balance
from generated_dates as d
left join agg_transactions as t
    on d.account_nm = t.account_nm
    and d.dates = t.balance_date
group by d.account_nm, d.dates
order by d.account_nm, d.dates
)
, full_statement as
(
select 
    account_nm
    , dates
    , LAST_VALUE(balance) IGNORE NULLS OVER (
        PARTITION BY account_nm 
        ORDER BY dates
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS balance
    , value as transaction_value
from scaff_transactions
)

select 
    account_nm
    , balance
    , transaction_value
from full_statement
where dates = '2023-02-01'
