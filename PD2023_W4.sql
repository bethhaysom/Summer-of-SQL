with dates as
(
select *
    , date('2023-01-'||joining_day) as Joining_Date
from pd2023_wk04_january
union all
select *
    , date('2023-02-'||joining_day) as Joining_Date
from pd2023_wk04_february
union all
select *
    , date('2023-03-'||joining_day) as Joining_Date
from pd2023_wk04_march
union all
select *
    , date('2023-04-'||joining_day) as Joining_Date
from pd2023_wk04_april
union all
select *
    , date('2023-05-'||joining_day) as Joining_Date
from pd2023_wk04_may
union all
select *
    , date('2023-06-'||joining_day) as Joining_Date
from pd2023_wk04_june
union all
select *
    , date('2023-07-'||joining_day) as Joining_Date
from pd2023_wk04_july
union all
select *
    , date('2023-08-'||joining_day) as Joining_Date
from pd2023_wk04_august
union all
select *
    , date('2023-09-'||joining_day) as Joining_Date
from pd2023_wk04_september
union all
select *
    , date('2023-10-'||joining_day) as Joining_Date
from pd2023_wk04_october
union all
select *
    , date('2023-11-'||joining_day) as Joining_Date
from pd2023_wk04_november
union all
select *
    , date('2023-12-'||joining_day) as Joining_Date
from pd2023_wk04_december
)

select 
    ID
    , Joining_Date
    , Account_Type
    , Date_of_Birth
    , Ethnicity
from dates
pivot(min(value) for 
    demographic in
    ('Account Type' as Account_Type,'Date of Birth' as Date_of_Birth, 'Ethnicity' as Ethnicity)
    )
