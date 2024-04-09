# Top suppliers

```sql top_suppliers
select
    supplier_name,

    count(*) as count,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    max(inserted_at) as latest,
    min(inserted_at) as first

from staging_auctions
group by 1
order by count desc
```

<DataTable
  data="{top_suppliers}"
  search="true"
  sortable="true"
  rows=20
/>