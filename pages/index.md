---
queries:
  - titles.sql
---

# Vakantieveilingen.nl auctions tracker
This website tracks the auctions won on https://vakantieveilingen.nl, a Dutch auction website.

It is updated daily.


```sql most_recent_bid
select
    max(inserted_at) as latest,
    min(cast(inserted_at as timestamp)) as day,
    count(distinct title) as distinct_auctions,
    count(inserted_at) as total,
    sum(winning_bid) as total_spent,
    (select count(inserted_at) as total from staging_auctions where winning_bid > 0) as total_winners
from staging_auctions
```

### Stats

- Most recent bid: <Value data={most_recent_bid} column="latest"/>
- Tracking since: <Value data={most_recent_bid} column="day"/>
- Total unique auctions: <Value data={most_recent_bid} column="distinct_auctions"/>
- Total spent: <Value data={most_recent_bid} column="total_spent" fmt=eur/>
- Total winners: <Value data={most_recent_bid} column="total_winners" />

---

# Auction count over time

```sql auction_count
select
  date_trunc('day', inserted_at) as day,

  count(*) as total_auctions
from staging_auctions
group by 1
order by 1 asc
```

<LineChart 
    data={auction_count}
    y=total_auctions
    x=day
    xAxisTitle="Days" 
    yAxisTitle="Total auctions" 
/>

---

### Navigation

Use the tabs on the left to navigate between the different sections of the website.

<img src="tabs.png" alt="drawing" width="200"/>
