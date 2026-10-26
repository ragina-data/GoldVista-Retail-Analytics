--7. vw_salesperson_performance


CREATE OR REPLACE VIEW vw_salesperson_performance AS
SELECT 
    salesperson_id,
    category_name,
    COUNT(DISTINCT invoice_id) AS invoices,
    ROUND(CAST(SUM(total_amount)AS NUMERIC),2) AS revenue,
    ROUND(CAST(AVG(total_amount)AS NUMERIC),2) AS avg_sale_value
FROM vw_sales_clean
WHERE is_return = false
  AND category_name IN ('New Gold', 'Old Gold','Diamond Jewellery','NEW SILVER')
GROUP BY salesperson_id, category_name;

