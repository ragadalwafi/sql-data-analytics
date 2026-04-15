-- Data Segmenttation (Case When Function)
/* Grouping the data based on a specific range.
helps understand the correlation between two measures.*/

-- Cost Range Segmentation
WITH cost_range_segment AS (
SELECT 
product_key,
product_name,
cost,
CASE 
	WHEN cost < 100 THEN 'Below 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'Above 1000'
END cost_range
FROM gold.dim_products
) 
SELECT 
cost_range,
COUNT(product_key) as total_products
FROM cost_range_segment
GROUP BY cost_range
ORDER BY total_products DESC;

-- Customers Segmentation
WITH customers_segment AS (
SELECT 
	c.customer_key,
	SUM(f.sales) total_spend,
	MIN(order_date) first_order,
	MAX(order_date) last_order,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
) 
SELECT
customer_range,
COUNT(customer_key) as total_customers
FROM(
SELECT 
customer_key,
CASE 
		WHEN lifespan >= 12 AND total_spend > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spend <= 5000 THEN 'Regular'
		ELSE 'New'
END customer_range
FROM customers_segment)t
GROUP BY customer_range
ORDER BY total_customers DESC