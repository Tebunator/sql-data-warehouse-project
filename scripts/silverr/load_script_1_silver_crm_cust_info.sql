/*
Check for Nulls or Duplicates in Primary Key
Expectation: Ro Result
If there is no more than, we check the creation date of the customer and pick the latest one.

SELECT 
cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 

-- Cleaning Nulls or Duplicates
SELECT *
FROM 
(SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info 
WHERE cst_id IS NOT NULL)t WHERE flag_last = 1
*/

/*
Checking for unwanted spaces
Expectation: Ro Result

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
FROM 
(SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info 
WHERE cst_id IS NOT NULL)t WHERE flag_last = 1
*/

/*
 Data Standardization and Consistency
  -- to store meaningful values than abbreviation terms
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info

-- Cleaning for Data Standardization and Consistency
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	    CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			ELSE UPPER('n/a')
		END AS 	cst_marital_status,
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE UPPER('n/a')
		END AS cst_gndr,
	cst_create_date
FROM 
(SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info 
WHERE cst_id IS NOT NULL)t WHERE flag_last = 1
*/
PRINT '>> Truncating Table: silver.crm_cust_info'
	TRUNCATE TABLE silver.crm_cust_info
PRINT '>> Inserting Data Into: silver.crm_cust_info' 
INSERT INTO silver.crm_cust_info(
       cst_id
      ,cst_key
      ,cst_firstname
      ,cst_lastname
      ,cst_marital_status
      ,cst_gndr
      ,cst_create_date
)
SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,
	TRIM(cst_lastname) AS cst_lastname,
	    CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			ELSE UPPER('n/a')
		END AS 	cst_marital_status,
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE UPPER('n/a')
		END AS cst_gndr,
	cst_create_date
FROM 
(SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info 
WHERE cst_id IS NOT NULL)t WHERE flag_last = 1
--SELECT * FROM bronze.crm_cust_info

/*
------------------------------------------------------------------
Checking data has been cleansed and standardized for 'silver' layer
------------------------------------------------------------------

Check for Nulls or Duplicates in Primary Key
Expectation: Ro Result
If there is no more than, we check the creation date of the customer and pick the latest one.

SELECT 
cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 

Checking for unwanted spaces: part of data normalization & standardization
Expectation: Ro Result

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

Expectation: 18484 records/rows
SELECT * from silver.crm_cust_info
*/