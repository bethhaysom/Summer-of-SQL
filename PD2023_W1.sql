-- Part 1: Total Values of Transactions by each bank

select
    split_part(transaction_code, '-', 1) as "Bank"
    , sum(value) as "Value"
from PD2023_WK01 as t1
group by "Bank"

-- Part 2: Total Values by Bank, Day of the Week and Type of Transaction

select
    split_part(transaction_code, '-', 1) as "Bank"
    , iff(online_or_in_person = 1, 'Online', 'In-Person') as "Online or In-Person"
    , dayname(
        to_date(transaction_date, 'dd/mm/yyyy hh:mi:ss')
        ) as "Transaction Date"
    , sum(value) as "Value"
from PD2023_WK01
group by "Bank"
    , "Transaction Date"
    , "Online or In-Person"

-- Part 3: Total Values by Bank and Customer Code

select
    split_part(transaction_code, '-', 1) as "Bank"
    , customer_code as "Customer Code"
    , sum(value) as "Value"
from PD2023_WK01
group by "Bank"
    , "Customer Code"
