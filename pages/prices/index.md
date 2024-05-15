# Prices

Several price analysis of auctions can be found here.

```sql prices
SELECT
  l.title,
  l.url,

  count(*) AS total_auctions,
  max(l.winning_bid) AS highest_price,
  min(l.winning_bid) AS lowest_price,
  min(l.inserted_at) AS min_date,
  max(l.inserted_at) AS max_date,
  max('/auctions/' || md5(l.title)) as auction_id,
  median(l.winning_bid) AS median_winning_bid,
  sum(CASE WHEN l.winning_bid = l.min_winning_bid THEN 1 ELSE 0 END) AS frequency_of_lowest_price,
  sum(CASE WHEN l.winning_bid = l.max_winning_bid THEN 1 ELSE 0 END) AS frequency_of_highest_price,
from (
  select *,
    min(winning_bid) OVER (PARTITION BY title, url) AS min_winning_bid,
    max(winning_bid) OVER (PARTITION BY title, url) AS max_winning_bid
  from staging_auctions
) l
group by 1, 2
```

# Cheapest auctions

Top 100 auctions with the lowest winning bid.

```sql cheapest
SELECT
  title,
  lowest_price,
  total_auctions,
  min_date,
  max_date,
  auction_id,
  frequency_of_lowest_price
FROM ${prices}
ORDER BY lowest_price ASC, frequency_of_lowest_price DESC, total_auctions DESC
LIMIT 100
```

<DataTable
  data="{cheapest}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="lowest_price"/>
    <Column id="frequency_of_lowest_price" title="Frequency"/>
    <Column id="total_auctions"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
</DataTable>

---

# Highest bids

Top 100 auctions with the highest winning bids.

```sql top_most_expensive
SELECT
  title,
  highest_price,
  total_auctions,
  min_date,
  max_date,
  auction_id,
  frequency_of_highest_price,
  'https://vakantieveilingen.nl' || url as url,
FROM ${prices}
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
  <Column id="frequency_of_highest_price" title="Frequency"/>
  <Column id="total_auctions"/>
  <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
  <Column id="min_date"/>
  <Column id="max_date"/>
  <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>

---

# Largest Bid spread

Top 100 auctions with highest spread between winning bids. Spread is calculated by subtracting lowest winning bid price from highest price.

```sql top_spread
select
    title,
    'https://vakantieveilingen.nl' || url as url,

    count(*) as total_auctions,
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
    <Column id="highest_price"/>
    <Column id="lowest_price"/>
    <Column id="total_auctions"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>

---

# Largest Retail Price Spread

Top 100 auctions with highest spread between winning bid and retail price.

```sql retail_spread
select
    title,
    'https://vakantieveilingen.nl' || url as url,

    greatest( max(winning_bid) - first(retail_price), first(retail_price) - min(winning_bid)) as retail_spread,
    count(*) as total_auctions,
    first(retail_price) as retail_price,
    max(winning_bid) as highest_bid,
    min(winning_bid) as lowest_bid,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    max('/auctions/' || md5(title)) as auction_id,
  from staging_auctions
  group by 1, 2
  order by retail_spread desc
  limit 100
```

<DataTable
  data="{retail_spread}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="retail_spread"/>
    <Column id="retail_price"/>
    <Column id="highest_bid"/>
    <Column id="lowest_bid"/>
    <Column id="total_auctions"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>
---

# Price distribution over time

```sql prices_daily
select
  date_trunc('day', inserted_at) as day,

  count(*) as total_auctions,
  avg(winning_bid) as avg_winning_bid,
  median(winning_bid) as median_winning_bid,
  min(winning_bid) as min,
  max(winning_bid) as max,
from staging_auctions
group by 1
order by 1 asc
```

<LineChart 
    data={prices_daily} 
    y={["median_winning_bid", "avg_winning_bid"]}
    x=day 
    xAxisTitle="Days" 
    yAxisTitle="Median Winning Bid" 
>
</LineChart>


# Monthly price distribution (Boxplot)

```sql prices_monthly
select
  date_trunc('month', inserted_at) as month,
  monthname(inserted_at) as month_name,

  count(*) as total_auctions,
  median(winning_bid) as median_winning_bid,
  min(winning_bid) as min,
  max(winning_bid) as max,
  stddev_pop(winning_bid) as std_dev,
  percentile_cont(0.25) within group (order by winning_bid) as q1,
  percentile_cont(0.75) within group (order by winning_bid) as q3,
  percentile_cont(0.05) within group (order by winning_bid) as q5,
  percentile_cont(0.95) within group (order by winning_bid) as q95,
from staging_auctions
group by 1, 2
order by 1 asc
```

<BoxPlot
    data={prices_monthly}
    name=month_name
    midpoint=median_winning_bid
    min=min
    max=max
    intervalBottom=q5
    intervalTop=q95
/>