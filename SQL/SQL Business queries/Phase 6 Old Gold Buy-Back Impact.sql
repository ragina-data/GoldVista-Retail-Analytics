-- Old Gold Buy-Back Impact

--Monthly Buy-back Volume (Weight & Value)
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(gross_weight) AS total_weight,
    SUM(total_amount) AS total_value
FROM vw_sales_clean
WHERE is_return = 'true'
GROUP BY 1
ORDER BY 1;

/*
"2025-01-01 00:00:00+04"	610.1099999999999	227245
"2025-02-01 00:00:00+04"	949.5600000000002	355950
"2025-03-01 00:00:00+04"	770.1200000000002	302175.82999999996
"2025-04-01 00:00:00+04"	794.5499999999998	332865
"2025-05-01 00:00:00+04"	876.3599999999999	368815
"2025-06-01 00:00:00+04"	671.43	285176.79000000004
"2025-07-01 00:00:00+04"	503.86000000000007	225250
"2025-08-01 00:00:00+04"	572.5500000000001	237768.32
"2025-09-01 00:00:00+04"	447.31999999999994	214552
"2025-10-01 00:00:00+04"	5658.7300000000005	381568.46
"2025-11-01 00:00:00+04"	2485.13	278795
"2025-12-01 00:00:00+04"	1514.2900000000002	297720
"2026-01-01 00:00:00+04"	35102.73	681089.99
"2026-02-01 00:00:00+04"	1755.0299999999997	120571.23
*/

--2. % of Sales Linked to Buy-Back
WITH og_customers AS (
    SELECT DISTINCT customer_id
    FROM fact_old_gold_purchase
),

sales AS (
    SELECT DISTINCT invoice_id, customer_id
    FROM vw_sales_clean
    WHERE is_return = false
)

SELECT 
    ROUND(
        COUNT(CASE WHEN og.customer_id IS NOT NULL THEN 1 END) * 100.0 
        / COUNT(*), 2
    ) AS pct_linked_sales

FROM sales s
LEFT JOIN og_customers og
    ON s.customer_id = og.customer_id;
/*
"pct_linked_sales"
14.28	
*/

--KPI 3: Branch Buy-Back Activity
SELECT 
    b.branch_name,
    ROUND(CAST(SUM(og.total_amount)AS NUMERIC),2) AS buyback_value,
    ROUND(CAST(SUM(og.gross_weight)AS NUMERIC),2) AS buyback_weight

FROM fact_old_gold_purchase og
JOIN dim_branch b 
    ON og.branch_id = b.branch_id

GROUP BY b.branch_name
ORDER BY buyback_value DESC;

/*
"branch_name"	"buyback_value"	"buyback_weight"
"Branch 02"	7006699.00	21264.81
"Branch 05"	6819845.06	42795.33
"Branch 07"	3221652.89	10362.11
"Branch 01"	3008394.00	7676.62
"Branch 12"	2429815.81	6326.53
"Branch 10"	2392870.00	6692.95
"Branch 16"	2173825.03	11473.84
"Branch 03"	2066106.00	5414.68
"Branch 09"	1946215.09	6020.52
"Branch 08"	1899770.00	6990.18
"Branch 19"	1309133.00	3285.59
"Branch 13"	1066405.00	2795.04
"Branch 04"	919710.00	3042.61
"Branch 15"	544195.20	1833.21
"Branch 18"	440613.00	6100.30
"Branch 06"	427930.00	1404.87
"Branch 17"	82980.00	274.20
*/
--4: Avg Invoice Value (Buy-back vs Normal)

WITH og_customers AS (
    SELECT DISTINCT customer_id
    FROM fact_old_gold_purchase
),

txn AS (
    SELECT 
        invoice_id,
        customer_id,
        SUM(total_amount) AS invoice_value
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY invoice_id, customer_id
)

SELECT 
    CASE 
        WHEN og.customer_id IS NOT NULL THEN 'Buy-Back Customer'
        ELSE 'Normal Customer'
    END AS customer_type,
    
    ROUND(CAST(AVG(invoice_value)AS NUMERIC),2) AS avg_invoice_value

FROM txn t
LEFT JOIN og_customers og
    ON t.customer_id = og.customer_id

GROUP BY customer_type;

/*
"customer_type"	"avg_invoice_value"
"Buy-Back Customer"	6236.69
"Normal Customer"	5581.96
*/

--Rate Spread (Buy-back vs Market)

SELECT 
    ROUND(CAST(AVG(metal_rate)AS NUMERIC),2) AS avg_buyback_rate,
    ROUND(CAST(AVG(market_rate)AS NUMERIC),2) AS avg_market_rate,
    ROUND(CAST(AVG(market_rate - metal_rate)AS NUMERIC),2) AS avg_spread

FROM fact_old_gold_purchase;

/*
"avg_buyback_rate"	"avg_market_rate"	"avg_spread"
372.70	388.33	15.62*/

--6: Purity Distribution

SELECT 
    CASE 
        WHEN purity >= 0.99 THEN '24K'
        WHEN purity >= 0.90 THEN '22K'
        WHEN purity >= 0.75 THEN '18K'
        ELSE 'Other'
    END AS karat,
    
    ROUND(CAST(SUM(gross_weight)AS NUMERIC),2) AS weight

FROM fact_old_gold_purchase
GROUP BY karat
ORDER BY weight DESC;

/*
"karat"	"weight"
"24K"	65279.24
"22K"	44268.04
"18K"	34206.11
*/
