# Auction count over time

```sql unsold
select
    title,
    expires_at,

    count(*) as unsold
from auctions_dupes
where is_running = False
and highest_bid = 0
group by 1, 2
having unsold > 1
order by unsold desc
```

```sql unsold_sold
select
    title,
    unsold,

    count(*) as sold,
    greatest(date_diff('day', min(inserted_at), max(inserted_at)), 1) as days_active,
    min(inserted_at) as first_seen,
    max(inserted_at) as last_seen,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    max(url) as url

from staging_auctions
inner join ${unsold} using (title)
group by 1, 2
having unsold > sold
```

---

# Unpopular auctions

<DataTable
  data="{unsold_sold}"
  search="true"
  sortable="true"
  rows=20
/>

# Shortest running

```sql shortest_running
select
    title,

    count(*) as sold,
    greatest(date_diff('day', min(inserted_at), max(inserted_at)), 1) as days_active,
    min(inserted_at) as first_seen,
    max(inserted_at) as last_seen,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    max(url) as url

from staging_auctions
group by 1
having last_seen < today()
and days_active = 1
order by days_active asc, sold desc
```

<DataTable
  data="{shortest_running}"
  search="true"
  sortable="true"
  rows=20
/>


---

Unsold over time

```sql unsold_over_time
select
    date_trunc('day', inserted_at) as day,
    count(*) as unsold
from auctions_dupes
where is_running = False
and highest_bid = 0
group by 1
having unsold > 1
```


<LineChart 
    data={unsold_over_time}
    y=unsold
    x=day
    xAxisTitle="Days" 
    yAxisTitle="Total auctions" 
/>
