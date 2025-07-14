/*
Part To Whole - Analyze how an individual part is performing compared to overall.
				This helps to understand which category has the most impact on the business.

	([Measure]/Total[Measure]) * 1oo By [Dimension]
	           (Sales/Total Sales) * 100 By Category
			   (quantity/Total Quantity) * 100 By Category
*/
-- Which category contribute the most to overall sales
WITH category_sales AS (
SELECT 
p.category,
SUM(s.sales_amount ) AS total_sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.category
)
SELECT
category,
total_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) /SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
