
--3. vw_customer_purchase_summary

CREATE OR REPLACE VIEW vw_customer_purchase_summary AS
SELECT 
    customer_id,
    COUNT(DISTINCT invoice_id) AS total_invoices,
    SUM(total_amount) AS total_spent,
    AVG(total_amount) AS avg_ticket_size,
    MAX(invoice_date) AS last_purchase_date
FROM vw_sales_clean
WHERE is_return = false
GROUP BY customer_id order by total_spent desc;

