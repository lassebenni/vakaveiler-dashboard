# Daily top 3 (last week)

```sql daily_auctions
select
  date_trunc('day', inserted_at) as day,
  title,

  row_number() OVER (PARTITION BY date_trunc('day', inserted_at) ORDER BY count(*) DESC) as rank,
  count(*) as total

from staging_auctions
group by 1, 2
order by 1 asc, 3 asc
```

```sql top_daily
select
  day,
  title,
  '/auctions/' || md5(title) as auction_id,
  total
from ${daily_auctions}
where rank = 1 or rank = 2 or rank = 3
order by 1 desc
limit 3*7
```

<AreaChart
  data="{top_daily}"
  x=day
  y=total
  series=title
/>

<DataTable
  data="{top_daily}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="day"/>
    <Column id="total"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
</DataTable>

# Weekly top 3
```sql weekly_auctions
select
  date_part('year', inserted_at) as year,
  date_part('week', inserted_at) as week,
  title,

  row_number() OVER (PARTITION BY date_part('week', inserted_at) ORDER BY count(*) DESC) as rank,
  count(*) as total

from staging_auctions
group by 1, 2, 3
```

```sql top_weekly
select
  year,
  week,
  '/auctions/' || md5(title) as auction_id,
  title,
  total,
  rank
from ${weekly_auctions}
where rank = 1 or rank = 2 or rank = 3
order by 1 desc, 2 desc
limit 12
```

<AreaChart
  data="{top_weekly}"
  x=week
  y=total
  series=title
/>

<DataTable
  data="{top_weekly}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="year"/>
    <Column id="week"/>
    <Column id="total"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
</DataTable>

# Monthly top 3


```sql monthly_auctions
select
  date_part('year', inserted_at) as year,
  date_part('month', inserted_at) as month,
  title,

  count(*) as total,
  row_number() OVER (PARTITION BY year, month ORDER BY count(*) DESC) as rank

from staging_auctions
group by 1, 2, 3
```


```sql top_monthly
select
  year,
  month,
  title,
  '/auctions/' || md5(title) as auction_id,
  total
from ${monthly_auctions}
where rank = 1 or rank = 2 or rank = 3
order by 1 desc, 2 desc
limit 12
```


<AreaChart
  data="{top_monthly}"
  x=month
  y=total
  series=title
/>

<DataTable
  data="{top_monthly}"
  search="true"
  sortable="true"
  rows=20
>
    <Column id="year"/>
    <Column id="month"/>
    <Column id="total"/>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
</DataTable>

# Most Popular All time

```sql top_popular_bids
select
    title,
    url as url,
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
    <Column id="url"/>
</DataTable>