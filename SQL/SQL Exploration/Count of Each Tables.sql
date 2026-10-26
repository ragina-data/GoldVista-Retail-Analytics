SELECT 'dim_branch' AS table_name, COUNT(*) FROM "dim_branch"
UNION ALL
SELECT 'dim_category', COUNT(*) FROM "dim_category"
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM "dim_customer"
UNION ALL
SELECT 'dim_date', COUNT(*) FROM "dim_date"
UNION ALL
SELECT 'dim_division', COUNT(*) FROM "dim_division"
UNION ALL
SELECT 'dim_item', COUNT(*) FROM "dim_item"
UNION ALL
SELECT 'dim_item_type', COUNT(*) FROM "dim_item_type"
UNION ALL
SELECT 'dim_karat', COUNT(*) FROM "dim_karat"
UNION ALL
SELECT 'dim_payment_mode', COUNT(*) FROM "dim_payment_mode"
UNION ALL
SELECT 'dim_salesperson', COUNT(*) FROM "dim_salesperson"
UNION ALL
SELECT 'dim_sub_category', COUNT(*) FROM "dim_sub_category"
UNION ALL
SELECT 'fact_branch_daily_summary', COUNT(*) FROM "fact_branch_daily_summary"
UNION ALL
SELECT 'fact_group_daily_summary', COUNT(*) FROM "fact_group_daily_summary"
UNION ALL
SELECT 'fact_old_gold_payment', COUNT(*) FROM "fact_old_gold_payment"
UNION ALL
SELECT 'fact_old_gold_purchase', COUNT(*) FROM "fact_old_gold_purchase"
UNION ALL
SELECT 'fact_return_payment', COUNT(*) FROM "fact_return_payment"
UNION ALL
SELECT 'fact_returns', COUNT(*) FROM "fact_returns"
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM "fact_sales"
UNION ALL
SELECT 'fact_sales_payment', COUNT(*) FROM "fact_sales_payment";