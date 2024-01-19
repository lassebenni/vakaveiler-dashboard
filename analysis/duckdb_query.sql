install sqlite
;
load sqlite
;
attach 'analysis/veilingen.sqlite' as veilingen(type sqlite)
;

CREATE TABLE bids AS (
with 
cleaned_auctions as 
(
select
  replace(data_lot_product_title, ':', '') as title,
  try_cast(last_won_bid as int) as winning_bid,
  strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f') as inserted_at,
  date_trunc('day', strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f')) as day,
  data_lot_product_url as url,
  data_highestBid_bidder_lastName as last_name,
  data_highestBid_bidder_firstName as first_name,
  data_highestBid_bidder_customerId as customer_id,
  data_lot_product_keywords as keywords,
  data_lot_product_supplier_name as supplier_name
from veilingen.auctions
),

total_bids as (
  select
    title,
    count(*) as total_bids,
    max(inserted_at) as last_bid
  from cleaned_auctions
  group by 1
  having date_diff('day', last_bid, now()::timestamp) < 1
    or (total_bids >= 100 and date_diff('day', inserted_at, now()::timestamp) > 1)
),



filtered as (
  select
    title,
    winning_bid,
    inserted_at,
    day,
    url,
    last_name,
    first_name,
    customer_id,
    keywords
  from cleaned_auctions
  inner join total_bids using (title)
)

select *
from cleaned_auctions
-- Only last 7 days
where date_diff('day', inserted_at, now()::timestamp) <= 7
);
