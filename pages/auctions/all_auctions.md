# All auction ids (technical reasons)


```sql all_auction_ids
select
    title,
    md5(title) as auction_id
from bids
group by 1
```

<DataTable 
  data="{all_auction_ids}"
  rows="all"
/>