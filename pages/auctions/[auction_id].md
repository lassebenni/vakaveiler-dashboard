---
queries:
  - sold_unsold: sold_unsold.sql
  - unsold: unsold.sql
---

```sql stats
select
  *
from ${sold_unsold}
where md5(title) = '${params.auction_id}'
```

# Stats

<script>
$: stats_filtered = stats.filter(d => d.auction_id === $page.params.auction_id);
$: url = stats_filtered.length > 0 ? stats_filtered[0].url : ""
</script>


Auction: <b><Value data={stats_filtered} column="title" /></b>

Url:  <u><a href="{url}">{url}</a><u>

Total: <b><Value data={stats_filtered} column="total" /></b>

Sold: <b><Value data={stats_filtered} column="sold" /></b>

Unsold: <b><Value data={stats_filtered} column="unsold" /></b>


Retail price: <b><Value data={stats_filtered} column="retail_price" /></b>

Highest bid: <b><Value data={stats_filtered} column="highest_price" /></b>

Median bid: <b><Value data={stats_filtered} column="median_price" /></b>

Lowest bid: <b><Value data={stats_filtered} column="lowest_price" /></b>

First seen: <b><Value data={stats_filtered} column="first_seen" /></b>

Last seen: <b><Value data={stats_filtered} column="last_seen" /></b>


# Winning bids

Winning bids count.



```sql prices
select
    title,
    coalesce(winning_bid, 0) as winning_bid,

    count(*) as total,
    min(day) as first_day,
    max(day) as last_day,
    max(md5(title)) as auction_id
  from staging_auctions
  where highest_price > 0
  and md5(title) = '${params.auction_id}'
  group by 1, 2
  order by total desc
```

<BarChart
  data={prices.filter(d=>d.auction_id === $page.params.auction_id)}
  x=winning_bid
  y=total
/>

<DataTable 
  data={prices.filter(d=>d.auction_id === $page.params.auction_id)}
>
    <Column id="winning_bid"/>
    <Column id="total"/>
    <Column id="last_day"/>
    <Column id="first_day"/>
</DataTable>

# Daily


```sql winning_bids
select
    title,
    day,

    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    median(winning_bid) as median_price,
    count(winning_bid) as total,
    max(md5(title)) as auction_id,
  from staging_auctions
  where highest_price > 0
  and md5(title) = '${params.auction_id}'
  group by 1, 2
```

Highest and lowest winning bids per day.

<BarChart
  data={winning_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=day
  y={["lowest_price", "median_price", "highest_price"]}
/>

Total auctions per day.

<LineChart
  data={winning_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=day
  y="total"
/>


```sql daily_bids
select
    title,
    day,

    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids,
    max(md5(title)) as auction_id,
  from staging_auctions
  where highest_price > 0
  and md5(title) = '${params.auction_id}'
  group by 1, 2
  order by day desc
```

Table for daily winners.

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
    extract('hour' FROM inserted_at) as hour,

    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    median(winning_bid) as median_price,
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids,
    max(md5(title)) as auction_id,
  from staging_auctions
  where highest_price > 0
  and md5(title) = '${params.auction_id}'
  group by 1, 2
  order by hour asc
```

Winners per hour of the day.

<BarChart
  data={hourly_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=hour
  y={["lowest_price", "median_price", "highest_price"]}
/>

Total auctions per hour of the day.

<LineChart
  data={hourly_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=hour
  y=total
/>

Table for hourly winners.

<DataTable 
  data="{hourly_bids.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

# Weekdays

```sql weekday_bids
select
    title,
    extract('dayofweek' FROM inserted_at) as day_nr,

    CASE EXTRACT('dayofweek' FROM inserted_at)
        WHEN 0 THEN 'Sun.'
        WHEN 1 THEN 'Mon.'
        WHEN 2 THEN 'Tue.'
        WHEN 3 THEN 'Wed.'
        WHEN 4 THEN 'Thu.'
        WHEN 5 THEN 'Fri.'
        WHEN 6 THEN 'Sat.'
     END AS weekday,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    median(winning_bid) as median_price,
    count(*) as total,
    sum(count(*)) over (partition by title) as total_bids,
    max(md5(title)) as auction_id,
  from staging_auctions
  where highest_price > 0
  and md5(title) = '${params.auction_id}'
  group by 1, 2
  order by day_nr asc
```

Winners on each day of the week.

<BarChart
  data={weekday_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=weekday
  y={["lowest_price", "median_price", "highest_price"]}
  type=grouped
  sort=false
/>

Total auctions on each day of the week.

<LineChart
  data={weekday_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=weekday
  y=total
  sort=false
/>

Weekday winners table.

<DataTable 
  data="{weekday_bids.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

---

# Customers

```sql bidders
select
    title,
    winner_customer_id,
    winner_first_name,
    winner_last_name,
    case when winner_first_name is null then 'Unknown' else concat(winner_first_name,' ', winner_last_name) end as winner_customer_name,

    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    median(winning_bid) as median_price,
    min(day) as first_day,
    max(day) as last_day,
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids,
    max(md5(title)) as auction_id,
  from staging_auctions
  where highest_price > 0
  and md5(title) = '${params.auction_id}'
  group by 1, 2, 3, 4
  order by total desc
```

Total number of won auctions per customer.

<BarChart
  data={bidders.filter(d=>d.auction_id === $page.params.auction_id)}
  x="winner_customer_name"
  y="total"
/>

Table for customer's that won this auction.
 
<DataTable 
  data="{bidders.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

# Price distribution over time

```sql price_distribution
select
  date_trunc('day', inserted_at) as day,

  count(*) as total_auctions,
  avg(winning_bid) as avg_winning_bid,
  median(winning_bid) as median_winning_bid,
  min(winning_bid) as min,
  max(winning_bid) as max,
from staging_auctions
where md5(title) = '${params.auction_id}'
group by 1
order by 1 asc
```

<LineChart 
    data={price_distribution}
    y={["median_winning_bid", "avg_winning_bid"]}
    x=day
    xAxisTitle="Days"
    yAxisTitle="Median Winning Bid"
>
</LineChart>


```sql prices_daily
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
where md5(title) = '${params.auction_id}'
group by 1, 2
order by 1 asc
```

<BoxPlot
    data={prices_daily}
    name=month_name
    midpoint=median_winning_bid
    min=min
    max=max
    intervalBottom=q5
    intervalTop=q95
/>


---
# Unsold over time

Total number of unsold auctions over time

```sql unsold_over_time
select
    day,
    unsold

from ${unsold}
where md5(title) = '${params.auction_id}'
```


<LineChart
    data={unsold_over_time}
    y=unsold
    x=day
    xAxisTitle="Days" 
    yAxisTitle="Unsold" 
/>
