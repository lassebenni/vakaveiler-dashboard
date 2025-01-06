```sql base
select
    *
from staging_auctions
where md5(title) = '${params.auction_id}'
```



```sql unsold_total
select
    title,

    count(*) as unsold
from ${base}
where has_winner = 'False'
group by 1
```

```sql stats
select
    title,

    count(*) as sold,
    first(unsold) as unsold,
    coalesce(first(unsold), 0) + count(*) as total,
    first(retail_price) as retail_price,
    sum(winning_bid) as total_spent,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    median(winning_bid) as median_price,
    min(day) as first_seen,
    max(day) as last_seen,
    max(md5(title)) as auction_id,
    max('https://vakantieveilingen.nl' || url) as url

from ${base}
left join ${unsold_total} using (title)
where has_winner = 'True'
group by 1
```

# Stats


Auction: <b><Value data={stats} column="title" /></b>

URL: <b><Value data={stats} column="url" /></b>

Total Auctions: <b><Value data={stats} column="total" /></b>

Sold: <b><Value data={stats} column="sold" /></b>

Unsold: <b><Value data={stats} column="unsold" /></b>

Total Spent: <b><Value data={stats} column="total_spent" /></b>

Retail price: <b><Value data={stats} column="retail_price" /></b>

Highest bid: <b><Value data={stats} column="highest_price" /></b>

Median bid: <b><Value data={stats} column="median_price" /></b>

Lowest bid: <b><Value data={stats} column="lowest_price" /></b>

First seen: <b><Value data={stats} column="first_seen" /></b>

Last seen: <b><Value data={stats} column="last_seen" /></b>



```sql price_moments
SELECT
  CASE EXTRACT('dayofweek' FROM inserted_at)
        WHEN 0 THEN 'Sun.'
        WHEN 1 THEN 'Mon.'
        WHEN 2 THEN 'Tue.'
        WHEN 3 THEN 'Wed.'
        WHEN 4 THEN 'Thu.'
        WHEN 5 THEN 'Fri.'
        WHEN 6 THEN 'Sat.'
     END AS weekday,
  EXTRACT('dayofweek' FROM inserted_at) as weekday_number,
  EXTRACT('hour' FROM inserted_at) AS hour,

  median(winning_bid) AS median_price,
  count(*) AS sales_count

FROM ${base}
WHERE has_winner = 'True'
GROUP BY 1, 2, 3
order by 2 asc
```

# Median Price per Hour


```sql price_stats
  select 
    max(median_price) as max_median_price,
    min(median_price) as min_median_price,
    max(sales_count) as max_sales_count
  from ${price_moments}
```

```sql best_moments
    SELECT
        ps.weekday,
        ps.hour,
        ps.median_price,
        ps.sales_count,
        -- Calculate best moment score based on price difference and sales volume
        CASE
            WHEN ps.median_price IS NOT NULL AND ps.sales_count IS NOT NULL THEN
                ((pss.max_median_price - ps.median_price) / 
                    NULLIF((pss.max_median_price - pss.min_median_price), 0)) *
                (ps.sales_count::float / NULLIF(pss.max_sales_count, 0))
            ELSE NULL
        END AS best_moment_score,
        ROW_NUMBER() OVER (ORDER BY best_moment_score DESC) AS rank

    FROM ${price_moments} ps
    CROSS JOIN ${price_stats} pss
    order by weekday_number asc
 ```

 ```sql top_ten_best_moments
 SELECT
    weekday,
    hour,
    rank,
    sales_count,
    best_moment_score,
    case
        when rank <= 20 THEN median_price
        else null
    end as median_price

  FROM ${best_moments}
 ```

# Best Moment to Buy

<Heatmap 
    data={top_ten_best_moments}
    x="weekday"
    y="hour"
    value="median_price"
    colorPalette={['white', 'red', 'yellow', 'green']}
    min=1
    title="Best Moment to Buy"
    subtitle="Top 10 best buying times (low median price & high sales)"
 />

 # Sales per Hour

 <Heatmap 
    data={price_moments}
    x="weekday"
    y="hour"
    value="sales_count"
    colorPalette={['red', 'yellow', 'green']}
    min=1
    title="Sales per Hour"
    subtitle="Number of sales per hour of the day, for each weekday"
 />

 # Median Price per Hour

 <Heatmap 
    data={price_moments}
    x="weekday"
    y="hour"
    value="median_price"
    colorPalette={['white', 'green', 'yellow', 'red']}
    min=1
    title="Median Price per Hour"
    subtitle="Median price per hour of the day, for each weekday"
 />


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
  where has_winner = 'True'
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



# Price distribution over time

```sql price_distribution
select
  date_trunc('day', inserted_at) as day,

  count(*) as total_auctions,
  avg(winning_bid) as avg_winning_bid,
  median(winning_bid) as median_winning_bid,
  min(winning_bid) as min,
  max(winning_bid) as max,
from ${base}
where has_winner = 'True'
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
from ${base}
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
