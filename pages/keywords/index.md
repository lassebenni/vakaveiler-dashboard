# Keyword count
```sql keyword_count
select
    keyword,
    total
from keywords
order by total desc
```

---

# Keyword count

<DataTable
  data="{keyword_count}"
  search="true"
  sortable="true"
  rows=20
/>

