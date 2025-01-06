WITH deduped AS (
    SELECT DISTINCT ON ("data_lot_product_title", "data_lot_tsEmbargo")
        *,
        REPLACE(data_lot_product_title, ':', '') AS title
    FROM auctions.auctions_v2
    WHERE inserted_at::timestamp >= date_trunc('month', now() - interval '5 month') AND inserted_at IS NOT NULL
    ORDER BY "data_lot_product_title", "data_lot_tsEmbargo", inserted_at DESC
),
cleaned_auctions AS (
    SELECT
        title,
        NULLIF(last_won_bid, 'None')::INTEGER AS winning_bid,
        NULLIF("data_lot_highestBidAmount", 'None')::INTEGER AS highest_price_amount,
        NULLIF("data_highestBid_price", 'None')::INTEGER AS highest_price,
        COALESCE("data_hasWinner", 'false') AS has_winner,
        inserted_at::timestamp AS inserted_at,
        date(inserted_at) AS day,
        data_lot_product_url AS url,
        "data_highestBid_bidder_lastName" AS winner_last_name,
        "data_highestBid_bidder_firstName" AS winner_first_name,
        "data_highestBid_bidder_customerId" AS winner_customer_id,
        "data_lot_product_keywords" AS keywords,
        "data_lot_product_supplier_name" AS supplier_name,
        "data_lot_tsExpires" AS expires_at,
        "data_lot_product_retailPrice"::float AS retail_price,
        COUNT(*) OVER (PARTITION BY title) AS total_bids,
        MAX(inserted_at) OVER (PARTITION BY title) AS last_bid
    FROM deduped
)
SELECT *
FROM cleaned_auctions;