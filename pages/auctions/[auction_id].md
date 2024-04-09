```sql stats
select
    title,

    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    min(day) as first_day,
    max(day) as last_day,
    count(*) as total,
    max(md5(title)) as auction_id,
    max('https://vakantieveilingen.nl' || url) as link
  from staging_auctions
  group by 1
```
# Stats

---

<script>
$: stats_filtered = stats.filter(d => d.auction_id === $page.params.auction_id);
$: link = stats_filtered.length > 0 ? stats_filtered[0].link : ""
</script>


Auction: <b><Value data={stats_filtered} column="title" /></b>

Url:  <u><a href="{link}">{link}</a><u>

Highest price: <b><Value data={stats_filtered} column="highest_price" /></b>

Lowest price: <b><Value data={stats_filtered} column="lowest_price" /></b>

First auction: <b><Value data={stats_filtered} column="first_day" /></b>

Most recent auction: <b><Value data={stats_filtered} column="last_day" /></b>

Total auctions: <b><Value data={stats_filtered} column="total" /></b>

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
    count(winning_bid) as total,
    max(md5(title)) as auction_id,
  from staging_auctions
  group by 1, 2
```

Highest and lowest winning bids per day.

<LineChart
  data={winning_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=day
  y={["lowest_price", "highest_price"]}
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
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids,
    max(md5(title)) as auction_id,
  from staging_auctions
  group by 1, 2
  order by hour asc
```

Winners per hour of the day.

<BarChart
  data={hourly_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=hour
  y={["lowest_price", "highest_price"]}
/>

Total auctions per hour of the day.

<BarChart
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
    count(*) as total,
    sum(count(*)) over (partition by title) as total_bids,
    max(md5(title)) as auction_id,
  from staging_auctions
  group by 1, 2
  order by day_nr asc
```

Winners on each day of the week.

<BarChart
  data={weekday_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=weekday
  y={["lowest_price", "highest_price"]}
  type=grouped
/>

Total auctions on each day of the week.

<BarChart
  data={weekday_bids.filter(d=>d.auction_id === $page.params.auction_id)}
  x=weekday
  y=total
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
    customer_id,
    first_name,
    last_name,
    case when first_name is null then 'Unknown' else concat(first_name,' ', last_name) end as customer_name,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    min(day) as first_day,
    max(day) as last_day,
    count(*) as total,
    sum(count(*)) over (partition by title) as daily_bids,
    max(md5(title)) as auction_id,
  from staging_auctions
  group by title, customer_id, first_name, last_name
  order by total desc
```

Total number of won auctions per customer.

<BarChart
  data={bidders.filter(d=>d.auction_id === $page.params.auction_id)}
  x="customer_name"
  y="total"
/>

Table for customer's that won this auction.
 
<DataTable 
  data="{bidders.filter(d=>d.auction_id === $page.params.auction_id)}"
  search="true"
  sortable="true"
/>

