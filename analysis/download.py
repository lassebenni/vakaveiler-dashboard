import os
import pandas as pd
import sqlite3
from datetime import datetime, timedelta
import gcsfs

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '.creds/vakantieveilingen.json'

# Define GCS file system
fs = gcsfs.GCSFileSystem(project="lasse-benninga-sndbx-y", toke="cloud")

# Download the SQLite file from GCS
with fs.open("gs://lasse-benninga-sndbx-y-vakantieveilingen/veilingen.sqlite", "rb") as fsrc:
    with open("veilingen.sqlite", "wb") as fdst:
        fdst.write(fsrc.read())

# Connect to the SQLite database
conn = sqlite3.connect("veilingen.sqlite")

# Calculate the date one month ago
one_month_ago = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")

# Query the past month of data
df = pd.read_sql_query(
    f"SELECT * FROM auctions WHERE inserted_at >= '{one_month_ago}'", conn
)

# Don't forget to close the connection
conn.close()
