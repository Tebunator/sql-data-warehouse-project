/*
  - If End Date is NUll then it is Current information of the product
  - Filtered By End Date for current information 
*/
   IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
         DROP VIEW gold.dim_products;
		 Go
	CREATE VIEW  gold.dim_products AS
	SELECT 
	ROW_NUMBER() OVER (ORDER BY prd_start_dt, prd_key) AS product_key,
		pd.prd_id AS product_id,
		pd.prd_key AS product_number,
		pd.prd_nm AS product_name,
		pd.cat_id AS category_id,
		pc.cat AS category,
		pc.subcat AS subcategory,
		pc.maintenance,
		pd.prd_cost AS cost,
		pd.prd_line AS product_line,
		pd.prd_start_dt AS start_date	
	FROM silver.crm_prd_info pd
	LEFT JOIN silver.erp_px_cat_g1v2 pc
	ON pd.cat_id = pc.id
	WHERE prd_end_dt IS NULL

/*
Quality check for duplicate products
Expectation: No Results

SELECT prd_key, COUNT(*) 
 FROM 
	(SELECT 
		pd.prd_id,
		pd.cat_id,
		pd.prd_key,
		pd.prd_nm,
		pd.prd_cost,
		pd.prd_line,
		pd.prd_start_dt,
		pc.cat,
		pc.subcat,
		pc.maintenance
	FROM silver.crm_prd_info pd
	LEFT JOIN silver.erp_px_cat_g1v2 pc
	ON pd.cat_id = pc.id
	WHERE prd_end_dt IS NULL)t GROUP BY prd_key 
	HAVING COUNT(*) > 1

	Check the View
	SELECT * FROM gold.dim_products
*/
