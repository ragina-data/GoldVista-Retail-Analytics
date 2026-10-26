
--vw_return_analysis

CREATE OR REPLACE VIEW vw_returns_analysis AS
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    COUNT(*) AS return_count,
    SUM(total_amount) AS return_value
FROM vw_sales_clean
WHERE is_return = true
GROUP BY 1;

