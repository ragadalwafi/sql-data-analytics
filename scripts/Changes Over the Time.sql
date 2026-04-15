-- Changes Over Years
SELECT 
YEAR(order_date) AS years,
SUM(sales) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_sold --total items sold
FROM gold.fact_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY total_sales DESC

-- Changes Over Months 
SELECT 
DATETRUNC(MONTH,order_date) AS order_date,
SUM(sales) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_sold --total items sold
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY order_date