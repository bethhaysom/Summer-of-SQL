select 
    transaction_id
    , concat(
        'GB'
        , check_digits
        , swift_code
        , replace(sort_code, '-', '')
        , account_number
    )
from pd2023_wk02_transactions as t
join pd2023_wk02_swift_codes as s
    on t.bank = s.bank
