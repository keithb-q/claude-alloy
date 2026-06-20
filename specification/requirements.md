# Stock Control
A back-end-for-front-end web service for knowing how much stuff you've got.

# Stories
1. Stock level
* To know the stock level of an item search using the UPC-E of the item like this: `GET` `…/stock/level/123456`
   1. receive a document containing the current level of that item against a 200 response code
   2. unless the item is unknown, in which case receive an empty document against a 404 response code 
   3.  `GET`s to a `stock/level` URI should see the current stock level as the sum of all activity on that UPC-E, with initial value 0

* To increase stock, `POST` a purchase against the UPC-E like this: `…/stock/purchase/123456` with a key-value in the request body saying the number received
* To decrease stock, `POST` a sale against the UPC-E like this: `…/stock/sale/123456` with a key-value in the request body saying the number received
 