with targets as (
  -- CTE to pivot targets table
  select online_or_in_person
      , split_part(quarters, 'Q', 2) as quarters
      , targets
  from pd2023_wk03_targets
      unpivot(targets for Quarters in (Q1, Q2, Q3, Q4))
),
trans as (
    -- CTE to get required format of transactions table
    select 
        transaction_code
        , value
        , customer_code
        , iff(online_or_in_person=1, 'Online', 'In-Person') as online_or_in
        , quarter(to_date(transaction_date, 'dd/mm/yyyy hh:mi:ss')) as quarters
    from pd2023_wk01
    where transaction_code like 'DSB%'
)

select
    t1.online_or_in
    , t1.quarters
    , sum(value) as value1
    , sum(t2.targets) as target1
    , value1 - target1 as variance_to_target
from trans as t1
join targets as t2
    on t1.online_or_in = t2.online_or_in_person
    and t1.quarters = t2.quarters
group by t1.quarters, t1.online_or_in
