# Stock Control
A back-end-for-front-end web service for knowing how much stuff you've got.

# Stories
1. Stock level
* To know the stock level of an item search using the UPC-E of the item like this: `GET` `…/stock/level/123456`
   1. receive a document containing the current level of that item against a 200 response code
   1. unless the item is unknown, in which case receive an empty document against a 404 response code