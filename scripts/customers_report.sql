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
		- average order value
		- average monthly spend
===============================================================================
*/
WITH base_query AS (
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(first_name, ' ', last_name) AS customer_name,
DATEDIFF(year, birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key 
WHERE order_date IS NOT NULL
)
, customers_aggregation AS (
SELECT 
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) as total_orders,
SUM(sales) as total_sales,
SUM(quantity) as total_quantitiy,
COUNT(DISTINCT product_key) total_products,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date),MAX(order_date)) lifespan
FROM base_query
GROUP BY 
customer_key,
customer_number,
customer_name,
age
) 
SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE 
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29' 
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and Above '
END age_range,
total_orders,
total_sales,
CASE 
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
END customer_range,
total_quantitiy,
total_products,
last_order,
lifespan,
DATEDIFF(month, last_order, GETDATE()) AS recency,
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
-- Compuate average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customers_aggregation

