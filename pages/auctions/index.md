# All Auctions

```sql bids
select
    title,
    winning_bid,
    inserted_at,
    day,
    'https://vakantieveilingen.nl' || url as url
from bids
```

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

# Cheapest auctions

Top 100 auctions with the lowest winning bid.

```sql cheapest
WITH lowest_price AS (
  SELECT
    title,
    url,
    min(winning_bid) AS lowest_price
  FROM ${bids}
  GROUP BY title, url
)

SELECT
  l.title,
  'https://vakantieveilingen.nl' || l.url AS url,
  l.lowest_price,
  max(B.winning_bid) AS highest_price,
  count(B.winning_bid) AS total,
  min(B.inserted_at) AS min_date,
  max(B.inserted_at) AS max_date,
  max(md5(l.title)) AS auction_id,
  sum(CASE WHEN B.winning_bid = l.lowest_price THEN 1 ELSE 0 END) AS frequency_of_lowest_price
FROM lowest_price l
JOIN ${bids} B ON l.title = B.title AND l.url = B.url
GROUP BY l.title, l.url, l.lowest_price
ORDER BY l.lowest_price ASC, frequency_of_lowest_price DESC, total DESC
LIMIT 100
```


<DataTable
  data="{cheapest}"
  search="true"
  sortable="true"
  link="auction_id"
>
    <Column id="lowest_price"/>
    <Column id="frequency_of_lowest_price" title="Frequency"/>
    <Column id="title"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>


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
    max(md5(title)) as auction_id,
  from bids
  group by title, url
  order by total desc
  limit 100
```

Top 100 auctions with the most winning bids. Some recurring auctions can be bid on mulitple times a day.



<DataTable
  data="{top_popular_bids}"
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

Top 100 auctions with the highest winning bids.

```sql top_most_expensive
select
    title,
    'https://vakantieveilingen.nl' || url as url,
    max(winning_bid) as highest_price,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max(md5(title)) as auction_id,
  from bids
  group by title, url
  order by highest_price desc
  limit 100
```

<DataTable
  data="{top_most_expensive}"
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

Top 100 auctions with highest spread between winning bids. Spread is calculated by subtracting lowest winning bid price from highest price.

```sql top_spread
select
    title,
    'https://vakantieveilingen.nl' || url as url,
    max(winning_bid) - min(winning_bid) as spread,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    min(inserted_at) as min_date,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max(md5(title)) as auction_id,
  from bids
  group by 1, 2
  order by spread desc
  limit 100
```

<DataTable
  data="{top_spread}"
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
