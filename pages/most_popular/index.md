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

# Most Popular

```sql top_popular_bids
select
    title,
    'https://vakantieveilingen.nl' || url as url,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    count(*) as total,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max('/auctions/' || md5(title)) as auction_id,
  from staging_auctions
  group by title, url
  order by total desc
  limit 100
```

Top 100 auctions with the most winning bids. Some recurring auctions can be bid on mulitple times a day.

<DataTable
  data="{top_popular_bids}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="total"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="lowest_price"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>
