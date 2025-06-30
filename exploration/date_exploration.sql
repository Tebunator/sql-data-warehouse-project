-- Identifying the earliest and latest dates (boundaries)
-- Understand the scope of data and the timespan
-- Used DATEDIFF function to determine the number of sales

-- Find the date of the first and last order
	SELECT 
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
	FROM gold.fact_sales

-- Find the youngest and the oldest customer
SELECT 
MIN(birth_date) AS olderst_customer,
DATEDIFF(year, MIN(birth_date), GETDATE()) AS oldest_age,
MAX(birth_date) AS youngest_customer,
DATEDIFF(year, MAX(birth_Date), GETDATE()) AS youngest_age
FROM gold.dim_customers
