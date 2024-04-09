# Cheapest auctions

Top 100 auctions with the lowest winning bid.

```sql lowest_prices
  SELECT
    title,
    url,

    min(winning_bid) AS lowest_price
  FROM staging_auctions
  GROUP BY 1, 2
```

```sql cheapest
SELECT
  l.title,
  l.lowest_price,

  max(B.winning_bid) AS highest_price,
  count(B.winning_bid) AS total,
  min(B.inserted_at) AS min_date,
  max(B.inserted_at) AS max_date,
  max('/auctions/' || md5(l.title)) as auction_id,
  sum(CASE WHEN B.winning_bid = l.lowest_price THEN 1 ELSE 0 END) AS frequency_of_lowest_price
FROM lowest_prices l
JOIN staging_auctions B ON l.title = B.title AND l.url = B.url
GROUP BY 1, 2
ORDER BY l.lowest_price ASC, frequency_of_lowest_price DESC, total DESC
LIMIT 100
```

<DataTable
  data="{cheapest}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="lowest_price"/>
    <Column id="frequency_of_lowest_price" title="Lowest"/>
    <Column id="total"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
</DataTable>

# Most expensive

Top 100 auctions with the highest winning bids.

```sql top_most_expensive
select
    title,
    'https://vakantieveilingen.nl' || url as url,

    count(*) as total,
    max(winning_bid) as highest_price,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max('/auctions/' || md5(title)) as auction_id,
  from staging_auctions
  group by 1, 2
  order by highest_price desc
  limit 100
```

<DataTable
  data="{top_most_expensive}"
  search="true"
  sortable="true"
  rows=20
>
  <Column id="highest_price"/>
  <Column id="total"/>
  <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
  <Column id="min_date"/>
  <Column id="max_date"/>
  <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>

# Largest spread

Top 100 auctions with highest spread between winning bids. Spread is calculated by subtracting lowest winning bid price from highest price.

```sql top_spread
select
    title,
    'https://vakantieveilingen.nl' || url as url,

    count(*) as total,
    max(winning_bid) - min(winning_bid) as spread,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max('/auctions/' || md5(title)) as auction_id,
  from staging_auctions
  group by 1, 2
  order by spread desc
  limit 100
```

<DataTable
  data="{top_spread}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="spread"/>
    <Column id="total"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="lowest_price"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>