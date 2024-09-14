with unsold_titles as (
select
    title,

    count(*) as unsold
from staging_auctions
where has_winner = 'False'
group by 1
order by unsold desc
)

select
    title,

    count(*) as sold,
    first(unsold) as unsold,
    first(unsold) + count(*) as total,
    first(retail_price) as retail_price,
    min(winning_bid) as lowest_price,
    max(winning_bid) as highest_price,
    median(winning_bid) as median_price,
    min(day) as first_seen,
    max(day) as last_seen,
    max('/auctions/' || md5(title)) as auction_id,
    max('https://vakantieveilingen.nl' || url) as url
from staging_auctions
left join unsold_titles using (title)
where has_winner = 'True'
group by 1
order by unsold desc
