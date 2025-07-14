/*
Change Over Time - Analyst how a measure evolves over time.
Helps track trends.

Formula : [Measure] BY [Date Dimension]
Function: We use a Sum Window Function
*/

-- Sales Performance Over Time

SELECT
YEAR(order_date) AS order_year,
MONTH(order_date) order_month,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date), YEAR(order_date) 
ORDER BY MONTH(order_date), YEAR(order_date)


   -- We can user DATETRUNC
SELECT
DATETRUNC(YEAR, order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date) 
ORDER BY DATETRUNC(YEAR, order_date)

  -- We User Format based - here the sorting is well since the date is in String
  SELECT
FORMAT(order_date, 'yyyy-MMM') AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM') 
ORDER BY FORMAT(order_date, 'yyyy-MMM') 
