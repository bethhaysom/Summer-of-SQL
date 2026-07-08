with account_info as
(
select 
    account_number
    , account_type
    , trim(value) as account_holder_id_split
    , balance_date
    , balance
    , seq
    , index
from pd2023_wk07_account_information, lateral split_to_table(account_holder_id, ', ')
where account_holder_id_split is not null and account_type != 'Platinum'
)

select 
    tp.transaction_id
    , tp.account_to
    , td.transaction_date
    , td.value
    , i.account_number
    , i.account_type
    , i.balance_date
    , i.balance
    , h.name
    , h.date_of_birth
    , concat('0', h.contact_number) as contact_number
    , h.first_line_of_address
from pd2023_wk07_account_holders as h
join account_info as i
    on h.account_holder_id = i.account_holder_id_split
join pd2023_wk07_transaction_path as tp
    on i.account_number = tp.account_from
join pd2023_wk07_transaction_detail as td
    on tp.transaction_id = td.transaction_id
where cancelled_ = 'N'
    and value > 1000
