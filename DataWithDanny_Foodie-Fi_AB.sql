-- SECTION A

select 
    customer_id
    , plan_name
    , start_date
    , price
from subscriptions as s
join plans as p
on s.plan_id = p.plan_id
where customer_id <= 8

-- cust 1: after trial, went onto basic monthly plan
-- cust 2: after trial, went onto pro annual plan
-- cust 3: after trial, went onto basic monthly plan
-- cust 4: after trial, went onto basic monthly for 3 months, before churn
-- cust 5: after trial, basic monthly
-- cust 6: after trial, basic monthly for 2 months, before churn
-- cust 7: after trial, basic monthly for 3 months, before pro monthly
-- cust 8: after trial, basic monthly for 2 months, before pro monthly
;

-- SECTION B

-- 1. Total customers = 1000
select count(distinct customer_id) as customer_count
from subscriptions
;

-- 2. Monthly distribution of trials starting
select
    date_trunc('month', start_date) as month_
    , count(distinct customer_id) as trials_starting
from subscriptions
where plan_id=0
group by month_
order by month_ asc
;

-- 3. Plan start dates from after 2020
select 
    p.plan_name
    , count(*) as count_of_events
from subscriptions as s
join plans as p
where year(s.start_date) > 2020
group by p.plan_name
;

-- 4. count and % customers who have churned (1dp)
select 
    count(distinct customer_id) as churned_count
    , round(churned_count / (select count(distinct customer_id) from subscriptions) * 100, 1) as percent_of_total
from subscriptions
where plan_id = 4
;

-- 5. customers churned straight after free trial and % of total (0dp)
with num_table as 
(
select
    row_number() over (partition by customer_id order by start_date asc) as num
    , *
from subscriptions
order by customer_id asc, start_date asc
)

select 
    count(distinct customer_id) as churned_asap
    , round(churned_asap / (select count(distinct customer_id) from subscriptions) * 100, 0) as percent_of_total
from num_table
where num=2 and plan_id=4
;

-- 6. Num and % of customer plans after free trial
with num_table as 
(
select
    row_number() over (partition by customer_id order by start_date asc) as num
    , *
from subscriptions
order by customer_id asc, start_date asc
)

select 
    plan_name
    , count(distinct customer_id) as customer_count
    , round(customer_count / (select count(distinct customer_id) from subscriptions) * 100, 0) as percent_of_total
from num_table as s
join plans as p
    on p.plan_id = s.plan_id
where num=2 
group by plan_name
;

-- 7. cust couny and % of 5 plan names at 2020-12-31
with num_table as 
(
select
    row_number() over (partition by customer_id order by start_date desc) as num
    , *
from subscriptions
where start_date <= '2020-12-31'
order by customer_id asc, start_date desc
)

select 
    plan_name
    , count(distinct customer_id) as customer_count
    , round(customer_count / (select count(distinct customer_id) from subscriptions) * 100, 0) as percent_of_total
from num_table as s
inner join plans as p
    on p.plan_id = s.plan_id
where num=1 
group by plan_name
;

-- 8. customers upgrated to annual plan in 2020
select 
    plan_name
    , count(distinct customer_id) as annual_upgrading_cust
from subscriptions as s
join plans as p
    on s.plan_id = p.plan_id
where plan_name like '%annual%'
    and year(start_date) = 2020
group by plan_name
;

-- 9. how many days to upgrade to annual from join day
with num_table as
(
select 
    row_number() over (partition by customer_id order by start_date asc) as num
    , *
from subscriptions
)
, join_date as
(
select 
    customer_id
    , start_date as join_date
from num_table
where num=1
)

select 
    avg(datediff('days', j.join_date, s.start_date))
from subscriptions as s
join join_date as j
    on s.customer_id = j.customer_id
join plans as p
    on s.plan_id = p.plan_id
where p.plan_name like '%annual%'
;

-- 10. break this avg to 30 dat periods
with num_table as  
(
select 
    row_number() over (partition by customer_id order by start_date asc) as num
    , *
from subscriptions
)
, join_date as
(
select 
    customer_id
    , start_date as join_date
from num_table
where num=1
)

select
    concat(
        to_char( floor(datediff('days', j.join_date, s.start_date) / 30) * 30 )
        , '-'
        , to_char( floor(datediff('days', j.join_date, s.start_date) / 30) * 30 + 30)
    ) as bins
    , count(j.customer_id) as cust_count
from subscriptions as s
join join_date as j
    on s.customer_id = j.customer_id
join plans as p
    on s.plan_id = p.plan_id
where p.plan_name like '%annual%'
group by bins
;

-- 11. how many downgrades from pro monthly to basic monthly in 2020
with num_table as  
(
select 
    row_number() over (partition by customer_id order by start_date asc) as num
    , customer_id
    , start_date
    , plan_name
from subscriptions as s
join plans as p
    on s.plan_id = p.plan_id
)
, pro_plan as
(
select 
    customer_id
    , start_date as pro_date
from num_table
where plan_name = 'pro monthly'
)
, basic_plan as 
(
select 
    customer_id
    , start_date as basic_date
from num_table
where plan_name = 'basic monthly'
)

select 
    sum(iff(basic_date>pro_date, 1, 0))
from pro_plan as p
join basic_plan as b
    on p.customer_id = b.customer_id














