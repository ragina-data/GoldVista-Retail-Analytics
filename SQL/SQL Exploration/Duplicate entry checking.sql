--fact_sales (Per item sold)
--Expected grain:
--invoice_id + item_id + item_code

SELECT 
    invoice_id,
    item_id,
    item_code,
    COUNT(*) AS duplicate_count
FROM fact_sales
GROUP BY invoice_id, item_id, item_code
HAVING COUNT(*) > 1;


--check full duplicates
WITH duplicates AS (
    SELECT *,
        COUNT(*) OVER (
            PARTITION BY 
                invoice_id, invoice_date, branch_id, customer_id,
                salesperson_id, item_id, item_code, pieces,
                gross_weight, net_weight, pure_weight,
                metal_amount, making_amount, total_amount
        ) AS dup_count
    FROM fact_sales
)
SELECT *
FROM duplicates
WHERE dup_count > 1;