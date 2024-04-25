with auctions as 
(
SELECT
  REPLACE(data_lot_product_title, ':', '') AS title,
  CAST(NULLIF(last_won_bid, 'None') AS INTEGER) AS winning_bid,
  CAST(NULLIF("data_lot_highestBidAmount", 'None') AS INTEGER) as highest_bid,

  cast(inserted_at as timestamp) as inserted_at,
  date(inserted_at) as day,

  data_lot_product_url AS url,
  "data_highestBid_bidder_lastName" AS winner_last_name,
  "data_highestBid_bidder_firstName" AS winner_first_name,
  "data_highestBid_bidder_customerId" AS winner_customer_id,
  "data_lot_product_keywords" AS keywords,
  "data_lot_product_supplier_name" AS supplier_name,
  "data_lot_tsExpires" AS expires_at,
  "data_isRunning" AS is_running

FROM
  auctions.auctions
)

select *
from auctions
where inserted_at > cast('2024-01-01' as timestamp)