-- Cumulative Analysis (Window Function)
/* measures the running total of values over time, 
showing how data builds up and grows rather than 
looking at individual points separately.*/
SELECT 
	order_date,
	total_sales,
	SUM(total_sales) OVER( ORDER BY order_date) as total_running_sales,
	AVG(avg_price) OVER( ORDER BY order_date) as moving_avg_price
FROM
(
SELECT 
DATETRUNC(MONTH,order_date) AS order_date,
SUM(sales) as total_sales,
AVG(price) as avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
)t