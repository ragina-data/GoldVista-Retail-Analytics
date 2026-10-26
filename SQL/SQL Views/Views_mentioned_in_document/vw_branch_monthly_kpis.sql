
--2. vw_branch_monthly_kpis
CREATE OR REPLACE VIEW vw_branch_monthly_kpis AS
SELECT 
    DATE_TRUNC('month', s.invoice_date) AS month,
    b.branch_name,

    COUNT(DISTINCT s.invoice_id) AS invoices,
    SUM(s.total_amount) AS revenue,
    SUM(s.gross_weight) AS weight,

    SUM(CASE 
            WHEN s.is_return = true THEN s.total_amount 
            ELSE 0 
        END) AS returns_value

FROM vw_sales_clean s
JOIN dim_branch b
    ON s.branch_id = b.branch_id

GROUP BY 
    DATE_TRUNC('month', s.invoice_date),
    b.branch_name;

