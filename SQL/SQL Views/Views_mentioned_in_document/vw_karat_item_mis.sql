
--8. vw_karat_item_mix


CREATE OR REPLACE VIEW vw_karat_item_mix AS
SELECT 
    CASE 
        WHEN purity >= 0.99 THEN '24K'
        WHEN purity >= 0.90 THEN '22K'
        WHEN purity >= 0.70 THEN '18K'
        ELSE 'Other'
    END AS gold_type,

    COUNT(*) AS transactions,
    ROUND(CAST(SUM(total_amount)AS NUMERIC),2) AS revenue

FROM vw_sales_clean
WHERE is_return = false
  AND purity > 0
GROUP BY 1;

