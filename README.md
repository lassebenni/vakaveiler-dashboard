# Vakaveiler dashboard

Powered by [Evidence](https://evidence.dev).

Steps:

1. A webscraper running in Google Cloud Run Jobs is scraping auctions and writing the results to a SQLITE database in Google Cloud Storage.
2. We need to download the sqlite database and convert it into a duckdb database file for efficient analytical quering. This also does some data cleaning and filtering using duckdb. See the `makefile` step `download-db`. For this we need to install the duckdb binary.
3. Then in order to create the dashboard in Evidence, we need to install `node` and then install evidence's dependencies by running `npm install`.
4. Now that Node and the project dependencies are installed, we run `npm run build` which will in turn run `evidence build`, connecting to the duckdb database file in the project dir (downloaded in the step before), run the sql queries defined in our evidence markdown pages, and cache the results and create an output directory called `build`.
5. We can host this directory as a website using Netlify and use the `nwtgck/actions-netlify@v2.0` github marketplace action to deploy it from the Github action. 

> Note: Deploying the website in <b>Google Cloud Runner</b> is not possible due to the hard-limit of 32MB per response size. When fetching data from the cache, the `json` responses for the auctions can be bigger than that, causing the navigation to break.
