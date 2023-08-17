# All auction ids (technical reasons)


```sql all_auction_ids
select
    title,
    md5(title) as auction_id
from bids
group by 1
```

We need to loop over each auction_id because of limitations in the way pages are rendered (only first 10 elements in a DataTable are cached), this is not intended for the end-user.

{#each all_auction_ids as auction}

- [{auction.auction_id}](/auctions/{auction.auction_id})

{/each}