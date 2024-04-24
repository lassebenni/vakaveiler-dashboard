# Auction count over time

```sql unsold
select
    title,
    expires_at,

    count(*) as unsold
from auctions_s
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

---

Unsold over time

```sql unsold_over_time
select
    date_trunc('day', inserted_at) as day,
    count(*) as unsold
from auctions_s
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
