# Keywords
Auctions by keyword

## Combined keywords

```sql comined_keywords
select
    string_to_array(NULLIF(trim(both '[]' from keywords), ''), ',') as keywords,
    count(*) as total
from staging_auctions
group by 1
order by 2 desc
```

<DataTable
    search="true"
    data="{comined_keywords}"
/>

## Individual keywords

```sql single_keywords
select
    unnest(keywords) AS keyword,
    total
from ${comined_keywords}
```

```sql single_keywords_count
select
    keyword,
    sum(total) as total
from ${single_keywords}
group by 1
order by 2 desc
```

<DataTable
    search="true"
    data="{single_keywords_count}"
/>


## Keyword Popularity Over Time

```sql keyword_popularity
with unnested_keywords as (
    select
        date_trunc('month', inserted_at) as month,
        unnest(string_to_array(NULLIF(trim(both '[]' from keywords), ''), ',')) as keyword
    from staging_auctions
),
top_keywords as (
    select
        keyword,
        sum(count(*)) over (partition by keyword) as total
    from unnested_keywords
    group by keyword
    order by total desc
    limit 5
)
select
    month,
    keyword,
    count(*) as total
from unnested_keywords
where keyword in (select keyword from top_keywords)
group by 1, 2
order by 1, 2
```

<AreaChart
    data="{keyword_popularity}"
    x="month"
    y="total"
    series="keyword"
    title="Top 10 Most Popular Keywords Over Time"
/>
