/*
Ranking Analysis - ordering the values of dimensions by measure 
 to understand the Top performers and Bottom performers - [Dimension] BY [Measure]
*/

-- Which 5 products generate the highest revenue
	/*SELECT TOP 5
	pd.product_name,
	SUM(sl.sales_amount) AS highest_revenue
	FROM gold.fact_sales sl
	LEFT JOIN gold.dim_products pd
	ON pd.product_key = sl.product_key
	GROUP BY pd.product_name
	ORDER BY highest_revenue DESC
	*/
    -- OR Use Window Function: RANK()
	SELECT 
	* 
	FROM (
	SELECT 
	pd.product_name,
	SUM(sl.sales_amount) AS highest_revenue,
	RANK() OVER(ORDER BY SUM(sl.sales_amount) DESC ) AS ranking_products
	FROM gold.fact_sales sl
	LEFT JOIN gold.dim_products pd
	ON pd.product_key = sl.product_key
	GROUP BY pd.product_name)t
	WHERE ranking_products <= 5

-- What are the 5 worst performing products in terms of sales
	/*SELECT TOP 5
	pd.product_name,
	SUM(sl.sales_amount) AS highest_revenue
	FROM gold.fact_sales sl
	LEFT JOIN gold.dim_products pd
	ON pd.product_key = sl.product_key
	GROUP BY pd.product_name
	ORDER BY highest_revenue 
	*/
	 -- OR Use Window Function: RANK()
	SELECT 
	* 
	FROM (
	SELECT 
	pd.product_name,
	SUM(sl.sales_amount) AS highest_revenue,
	RANK() OVER(ORDER BY SUM(sl.sales_amount) ) AS ranking_products
	FROM gold.fact_sales sl
	LEFT JOIN gold.dim_products pd
	ON pd.product_key = sl.product_key
	GROUP BY pd.product_name)t
	WHERE ranking_products <= 5

-- Find the top 10 customers who have generated the highest revenue
  
	SELECT TOP 10
	cu.first_name,
	cu.last_name,
	SUM(sl.sales_amount) AS highest_revenue
	FROM gold.fact_sales sl
	LEFT JOIN gold.dim_customers cu
	ON cu.customer_key = sl.customer_key
	GROUP BY cu.first_name,
	cu.last_name
	ORDER BY highest_revenue

-- The 3 customes with the fewest orders placed
   SELECT TOP 3
   cu.customer_key,
   cu.first_name,
   cu.last_name,
   COUNT(DISTINCT order_number) AS total_orders
   FROM gold.fact_sales sl
   LEFT JOIN gold.dim_customers cu
   ON cu.customer_key = sl.customer_key
   GROUP BY
   cu.customer_key,
   cu.first_name,
   cu.last_name
   ORDER BY total_orders
	
	
