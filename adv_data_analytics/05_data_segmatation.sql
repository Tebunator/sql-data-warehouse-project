/*
Data Segmentation - is the process of dividing a dataset in distinct groups
                    base on certain criteria such demographic,region or time
					[Measure]  By [Measure]
					  Total Products By Sales Range
					  Total Customers by Age
*/

-- Segment products into cost ranges and count how many products fall into each segment
WITH product_segments AS (
SELECT
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
     WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END AS cost_range
FROM gold.dim_products
)
SELECT
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/*
Group customers into three segments based on their spending behavior:
    - VIP: Customers with atleast 12 month history and spending more than R5000.
	- Regular: Customers with atleast 12 months of history but spending R5000 or less.
	- New: Customers with a lifespan less than 12 months.
	- Find the total number of customers by each group
*/
WITH customer_seg AS (
SELECT 
s.customer_key,
c.first_name,
SUM(sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY s.customer_key, c.first_name
)

SELECT
COUNT(customer_key) AS total_customers,
customer_segment
FROM 
(
SELECT
customer_key,
CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP: Customer'
     WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regualar: Customer'
	 ELSE 'New Customer'
END AS customer_segment
FROM customer_seg)t
GROUP BY customer_segment
ORDER BY total_customers DESC

