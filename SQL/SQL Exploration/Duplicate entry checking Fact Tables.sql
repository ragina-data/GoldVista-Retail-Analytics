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
HAVING COUNT(*) > 1 ORDER BY invoice_id asc;


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


--fact_sales_payment (Per payment)
WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
invoice_id, payment_mode_id, amount, weight, is_advance
) dup_count
FROM fact_sales_payment)
SELECT * FROM d WHERE dup_count > 1;


--fact_returns (Per returned item)           
--return_id + item_id

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
return_id, return_date, branch_id, customer_id,
salesperson_id, original_invoice_id,
item_id, item_code, pieces, gross_weight,
net_weight, pure_weight, purity, metal_rate,
making_rate, metal_amount, making_amount,
discount, gross_amount, total_amount
) dup_count
FROM fact_returns)
SELECT * FROM d WHERE dup_count > 1;


--fact_return_payment

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
return_id, payment_mode_id, amount
) dup_count
FROM fact_return_payment)
SELECT * FROM d WHERE dup_count > 1;

--fact_old_gold_purchase

SELECT 
    purchase_id,
    item_code,
    COUNT(*)
FROM fact_old_gold_purchase
GROUP BY purchase_id, item_code
HAVING COUNT(*) > 1;

--with all tables
WITH duplicates AS (
    SELECT *,
        COUNT(*) OVER (
            PARTITION BY 
                purchase_id,
                purchase_date,
                branch_id,
                customer_id,
                salesperson_id,
                item_code,
                pieces,
                gross_weight,
                net_weight,
                pure_weight,
                purity,
                metal_rate,
                market_rate,
                metal_amount,
                stone_amount,
                total_amount
        ) AS dup_count
    FROM fact_old_gold_purchase
)
SELECT *
FROM duplicates
WHERE dup_count > 1;

--fact_group_daily_summary

WITH duplicates AS (
    SELECT *,
        COUNT(*) OVER (
            PARTITION BY 
                branch_id,
                group_id,
                group_name,
                group_type,
                summary_date,
                is_return,
                gold_weight,
                gold_amount,
                silver_weight,
                silver_amount,
                diamond_pieces,
                diamond_amount
        ) AS dup_count
    FROM fact_group_daily_summary
)
SELECT *
FROM duplicates
WHERE dup_count > 1;


--fact_branch_daily_summary
WITH duplicates AS (
    SELECT *,
        COUNT(*) OVER (
            PARTITION BY 
                branch_id,
                summary_date,
                gold_weight,
                gold_amount,
                silver_weight,
                silver_amount,
                diamond_pieces,
                diamond_amount,
                watch_pieces,
                watch_amount,
                profit_making,
                profit_metal,
                profit_others,
                total_amount,
                is_return
        ) AS dup_count
    FROM fact_branch_daily_summary
)
SELECT *
FROM duplicates
WHERE dup_count > 1;


--fact_old_gold_payment

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
purchase_id, payment_mode_id, amount
) dup_count
FROM fact_old_gold_payment)
SELECT * FROM d WHERE dup_count > 1;
