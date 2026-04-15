-- Performance Analysis (Window Function)
-- Comparing the current value to a target value. 
-- helps measure success and compare performance.
WITH yearly_product_sales AS (
SELECT 
	YEAR(f.order_date) AS order_year,
	p.product_name,
	SUM(f.sales) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON P.product_key = F.product_key
WHERE f.order_date IS NOT NULL
GROUP BY YEAR(f.order_date),
p.product_name
) 
SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) diff_avg,
CASE 
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Average'
	WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Average'
	ELSE 'Average'
END avg_flag,
-- Year-Over-Year Analysis
-- Long-Term Analysis
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) diff_py,
CASE 
	WHEN current_sales- LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	WHEN current_sales- LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'decrease'
	ELSE 'No Change'
END py_flag
FROM yearly_product_sales 
ORDER BY product_name, order_year