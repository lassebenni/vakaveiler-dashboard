select * 
from auctions
WHERE inserted_at < strftime('%Y-%m-%d', 'now', '-1 month')
