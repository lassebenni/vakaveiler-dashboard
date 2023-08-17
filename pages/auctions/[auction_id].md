```sql stats
select
    title,
    max(md5(title)) as auction_id,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    min(day) as first_day,
    max(day) as last_day,
    count(*) as total
  from bids
  group by 1
```
# Stats

---

Auction: <b><Value data={stats.filter(d=>d.auction_id === $page.params.auction_id)} column="title" /></b>

Highest price: <b><Value data={stats.filter(d=>d.auction_id === $page.params.auction_id)} column="highest_price" /></b>

Lowest price: <b><Value data={stats.filter(d=>d.auction_id === $page.params.auction_id)} column="lowest_price" /></b>

First auction: <b><Value data={stats.filter(d=>d.auction_id === $page.params.auction_id)} column="first_day" /></b>

Most recent auction: <b><Value data={stats.filter(d=>d.auction_id === $page.params.auction_id)} column="last_day" /></b>

Total auctions: <b><Value data={stats.filter(d=>d.auction_id === $page.params.auction_id)} column="total" /></b>

# Daily

Highest and lowest winning bids per day.

```sql winning_bids
select
    title,
    day,
    max(md5(title)) as auction_id,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    count(winning_bid) as total
  from bids
  group by 1, 2
```

<LineChart
  data={winning_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=day
  y={["lowest_price", "highest_price"]}
/>

```sql daily_bids
select
    title,
    day,
    max(md5(title)) as auction_id,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids
  from bids
  group by 1, 2
  order by day desc
```

<DataTable 
  data="{daily_bids.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

---

# Hourly

```sql hourly_bids
select
    title,
    extract('hour' FROM strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f')) as hour,
    max(md5(title)) as auction_id,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids
  from bids
  group by 1, 2
  order by hour desc
```

<BarChart
  data={hourly_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=hour
  y={["lowest_price", "highest_price"]}
/>

<DataTable 
  data="{hourly_bids.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

---

# Weekdays

```sql weekday_bids
select
    title,
    extract('dayofweek' FROM strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f')) as day_nr,
    CASE EXTRACT('dayofweek' FROM strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f'))
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
     END AS weekday,
    max(md5(title)) as auction_id,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    count(*) as total,
    sum(count(*)) over (partition by title) as total_bids
  from bids
  group by 1, 2
  order by day_nr asc
```

<BarChart
  data={weekday_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=weekday
  y={["lowest_price", "highest_price"]}
/>

<DataTable 
  data="{weekday_bids.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

---

# Winners

```sql bidders
select
    title,
    customer_id,
    first_name,
    last_name,
    case when first_name is null then 'Unknown' else concat(first_name,' ', last_name) end as customer_name,
    max(md5(title)) as auction_id,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    min(day) as first_day,
    max(day) as last_day,
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids
  from bids
  group by title, customer_id, first_name, last_name
```

<BarChart
  data={bidders.filter(d=>d.auction_id === $page.params.auction_id)}
  x=customer_name
  y={["lowest_price", "highest_price"]}
/>

<DataTable 
  data="{bidders.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

---

# All wins

```sql all_bids
select *, md5(title) as auction_id
from bids
```

<DataTable
  data="{all_bids.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

