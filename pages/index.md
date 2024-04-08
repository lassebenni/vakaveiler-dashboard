---
queries:
  - total_bids.sql
---

# Vakantieveilingen.nl auctions tracker


This website tracks the auctions won on https://vakantieveilingen.nl, a Dutch auction website. It is updated daily.

Click to go to the auctions page: [Auctions](auctions)

```sql most_recent_bid
select *
from ${total_bids}
```

### Stats

- Most recent bid: <Value data={most_recent_bid} column="latest"/>
- Tracking since: <Value data={most_recent_bid} column="day"/>
- Total unique auctions: <Value data={most_recent_bid} column="distinct_auctions"/>
- Total winners: <Value data={most_recent_bid} column="total_winners" />
