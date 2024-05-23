select
    title,

    first('https://vakantieveilingen.nl/' || url) as url,
    count(*) as total,
    min(inserted_at) as min_date,
    max(inserted_at) as max_date,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    '/auctions/' || md5(title) as auction_id,
from staging_auctions
group by 1