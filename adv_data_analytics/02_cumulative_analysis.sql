/*
Cumulative Analysis - to aggregate the data progressively over time. 
                      to understand whether our business is growing or declining over time.
   Aggregate - data that has been combined and summarized from multiple 
               sources or individual records to create a high-level overview or statistical report.

Formula : [Cumulative Measure] BY [Date Dimension]			
Function: We use Average Window Function
*/
-- Calculate the total sales per month
SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales, -- adding each rows value to the sum of all the previous rows value
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM 
(
SELECT 
DATETRUNC(MONTH, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
)t
ORDER BY DATETRUNC(MONTH, order_date)
-- ad the running totals of sales over time
