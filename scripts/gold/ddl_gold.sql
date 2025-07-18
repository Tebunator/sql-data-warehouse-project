/*
==========================================================
DDL Script: Create Gold Views
==========================================================
Script Purpose:
    This script create views for Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

	Each view performs transformations and combines data from the Silver layer
	to produce a clean, enriched and business-ready dataset.

Usage
  - These views can be queried directly for analystics and reporting.
  ==========================================================
 */

   -- ======================================================
   -- Create Dimension: gold.dim_customers
   -- ======================================================
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

	GO

   -- ======================================================
   -- Create Dimension: gold.dim_products
   -- ======================================================
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

	GO
   -- ======================================================
   -- Create Fact: gold.fact_sales
   -- ======================================================
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
