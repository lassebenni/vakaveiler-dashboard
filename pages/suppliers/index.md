# Top suppliers

```sql top_suppliers
select
    supplier_name,

    count(*) as count,
    sum(winning_bid) as total_revenue,
    max(winning_bid) as highest_price,
    min(winning_bid) as lowest_price,
    max(inserted_at) as latest,
    min(inserted_at) as first

from staging_auctions
group by 1
order by count desc
```

<DataTable
  data="{top_suppliers}"
  search="true"
  sortable="true"
  rows=20
  fmt=eur
>
<Column id=supplier_name title='Supplier'/>
<Column id=count title='Total auctions'/>
<Column id=total_revenue fmt=nnum2m/>
<Column id=highest_price fmt=eur/>
<Column id=lowest_price fmt=eur/>
<Column id=latest/>
<Column id=first/>
</DataTable>