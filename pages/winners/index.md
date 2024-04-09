# Biggest winners

Top auction customers

```sql top_customers
select
    winner_last_name,
    winner_first_name,
    winner_customer_id,

    count(*) as won,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    max(inserted_at) as latest,
    min(inserted_at) as first,
  from staging_auctions
  where (winner_customer_id is not null) and (winner_customer_id not like 'None')
  group by 1, 2, 3
  having won > 50
  order by won desc
```

<DataTable
  data="{top_customers}"
  search="true"
  sortable="true"
  rows=20
/>

# All winning bids

All individual winning bids in the database.

<Alert status="warning">
Warning: This is a lot of information, it can be slow to search.
</Alert>


```sql all_winning_bids
select
    *,
    'auctions/' || md5(title) as auction_id,
    cast(datepart('year', inserted_at) as text) as year
from staging_auctions
```

<DataTable
    data="{all_winning_bids}"
    search="true"
    sortable="true"
    rows=20
/>
