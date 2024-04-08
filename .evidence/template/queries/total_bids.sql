select
    max(inserted_at) as latest,
    min(cast(inserted_at as timestamp)) as day,
    count(distinct title) as distinct_auctions,
    count(inserted_at) as total,
    (select count(inserted_at) as total from staging_auctions where winning_bid > 0) as total_winners
from staging_auctions
