/*
We generated Surrogate Key - a system generated unique identifier using Window Function
CRM is the master for Customer Information
Checking duplicates by using Sub Query afer Joining Customer Tables
Expectation: No Result

SELECT cst_id, COUNT(*) FROM
	(SELECT 
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		lo.cntry
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 lo
	ON ci.cst_key = lo.cid)t GROUP BY cst_id
	HAVING COUNT(*) > 1

	Our Joining had issues with Gender not being consistent.
	SELECT DISTINCT
		ci.cst_gndr,
		ca.gen,
		CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			 ELSE COALESCE(ca.gen, 'n/a')
		END AS new_gen
		...ORDER BY 1, 2
*/
 IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
         DROP VIEW gold.dim_customers;
		 Go
CREATE VIEW gold.dim_customers AS
	SELECT 
	    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_numer,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		lo.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			 ELSE COALESCE(ca.gen, 'n/a')
		END AS gender,
		ca.bdate AS birth_date,
		ci.cst_create_date
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 lo
	ON ci.cst_key = lo.cid

/*
Quality Checks for gender.....
Expectation: 3 distict values
SELECT DISTINCT gender
FROM gold.dim_customers

SELECT DISTINCT gender
FROM gold.dim_customers
*/