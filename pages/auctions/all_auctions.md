# All auction links (technical reasons)

We need to iterate over all possible `auction_id` links to be able to access the pages. See the [Github issue](https://github.com/evidence-dev/evidence/issues/1115).


```sql all_auction_ids
select
    title,
    '/auctions/' || md5(title) as link
from bids
group by 1
```

<DataTable 
  data="{all_auction_ids}"
  rows="all"
  link="link"
/>
