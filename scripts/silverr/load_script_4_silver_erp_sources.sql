/*
Matching manipulating cid field to be the same as one from crm.cust_info to make a link
.....WHEN cid LIKE'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))

Identify Out-of-Range Dates
....
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE() 

Data Standardization & Consistency
SELECT DISTINCT
gen
FROM bronze.erp_cust_az12
*/
PRINT '>> Truncating Table: silver.erp_cust_az12'
	TRUNCATE TABLE silver.erp_cust_az12
PRINT '>> Inserting Data Into: silver.erp_cust_az12'
INSERT INTO silver.erp_cust_az12(cid, bdate, gen)
SELECT
CASE WHEN cid LIKE'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END AS cid,
CASE WHEN  bdate > GETDATE() THEN NULL
     ELSE  bdate
END AS bdate, -- Set future birthdates to Null,
CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
	 ELSE ('n/a')  
END AS gen -- Normalize gender values and handle unknown cases
FROM bronze.erp_cust_az12

/*
------------------------------------------------------------------
Checking data has been cleansed and standardized for 'silver' layer
------------------------------------------------------------------

Identify Out-of-Range Dates
--We left very old customers
SELECT cid, bdate, gen
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE() 

Data Standardization & Consistency
SELECT DISTINCT
gen
FROM silver.erp_cust_az12
SELECT * FROM silver.erp_cust_az12
*/


/*
Manipulating cid field to match with crm.cust_info by removing '-'
....
SELECT
REPLACE(cid,'-','') AS cid,
FROM bronze.erp_loc_a101 

Data Standardization & Consistency
SELECT DISTINCT cntry
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101 
*/
PRINT '>> Truncating Table: silver.erp_loc_a101'
	TRUNCATE TABLE silver.erp_loc_a101
PRINT '>> Inserting Data Into: silver.erp_loc_a101'
INSERT INTO silver.erp_loc_a101(
cid,
cntry
)
SELECT 
REPLACE(cid,'-','') AS cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
	 WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_loc_a101 

/*
------------------------------------------------------------------
Checking data has been cleansed and standardized for 'silver' layer
------------------------------------------------------------------
Expectation: No results
SELECT
cid,
cntry
FROM silver.erp_loc_a101 WHERE cid NOT IN (SELECT cst_key, FROM silver.crm_cust_info)

Data Standardization & Consistency
Expectation: standardized and consistent data
SELECT DISTINCT cntry
FROM silver.erp_loc_a101 
*/

/*
There was nothing to clean....
Check for unwanted Spaces
SELECT id,
cat
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance) 

Data Standardization & Consistency
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2
*/
PRINT '>> Truncating Table: silver.erp_px_cat_g1v2'
	TRUNCATE TABLE silver.erp_px_cat_g1v2
PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2'
INSERT INTO silver.erp_px_cat_g1v2(
id,
cat,
subcat,
maintenance
)
SELECT  
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2

/*
Checking data has been cleansed and standardized for 'silver' layer
------------------------------------------------------------------
SELECT id,
cat
FROM silver.erp_px_cat_g1v2

Data Standardization & Consistency
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2
SELECT * FROM silver.erp_px_cat_g1v2
*/



