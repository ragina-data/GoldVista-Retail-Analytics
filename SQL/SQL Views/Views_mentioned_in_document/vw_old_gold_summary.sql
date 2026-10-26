--6. vw_old_gold_summary

CREATE OR REPLACE VIEW vw_old_gold_summary AS
SELECT 
    DATE_TRUNC('month', purchase_date) AS month,
    COUNT(*) AS transactions,
    SUM(metal_amount) AS total_value,
    SUM(pure_weight) AS pure_gold_weight
FROM fact_old_gold_purchase
GROUP BY 1;

