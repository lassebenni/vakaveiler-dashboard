# Biggest winners

Top auction customers

```sql top_customers
select
    title,
    winner_last_name,
    winner_first_name,
    winner_customer_id,

    count(*) as won,
    first(retail_price) as retail_price,
    max(winning_bid) as highest_price,
    median(winning_bid) as median_bid,
    min(winning_bid) as lowest_price,
    max(inserted_at) as latest,
    min(inserted_at) as first,
  from staging_auctions
  where (winner_customer_id is not null) and (winner_customer_id not like 'None')
  group by 1, 2, 3, 4
  having won > 10
  order by won desc
```

<DataTable
  data="{top_customers}"
  search="true"
  sortable="true"
  rows=20
/>
