with ranked as
(
select 
    to_char( to_date(transaction_date, 'dd/mm/yyyy hh:mi:ss'), 'mmmm') as transaction_dt
    , split_part(transaction_code, '-', 1) as bank
    , sum(value) as monthly_value
    , rank() over (partition by transaction_dt order by monthly_value desc) as bank_rank_per_month
from pd2023_wk01
group by bank, transaction_dt
)
, bank_rank as
(
select 
    bank
    , avg(bank_rank_per_month) as avg_rank_per_bank
from ranked
group by bank
)
, rank_value as
(
select
    bank_rank_per_month
    , avg(monthly_value) as avg_transaction_value_per_rank
from ranked
group by bank_rank_per_month
)

select 
    r.transaction_dt
    , r.bank
    , r.monthly_value
    , r.bank_rank_per_month
    , avg_transaction_value_per_rank
    , avg_rank_per_bank
from ranked as r
join bank_rank as b on r.bank = b.bank
join rank_value as v on r.bank_rank_per_month = v.bank_rank_per_month
