--Branch check

SELECT COUNT(*) 
FROM fact_sales f
LEFT JOIN dim_branch d 
ON f.branch_id = d.branch_id
WHERE d.branch_id IS NULL;

--Customer check

SELECT COUNT(*) 
FROM fact_sales f
LEFT JOIN dim_customer d 
ON f.customer_id = d.customer_id
WHERE d.customer_id IS NULL;

--Salesperson check
SELECT COUNT(*) 
FROM fact_sales f
LEFT JOIN dim_salesperson d 
ON f.salesperson_id = d.salesperson_id
WHERE d.salesperson_id IS NULL;


--Item check

SELECT COUNT(*) 
FROM fact_sales f
LEFT JOIN dim_item d 
ON f.item_id = d.item_id
WHERE d.item_id IS NULL;

--Date check ⚠️ (important)

SELECT COUNT(*) 
FROM fact_sales f
LEFT JOIN dim_date d 
ON f.invoice_date = d.date_key
WHERE d.date_key IS NULL;

--B. fact_sales_payment → fact_sales

SELECT COUNT(*) 
FROM fact_sales_payment p
LEFT JOIN fact_sales s 
ON p.invoice_id = s.invoice_id
WHERE s.invoice_id IS NULL;

--fact_returns → fact_sales

SELECT COUNT(*) 
FROM fact_returns r
LEFT JOIN fact_sales s 
ON r.original_invoice_id = s.invoice_id
WHERE s.invoice_id IS NULL;

--fact_return_payment → fact_returns

SELECT COUNT(*) 
FROM fact_return_payment rp
LEFT JOIN fact_returns r 
ON rp.return_id = r.return_id
WHERE r.return_id IS NULL;

--Old gold tables

SELECT COUNT(*) 
FROM fact_old_gold_purchase p
LEFT JOIN dim_branch b 
ON p.branch_id = b.branch_id
WHERE b.branch_id IS NULL;

--Summary tables

SELECT COUNT(*) 
FROM fact_branch_daily_summary s
LEFT JOIN dim_branch b 
ON s.branch_id = b.branch_id
WHERE b.branch_id IS NULL;

--DUPLICATE CHECK

SELECT invoice_id, COUNT(*)
FROM fact_sales
GROUP BY invoice_id
HAVING COUNT(*) > 1;

--Check referential integrity ratio

SELECT 
    COUNT(*) AS total_rows,
    COUNT(d.branch_id) AS matched_rows,
    COUNT(*) - COUNT(d.branch_id) AS unmatched_rows
FROM fact_sales f
LEFT JOIN dim_branch d 
ON f.branch_id = d.branch_id;