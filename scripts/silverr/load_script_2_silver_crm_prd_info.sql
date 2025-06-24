/*
Check for Nulls or Duplicates in Primary Key
Expectation: Ro Result
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

Checking unwanted spaces ub prd_nm
Expectation: No results
SELECT prd_nm FROM bronze.crm_prd_info
WHERE  prd_nm != TRIM(prd_nm)

Check quality of numbers; null or negative numbers
Expectation: No Results
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

Data Standardization & Consistency
Expextation: No Results
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

Check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt
*/
PRINT '>> Truncating Table: silver.crm_prd_info'
	TRUNCATE TABLE silver.crm_prd_info
PRINT '>> Inserting Data Into: silver.crm_prd_info' 
INSERT INTO silver.crm_prd_info( 
      prd_id
      ,cat_id
      ,prd_key
      ,prd_nm
      ,prd_cost
      ,prd_line
      ,prd_start_dt
      ,prd_end_dt
)

SELECT prd_id,
	 REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,
	 SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key
      ,prd_nm
      ,ISNULL(prd_cost, 0) AS prd_cost
      ,
	  CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		   WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		   WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		   WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		   ELSE 'n/a'
	  END AS prd_line
      ,CAST(prd_start_dt AS DATE) prd_start_dt
      ,CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
  FROM bronze.crm_prd_info

  /*
------------------------------------------------------------------
Checking data has been cleansed and standardized for 'silver' layer
------------------------------------------------------------------

Check for Nulls or Duplicates in Primary Key
Expectation: Ro Result

SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

SELECT prd_nm FROM silver.crm_prd_info
WHERE  prd_nm != TRIM(prd_nm)


Check quality of numbers; null or negative numbers
Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

Data Standardization & Consistency
Expextation: No Results
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

Check for Invalid Date Orders
Expectition: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT * 
FROM silver.crm_prd_info
*/






