# Unpopular auctions

Auctions that have more unsold than sold items

```sql unsold
select
    title,

    count(*) as unsold
from auctions_dupes
where highest_bid = 0
group by 1
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
    first(retail_price) as retail_price,
    max(winning_bid) as highest_bid,
    min(winning_bid) as lowest_bid,
    max(url) as url,
    '/auctions/' || md5(title) as auction_id,

from staging_auctions
inner join ${unsold} using (title)
where highest_bid > 0
group by 1, 2
having unsold > sold
order by 2 desc
```

---

<DataTable
    data="{unsold_sold}"
    search="true"
    rows=20
>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="unsold"/>
    <Column id="sold"/>
    <Column id="days_active"/>
    <Column id="retail_price"/>
    <Column id="lowest_bid"/>
    <Column id="highest_bid"/>
    <Column id="first_seen"/>
    <Column id="last_seen"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>

# Shortest running

Auctions that have only been active for one day

```sql shortest_running
select
    title,

    count(*) as sold,
    greatest(date_diff('day', min(inserted_at), max(inserted_at)), 1) as days_active,
    first(retail_price) as retail_price,
    min(inserted_at) as first_seen,
    max(inserted_at) as last_seen,
    max(winning_bid) as highest_bid,
    min(winning_bid) as lowest_bid,
    max(url) as url,
    '/auctions/' || md5(title) as auction_id,

from staging_auctions
group by 1
having last_seen < today()
and days_active = 1
order by days_active asc, sold desc
```

<DataTable
    data="{shortest_running}"
    search="true"
    rows=20
>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="sold"/>
    <Column id="days_active"/>
    <Column id="retail_price"/>
    <Column id="lowest_bid"/>
    <Column id="highest_bid"/>
    <Column id="first_seen"/>
    <Column id="last_seen"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>


---

# Unsold over time

Total number of unsold auctions over time

```sql unsold_over_time
select
    date_trunc('day', inserted_at) as day,
    count(*) as unsold
from auctions_dupes
where highest_bid = 0
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
