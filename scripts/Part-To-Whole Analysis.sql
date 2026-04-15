-- Part-To-Whole Analysis
/* Analyze how individual parts is performing compared to the overall, 
allowing us to understand which category has the greatest impact on the business.*/ 
WITH part_to_whole AS (
SELECT 
p.category,
SUM(f.sales) as total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY p.category
)
SELECT 
category,
total_sales,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER() * 100,2),  '%') AS presentage_of_total
FROM part_to_whole
ORDER BY total_sales DESC