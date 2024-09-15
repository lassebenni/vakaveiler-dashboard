# Time
 
# Total spent day/hour combination

For each hour of the day, shows the total spent (sum of winning bids). Useful for tracking the most popular times to bid.

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
  EXTRACT('hour' FROM inserted_at) AS hour,

  count(*) AS total_bids,
  sum(winning_bid) AS total_price,
FROM staging_auctions
GROUP BY 1, 2
```

<Heatmap 
    data={price_moments} 
    x=weekday 
    y=hour 
    value=total_price 
    valueFmt=eur 
    colorPalette={['white', 'green', 'red']}
    title="Total spent per hour"
    subtitle="Total spent per hour of the day, for each weekday"
/>

<Heatmap 
    data={price_moments} 
    x=weekday 
    y=hour 
    value=total_bids 
    colorPalette={['white', 'green', 'red']}
    title="Most popular moments"
/>
