/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value: Average Order Value = Total Sales / Total Nr of Orders
		- average monthly spend: Average Month Spending = Total Sales / Nr of Months
===============================================================================
*/
IF OBJECT_ID('gold.report_customers','V') IS NOT NULL
	DROP VIEW gold.report_customers;
	GO
CREATE VIEW gold.report_customers AS
WITH base_query AS (
-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
SELECT
/*
-------------------------------------------------------------------------
1) Base Query: Retrieve core columns from tables
-------------------------------------------------------------------------
*/
s.order_number,
s.product_key,
s.sales_amount,
s.quantity,
s.order_date,
c.customer_key,
c.customer_numer,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
DATEDIFF(YEAR, c.birth_date, GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
WHERE s.order_date IS NOT NULL

), customer_aggregatoin AS (
/*
-------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
-------------------------------------------------------------------------
*/
SELECT 
customer_key,
customer_numer,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key,
customer_numer,
customer_name,
age
)
SELECT
customer_key,
customer_numer,
customer_name,
age,
CASE 
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 Above'
END AS age_group,
CASE 
    WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segment,
DATEDIFF(MONTH, last_order, GETDATE()) AS recent_order,
total_orders,
total_sales,
total_quantity,
total_products,
first_order,
last_order,
lifespan,
-- Compute Average Order Value (AVO)
CASE 
	WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders 
END AS average_value_order,
-- Compute Average Monthly Spend 
CASE 
	WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM 
customer_aggregatoin