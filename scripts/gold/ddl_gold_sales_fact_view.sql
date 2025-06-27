/*
- This is Fact Table: It has more Foreign keys (to connect to multiple dimensions) to faciliate transactions 
  and as to when they happen and the measures of them as to how much each sale cost.

  We used dimension's surrogate keys instead of IDs to easily connects Facts with Dimensions
*/
 IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
         DROP VIEW gold.fact_sales;
		 Go
CREATE VIEW gold.fact_sales AS
SELECT  sd.sls_ord_num AS order_number
      , pd.product_key 
      , ci.customer_key
      , sd.sls_order_dt AS order_date
      , sd.sls_ship_dt AS shipping_date
      , sd.sls_due_dt AS due_date
      , sd.sls_sales AS sales_amount
      , sd.sls_quantity AS quantity
      , sd.sls_price AS price
  FROM silver.crm_sales_details sd
  LEFT JOIN gold.dim_products pd
  ON sd.sls_prd_key = pd.product_number
  LEFT JOIN gold.dim_customers ci
  ON sd.sls_cust_id = ci.customer_id

/*
Check quality 
SELECT * FROM gold.fact_sales

Foreign Key Integrity (Dimensions)
Expectation: No Results.
SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE p.product_key IS NULL 
-- WHERE c.customer_key = f.customer_key
*/
