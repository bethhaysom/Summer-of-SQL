with unpiv as
-- unpivoting to 5 rows per cust
(
select 
    customer_id
    , split_part(mobile_col,'___',2) as mobile
    , split_part(online_col,'___',2) as online
    , mobile_rating
    , online_rating
from pd2023_wk06_dsb_customer_survey
unpivot(mobile_rating for mobile_col in 
    (mobile_app___ease_of_access,mobile_app___ease_of_use,mobile_app___navigation,mobile_app___likelihood_to_recommend,mobile_app___overall_rating))
unpivot(online_rating for online_col in 
    (online_interface___ease_of_access,online_interface___ease_of_use,online_interface___navigation,online_interface___likelihood_to_recommend,online_interface___overall_rating))
where mobile = online
    and mobile != 'OVERALL_RATING'
)
, avg_ as
-- calculating difference between avgs for platforms
(
select 
    customer_id
    , avg(mobile_rating) 
    , avg(online_rating)
    , avg(mobile_rating) - avg(online_rating) as plat_diff
from unpiv
group by customer_id
)

-- categorise fans and calculate %
select 
    case
        when plat_diff >= 2 then 'mobile_app_superfan'
        when plat_diff >= 1 then 'mobile_app_fan'
        when plat_diff <= -2 then 'online_interface_superfan'
        when plat_diff <= -1 then 'online_interface_fan'
        else 'neutral'
        end as preference
    , count(customer_id) / (select count(customer_id) from avg_)
from avg_
group by preference
