-- How many unique nodes on Data Bank system?

select 
  count( distinct node_id ) as unique_nodes
from customer_nodes
;

-- What is number of nodes per region?

select
    r.region_name
    , count( distinct c.node_id ) as unique_nodes
from customer_nodes as c
join regions as r 
    on c.region_id = r.region_id
group by r.region_name
;

-- How any customers are allocated to each region?

select
    r.region_name
    , count( distinct c.customer_id ) as unique_customers
from customer_nodes as c
join regions as r 
    on c.region_id = r.region_id
group by r.region_name
;

-- How many days on avg are customers reallocated to a different node?

with CTE as 
(select
    customer_id
    , node_id
    , region_id
    , start_date
    , end_date
    , datediff('day', start_date, end_date) as days_diff
from customer_nodes as c
where end_date < '9999-12-31'
order by customer_id
)
, total_days_per_node as
( 
select
    customer_id
    , node_id
    , sum(days_diff) as days_per_node
from CTE
group by customer_id, node_id
order by customer_id
)

select 
    round(avg(days_per_node)) as avg_days_per_node
from total_days_per_node
;

-- what is median, 80th and 95th percentile for this same reallocation days metric for each region?
-- reallocation days: found above, can use total_days_per_node CTE
-- median and percentile functions, group by region

with CTE as 
(select
    customer_id
    , node_id
    , region_id
    , start_date
    , end_date
    , datediff('day', start_date, end_date) as days_diff
from customer_nodes as c
where end_date < '9999-12-31'
order by customer_id
)
, total_days_per_node as
( 
select
    customer_id
    , node_id
    , region_id
    , sum(days_diff) as days_per_node
from CTE
group by customer_id, node_id, region_id
order by customer_id
)

select 
    region_name
    , round( median(days_per_node) ) as median_days
    , round( percentile_cont(0.8) within group (order by days_per_node) ) as "80th_percentile"
    , round( percentile_cont(0.95) within group (order by days_per_node) ) as "95th_percentile"
from total_days_per_node as t
join regions as r
    on t.region_id = r.region_id
group by region_name

