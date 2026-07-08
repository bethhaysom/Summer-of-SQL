with union_ as
(
--jan
select 
    date_from_parts(2023, 01, 01) as file_date
    , *
from pd2023_wk08_01
union all
-- feb
select 
    date_from_parts(2023, 02, 01) as file_date
    , *
from pd2023_wk08_02
union all
-- mar
select 
    date_from_parts(2023, 03, 01) as file_date
    , *
from pd2023_wk08_03
union all
-- apr
select 
    date_from_parts(2023, 04, 01) as file_date
    , *
from pd2023_wk08_04
union all
-- may
select 
    date_from_parts(2023, 05, 01) as file_date
    , *
from pd2023_wk08_05
union all
-- jun
select 
    date_from_parts(2023, 06, 01) as file_date
    , *
from pd2023_wk08_06
union all
-- jul
select 
    date_from_parts(2023, 07, 01) as file_date
    , *
from pd2023_wk08_07
union all
-- aug
select 
    date_from_parts(2023, 08, 01) as file_date
    , *
from pd2023_wk08_08
union all
-- sep
select 
    date_from_parts(2023, 09, 01) as file_date
    , *
from pd2023_wk08_09
union all
-- oct
select 
    date_from_parts(2023, 10, 01) as file_date
    , *
from pd2023_wk08_10
union all
-- nov
select 
    date_from_parts(2023, 11, 01) as file_date
    , *
from pd2023_wk08_11
union all                    
-- dec
select 
    date_from_parts(2023, 12, 01) as file_date
    , *
from pd2023_wk08_12
)

, clean_num as
(
select 
    file_date
    , id
    , first_name
    , last_name
    , ticker
    , sector
    , market
    , stock_name
    , case
            when split_part(market_cap,'$',2) like '%M' then try_to_double(split_part(split_part(market_cap,'$',2),'M',1)) * 1000000
            when split_part(market_cap,'$',2) like '%B' then try_to_double(split_part(split_part(market_cap,'$',2),'B',1)) * 1000000000
            else try_to_double(split_part(market_cap,'$',2))
    end
    as market_cap_
    , try_to_double(split_part(purchase_price,'$',2)) as purchase_price_
from union_
where market_cap != 'n/a' 
)
, rank_tab as
(
select 
    case
        when market_cap_ < 100000000 then 'small'
        when market_cap_ < 1000000000 then 'medium'
        when market_cap_ < 100000000000 then 'large'
        when market_cap_ >= 100000000000 then 'huge'
    end as market_cap_cat
    , case 
        when purchase_price_ < 25000 then 'low'
        when purchase_price_ < 50000 then 'medium'
        when purchase_price_ < 75000 then 'high'
        when purchase_price_ < 100000 then 'very_high'
    end as purchase_price_cat
    , file_date
    , ticker
    , sector
    , market
    , stock_name
    , market_cap_
    , purchase_price_
    , rank() over (
            partition by market_cap_cat, purchase_price_cat, file_date 
            order by purchase_price_ desc
            ) as rank_
from clean_num
)

select *
from rank_tab
where rank_ <= 5
