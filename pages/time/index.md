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

 # Best moments

```sql price_moments_2
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

  sum(winning_bid) AS median_price,
  count(*) AS sales_count

FROM staging_auctions
WHERE has_winner = 'True'
GROUP BY 1, 2, 3
order by 2 asc
```

```sql price_stats
  select 
    max(median_price) as max_median_price,
    min(median_price) as min_median_price,
    max(sales_count) as max_sales_count
  from ${price_moments_2}
```

```sql best_moments
    SELECT
        ps.weekday,
        ps.hour,
        ps.median_price,
        ps.sales_count,
        -- Calculate best moment score based on price difference and sales volume
        -- This CASE statement calculates the 'best_moment_score' based on the following logic:
        -- 1. If both 'ps.median_price' and 'ps.sales_count' are not NULL:
        --    a. Calculate the difference between 'pss.max_median_price' and 'ps.median_price'.
        --    b. Divide the result by the difference between 'pss.max_median_price' and 'pss.min_median_price', ensuring no division by zero using NULLIF.
        --    c. Multiply the result by the ratio of 'ps.sales_count' to 'pss.max_sales_count', ensuring no division by zero using NULLIF.
        -- 2. If either 'ps.median_price' or 'ps.sales_count' is NULL, the 'best_moment_score' is set to NULL.
        -- The 'best_moment_score' is then used to rank the rows in descending order using ROW_NUMBER().
        CASE
            WHEN ps.median_price IS NOT NULL AND ps.sales_count IS NOT NULL THEN
                ((pss.max_median_price - ps.median_price) / 
                    NULLIF((pss.max_median_price - pss.min_median_price), 0)) *
                (ps.sales_count::float / NULLIF(pss.max_sales_count, 0))
            ELSE NULL
        END AS best_moment_score,
        ROW_NUMBER() OVER (ORDER BY best_moment_score DESC) AS rank

    FROM ${price_moments_2} ps
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
  CASE
    WHEN rank <= 10 THEN median_price
    ELSE NULL
  END AS median_price
 FROM ${best_moments}
 ```

# Best Moment to Buy

<Heatmap 
  data={top_ten_best_moments}
  x="weekday"
  y="hour"
  value="median_price"
  colorPalette={['white', 'red', 'yellow', 'green']}
  min={1}
  title="Best Moment to Buy"
  subtitle="Top 10 best buying times (low median price & high sales)"
 />
