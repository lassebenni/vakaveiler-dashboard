with deduped as (
    select
      distinct on("data_lot_product_title", "data_lot_tsEmbargo") *
    from auctions.auctions
    order by "data_lot_product_title", "data_lot_tsEmbargo", inserted_at desc
),

words as
(
select
    unnest(string_to_array(trim(both '[]' from "data_lot_product_keywords"), ',')) as keyword,
    count(*) as total

from deduped
group by 1
)

select *
from words
