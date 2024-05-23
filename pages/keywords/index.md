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


## Auctions by keyword

Find all auctions for a keyword

<Dropdown
    data={single_keywords_count}
    name=keywords
    value=keyword
    defaultValue=""
/>


```sql titles
select
    title,

    first(${inputs.keywords.value}) as keyword,
    first('https://vakantieveilingen' || url) as url,
    first(keywords) as keywords,
    count(*) as total,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    first(retail_price) as retail_price,
    min(winning_bid) as lowest_price,
    median(winning_bid) as median_price,
    max(winning_bid) as highest_price,
     '/auctions/' || md5(title) as auction_id,
from staging_auctions
where regexp_matches(keywords, ${inputs.keywords.value})
group by 1
```

<DataTable
    data="{titles}"
    search="true"
    rows=20
>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="keyword"/>
    <Column id="keywords"/>
    <Column id="total"/>
    <Column id="retail_price"/>
    <Column id="lowest_price"/>
    <Column id="median_price"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>
