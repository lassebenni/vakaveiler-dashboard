# All auctions (unique titles)

All unique auction titles in the database. You can search for an auction by name. Click on the auction title to go to the details page.


```sql titles
select
    title,

    first('https://vakantieveilingen' || url) as url,
    count(*) as total,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    first(retail_price) as retail_price,
    min(winning_bid) as lowest_price,
    median(winning_bid) as median_price,
    max(winning_bid) as highest_price,
    md5(title) as auction_id,
from staging_auctions
group by 1
```

<DataTable
    data="{titles}"
    search="true"
    rows=20
>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="total"/>
    <Column id="retail_price"/>
    <Column id="lowest_price"/>
    <Column id="median_price"/>
    <Column id="highest_price"/>
    <Column id="min_date"/>
    <Column id="max_date"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>
