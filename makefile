# Targets
.PHONY: download-db

download-db:
	rm auctions.duckdb || true
	# gsutil cp gs://lasse-benninga-sndbx-y-vakantieveilingen/veilingen.sqlite analysis/veilingen.sqlite
	duckdb auctions.duckdb -c '.read analysis/duckdb_query.sql'
