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

select 
    account_nm
    , date_ as balance_date
    , value as transaction_value
    , balance + iff(running_change is null, 0, running_change) as balance
from running_calc
order by account_nm asc, balance_date asc, transaction_value desc
