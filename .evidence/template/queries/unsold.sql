select
    title,
    date_trunc('day', inserted_at) as day,

    count(*) as unsold
from staging_auctions
where has_winner = false
group by 1, 2