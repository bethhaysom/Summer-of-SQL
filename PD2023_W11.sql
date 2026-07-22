-- 2023 week 11: cross joins, maths functions and row number sorting:

-- append branch information to customer 
-- change lat/longs from degrees to radians (x rad = x degree * pi / 180)
with location_rads as 
(
select 
    c.customer
    , c.address_long * pi() / 180 as address_long
    , c.address_lat * pi() / 180 as address_lat
    , b.branch
    , b.branch_long * pi() / 180 as branch_long
    , b.branch_lat * pi() / 180 as branch_lat
from pd2023_wk11_dsb_customer_locations as c
cross join pd2023_wk11_dsb_branches as b
)
-- distance in miles = 3963 * acos((sin(lat1) * sin(lat2)) + cos(lat1) * cos(lat2) * cos(long2 – long1))
-- find customers closest branch
, customer_distance as
(
select 
    *
    , round( 
        3963 * acos((sin(address_lat) * sin(branch_lat)) + cos(address_lat) * cos(branch_lat) * cos(branch_long - address_long)) 
        , 2) as distance
    , row_number() over (
        partition by customer
        order by distance asc
        ) as customer_clostest
from location_rads
)
-- filter so cust associated only with closest branch
-- rank customer priority where closest customer = 1
select 
    branch
    , branch_long
    , branch_lat
    , distance
    , row_number() over (
        partition by branch
        order by distance asc
        ) as customer_priority
    , customer
    , address_long
    , address_lat
from customer_distance
where customer_clostest = 1
