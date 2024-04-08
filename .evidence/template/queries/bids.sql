select
    max(inserted_at) as latest,
    min(date_trunc('day', strptime(inserted_at, '%Y-%m-%d %H:%M:%S.%f'))) as day,
    count(distinct title) as distinct_auctions,
    count(inserted_at) as total,
    (select count(inserted_at) as total from bids where winning_bid > 0) as total_winners
from auctions.bids