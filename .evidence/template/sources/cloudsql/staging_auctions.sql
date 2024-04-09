with 
cleaned_auctions as 
(
SELECT
  REPLACE(data_lot_product_title, ':', '') AS title,
  CAST(NULLIF(last_won_bid, 'None') AS INTEGER) AS winning_bid,

  cast(inserted_at as timestamp) as inserted_at,
  date(inserted_at) as day,

  data_lot_product_url AS url,
  "data_highestBid_bidder_lastName" AS winner_last_name,
  "data_highestBid_bidder_firstName" AS winner_first_name,
  "data_highestBid_bidder_customerId" AS winner_customer_id,
  "data_lot_product_keywords" AS keywords,
  "data_lot_product_supplier_name" AS supplier_name
FROM
  auctions.auctions
),

total_bids as (
  select
    title,

    count(*) as total_bids,
    max(inserted_at) as last_bid
  from cleaned_auctions
  group by 1
),

filtered as (
  select
    inserted_at,
    title,
    winning_bid,
    total_bids,
    last_bid,
    day,
    url,
    winner_last_name,
    winner_first_name,
    winner_customer_id,
    supplier_name,
    keywords
  from cleaned_auctions
  inner join total_bids using (title)
)


select *
from filtered
-- Only 2024
where inserted_at > cast('2024-01-01' as timestamp)
