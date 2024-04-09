# Vakantieveilingen.nl auctions tracker
This website tracks the auctions won on https://vakantieveilingen.nl, a Dutch auction website.

It is updated daily.


```sql most_recent_bid
select
    max(inserted_at) as latest,
    min(cast(inserted_at as timestamp)) as day,
    count(distinct title) as distinct_auctions,
    count(inserted_at) as total,
    (select count(inserted_at) as total from staging_auctions where winning_bid > 0) as total_winners
from staging_auctions
```

### Stats

- Most recent bid: <Value data={most_recent_bid} column="latest"/>
- Tracking since: <Value data={most_recent_bid} column="day"/>
- Total unique auctions: <Value data={most_recent_bid} column="distinct_auctions"/>
- Total winners: <Value data={most_recent_bid} column="total_winners" />

---



### Auctions

Search and find auctions. Click on the title to see the details of the auction.

```sql titles
select
    title,

    first('https://vakantieveilingen.nl/' || url) as url,
    count(*) as total,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    '/auctions/' || md5(title) as auction_id,
from staging_auctions
group by 1
```

<DataTable
    data="{titles}"
    search="true"
>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="total"/>
    <Column id="lowest_price"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>

---

### Navigation

Use the tabs on the left to navigate between the different sections of the website.

<img src="tabs.png" alt="drawing" width="200"/>
