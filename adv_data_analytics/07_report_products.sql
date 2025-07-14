/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key products metrics and behaviors

Highlights:
    1. Gathers essential fields such as proudct name, category, subcategory and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Perfomers.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order revenue: Average Order Value = Total Sales / Total Nr of Orders
		- average monthly spend: Average Month Spending = Total Sales / Nr of Months
===============================================================================
*/
IF OBJECT_ID('gold.report_products','V') IS NOT NULL
	DROP VIEW gold.report_products;
	GO 
CREATE VIEW gold.report_products AS
WITH base_query AS (
/*
-------------------------------------------------------------------------
1) Base Query: Retrieve core columns from tables
-------------------------------------------------------------------------
*/
SELECT
s.order_number,
s.order_date,
s.customer_key,
s.sales_amount,
s.quantity,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
), 
product_aggregate AS (
SELECT
/*
-------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
-------------------------------------------------------------------------
*/
product_key,
product_name,
category,
subcategory,
cost,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
MAX(order_date) AS last_order,
COUNT(DISTINCT order_number) AS total_orders,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY
product_key,
product_name,
category,
subcategory,
cost
)
SELECT
product_key,
product_name,
category,
subcategory,
cost,
last_order,
DATEDIFF(MONTH, last_order, GETDATE()) AS recency_in_months,
CASE 
	WHEN total_sales > 50000 THEN 'High_Performer'
	WHEN total_sales >= 10000 THEN 'Mid_Range'
	ELSE 'Low-Performer'
END AS product_segment,
lifespan,
total_orders,
total_sales,
total_quantity,
total_customers,
avg_selling_price,
-- Average Order Revenue (AOR)
CASE
	WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders
END AS avg_order_revenue,
-- Average Monthly Revenue
CASE 
	WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END AS avg_monthly_revenue
FROM product_aggregate