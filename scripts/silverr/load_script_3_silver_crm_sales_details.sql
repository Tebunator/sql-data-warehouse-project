/*
Checking for invalid order dates
Expectation: No Result
--- negative dates

SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt < 0

--- zero value as a Date
 Resolution replace with Null Using NULLIF Function
SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0

Out of boundry date
---Expectation: date's length should be 8. No less or no more than that
SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) != 8 OR sls_order_dt > 20500101 OR sls_order_dt < 19000101

Converting a date from INT to DATE. First CAST as VARCHAR then CAST as DATE
SELECT sls_order_dt
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			 END AS sls_order_dt 
FROM bronze.crm_sales_detatils

Order Date must always be earlier than Shipping Date or Due Date
SELECT sls_order_dt
FROM bronze.crm_sales_detatils
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt  > sls_due_dt

Sales = Quantity * Price
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <=0
	ORDER BY sls_sales, sls_quantity, sls_price
All Sales, Quantities or Price must not be nagetive. If there are results to be incorrect
Rules:
     IF SALES is negative, zero or null, derive it us Quantity and Price: Quantity * Price
	 IF Price is zero or null, calculate it using Sales and Quantity: Sales / Quantity 
	 IF Price is negative, convert it to positive value
     CASE WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / NULLIF(sls_quantity, 0)
	         ELSE sls_price
         END AS sls_price,
                sls_quantity,
    	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                THEN sls_quantity * ABS(sls_price)
			 ELSE sls_sales
	    END AS sls_sales
*/
PRINT '>> Truncating Table: silver.crm_sales_details'
	TRUNCATE TABLE silver.crm_sales_details
PRINT '>> Inserting Data Into: silver.crm_sales_details' 
INSERT INTO silver.crm_sales_details( 
        sls_ord_num 
      , sls_prd_key 
      , sls_cust_id 
      , sls_order_dt 
      , sls_ship_dt 
      , sls_due_dt 
      , sls_sales 
      , sls_quantity 
      , sls_price 
)
SELECT sls_ord_num,
       sls_prd_key
      , sls_cust_id 
      , CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
	         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			 END AS sls_order_dt 
      , CASE WHEN sls_ship_dt  = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
	         ELSE CAST(CAST(sls_ship_dt  AS VARCHAR) AS DATE)
			 END AS sls_ship_dt 
      , CASE WHEN sls_due_dt  = 0 OR LEN(sls_due_dt) != 8 THEN NULL
	         ELSE CAST(CAST(sls_due_dt  AS VARCHAR) AS DATE)
			 END AS sls_due_dt ,
	    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
                THEN sls_quantity * ABS(sls_price)
			 ELSE sls_sales
	    END AS sls_sales,
		 sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / NULLIF(sls_quantity, 0)
	         ELSE sls_price
         END AS sls_price    
FROM  bronze.crm_sales_details
/*
------------------------------------------------------------------
Checking data has been cleansed and standardized for 'silver' layer
------------------------------------------------------------------

Checking data quality for Sales, Quantity & Price.
All Sales, Quantities or Price must not be nagetive.
Expectation: No Results.
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <=0
	ORDER BY sls_sales, sls_quantity, sls_price
	
Order Date must always be earlier than Shipping Date or Due Date
SELECT sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt  > sls_due_dt
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <=0
	ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details
*/


