INSTALL sqlite;
LOAD sqlite;
ATTACH 'analysis/veilingen.sqlite' AS veilingen (TYPE SQLITE);

CREATE TABLE bids AS (
select
  replace(data_lot_product_title, ':', '') as title,
  cast(last_won_bid as int) as winning_bid,
  inserted_at,
  date_trunc('day', strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f')) as day,
  data_lot_product_url as url,
  data_highestBid_bidder_lastName as last_name,
  data_highestBid_bidder_firstName as first_name,
  data_highestBid_bidder_customerId as customer_id
from veilingen.auctions
);

