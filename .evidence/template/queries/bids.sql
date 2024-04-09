select
    title,
    winning_bid,
    inserted_at,
    day,
    'https://vakantieveilingen.nl' || url as url
from staging_auctions