-- Calculate the key metric of the business(Big NUmbers)
-- Highest Level of Aggregation | Lowest Level of Details

-- Generate a Report that shows all key metrics of the business
	SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measuere_value FROM gold.fact_sales
	UNION ALL
	SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measuere_value FROM gold.fact_sales
	UNION ALL
	SELECT 'Average Price' AS measure_name, AVG(price) AS measuere_value FROM gold.fact_sales
	UNION ALL
	SELECT 'Total No. Orders' AS measure_name, COUNT(DISTINCT order_number) AS measuere_value FROM gold.fact_sales
	UNION ALL
	SELECT 'Total No. Products' AS measure_name, COUNT(product_name) AS measuere_value FROM gold.dim_products
	UNION ALL
	SELECT 'Total No. Customers' AS measure_name, COUNT(customer_key) AS measuere_value FROM gold.dim_customers