select
    title,
    date_trunc('day', inserted_at) as day,

    count(*) as unsold
from staging_auctions
where highest_price = 0
group by 1, 2