---
queries:
  - sold_unsold.sql
---


# All auctions (unique titles)

All unique auction titles in the database. You can search for an auction by name. Click on the auction title to go to the details page.

<DataTable
    data="{sold_unsold}"
    search="true"
    rows=20
>
    <Column id="auction_id" title="Title" contentType="link" linkLabel="title" openInNewTab="true"/>
    <Column id="total"/>
    <Column id="sold"/>
    <Column id="unsold"/>
    <Column id="retail_price"/>
    <Column id="lowest_price"/>
    <Column id="median_price"/>
    <Column id="highest_price"/>
    <Column id="first_seen"/>
    <Column id="last_seen"/>
    <Column id="url" contentType="link" linkLabel="url" openInNewTab="true"/>
</DataTable>
