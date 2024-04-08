# Vakantieveilingen.nl auctions tracker

This website tracks the auctions won on https://vakantieveilingen.nl, a Dutch auction website. It is updated daily.

Click to go to the auctions page: [Auctions](auctions)

```sql most_recent_bid
select
    max(inserted_at) as latest,
    min(date_trunc('day', strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f'))) as day,
    count(distinct title) as distinct_auctions,
    count(inserted_at) as total,
    (select count(inserted_at) as total from bids where winning_bid > 0) as total_winners
from auctions
```

```sql most_recent_bid_v2
select *
from auctions.bids
```

### Stats

- Most recent bid: <Value data={most_recent_bid} column="latest"/>
- Tracking since: <Value data={most_recent_bid} column="day"/>
- Total unique auctions: <Value data={most_recent_bid} column="distinct_auctions"/>
- Total winners: <Value data={most_recent_bid} column="total_winners" />

# Top keywords

```sql top_keywords
    with key_words as (
        select
            unnest(
                regexp_split_to_array(
                    regexp_replace(
                        regexp_replace(
                            keywords, '\[', ''
                            ) , '\]', '')
                            , ',')
                        ) as keyword
        from bids
    )

    select
        keyword,
        count(*) as total
    from key_words
    where keyword != ''
    group by 1
    order by 2 desc
```

<DataTable
  data="{top_keywords}"
  search="true"
  sortable="true"
/>

<Dropdown
    data={top_keywords} 
    name=name_of_dropdown
    value=keyword
/>