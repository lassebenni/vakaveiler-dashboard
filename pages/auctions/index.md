# All Auctions

All auctions in the database. You can search for an auction by name. Click on auction to go to the details page.

```sql titles
select
    title,
    md5(title) as auction_id,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date
from bids
group by 1
```

<DataTable
    data="{titles}"
    link="auction_id"
    search=true
/>

# Most Popular

Top 10 auctions with the most winning bids. Some recurring auctions can be bid on mulitple times a day.

```sql bids
select
    title,
    winning_bid,
    inserted_at,
    date_trunc('day', strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f')) as day,
    'https://vakantieveilingen.nl' || url as url
from bids
```

```sql top_10_popular_bids
select
    title,
    url,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    count(winning_bid) as total,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max(md5(title)) as auction_id,
  from ${bids}
  group by title, url
  order by total desc
  limit 10
```

<DataTable
  data="{top_10_popular_bids}"
  search="true"
  sortable="true"
  link="auction_id"
>
    <Column id="total"/>
    <Column id="title"/>
    <Column id="lowest_price"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>

# Most expensive

Top 10 auctions with the highest winning bids.

```sql top_10_most_expensive
select
    title,
    url,
    max(winning_bid) as highest_price,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max(md5(title)) as auction_id,
  from ${bids}
  group by title, url
  order by highest_price desc
  limit 10
```

<DataTable
  data="{top_10_most_expensive}"
  search="true"
  sortable="true"
  link="auction_id"
>
  <Column id="highest_price"/>
  <Column id="title"/>
  <Column id="min_date"/>
  <Column id="max_date"/>
  <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>

# Largest spread

Top 10 auctions with highest spread between winning bids. Spread is calculated by subtracting lowest winning bid price from highest price.

```sql top_10_spread
select
    title,
    url,
    max(winning_bid) - min(winning_bid) as spread,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    min(inserted_at) as min_date,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max(md5(title)) as auction_id,
  from ${bids}
  group by 1, 2
  order by spread desc
  limit 10
```

<DataTable
  data="{top_10_spread}"
  search="true"
  sortable="true"
  link="auction_id"
>
    <Column id="spread"/>
    <Column id="title"/>
    <Column id="lowest_price"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>
