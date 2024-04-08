with 
cleaned_auctions as 
(
SELECT
  REPLACE(data_lot_product_title, ':', '') AS title,
  CAST(NULLIF(last_won_bid, 'None') AS INTEGER) AS winning_bid,

  cast(inserted_at as timestamp) as inserted_at,
  date(inserted_at) as day,

  data_lot_product_url AS url,
  "data_highestBid_bidder_lastName" AS last_name,
  "data_highestBid_bidder_firstName" AS first_name,
  "data_highestBid_bidder_customerId" AS customer_id,
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
    title,
    winning_bid,
    inserted_at,
    day,
    url,
    last_name,
    first_name,
    supplier_name,
    customer_id,
    keywords
  from cleaned_auctions
  inner join total_bids using (title)
)


select * from filtered
