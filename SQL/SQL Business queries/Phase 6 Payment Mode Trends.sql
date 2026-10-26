-- C:04 Payment Mode Trends
--1. KPI: Payment Mode Split (Value Contribution)
SELECT 
    payment_type,
    SUM(total_amount) AS total_value,
    COUNT(*) AS txn_count
FROM vw_sales_clean s
JOIN vw_payment_clean p
    ON s.invoice_id = p.invoice_id
WHERE is_return = false
GROUP BY payment_type
ORDER BY total_value DESC;

/*

"Cash"	259582443.24	66119
"Card"	161917533.04	39425
"Bank Transfer"	17788519.99	2221
"Non-Cash Adjustment"	2443470.00	681
"Cheque"	9270.00	2
*/
----------------------------------------------------

--2. KPI: Payment Mode Trend Over Time
SELECT 
    DATE_TRUNC('month', invoice_date) AS month,
    payment_type,
    ROUND(CAST(SUM(total_amount)AS NUMERIC),2) AS total_value
FROM vw_sales_clean s
JOIN vw_payment_clean p
    ON s.invoice_id = p.invoice_id
WHERE is_return = false
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
/*
"month"	"payment_type"	"total_value"
"2025-01-01 00:00:00+04"	"Cash"	12042508.00
"2025-01-01 00:00:00+04"	"Card"	7095288.00
"2025-01-01 00:00:00+04"	"Bank Transfer"	392826.17
"2025-01-01 00:00:00+04"	"Non-Cash Adjustment"	301895.00
"2025-01-01 00:00:00+04"	"Cheque"	9270.00
"2025-02-01 00:00:00+04"	"Cash"	19243638.16
"2025-02-01 00:00:00+04"	"Card"	11631734.32
"2025-02-01 00:00:00+04"	"Non-Cash Adjustment"	282925.00
"2025-02-01 00:00:00+04"	"Bank Transfer"	252763.92
"2025-03-01 00:00:00+04"	"Cash"	21271960.93
"2025-03-01 00:00:00+04"	"Card"	13493478.46
"2025-03-01 00:00:00+04"	"Bank Transfer"	339284.07
"2025-03-01 00:00:00+04"	"Non-Cash Adjustment"	297185.00
"2025-04-01 00:00:00+04"	"Cash"	22163026.47
"2025-04-01 00:00:00+04"	"Card"	13232443.77
"2025-04-01 00:00:00+04"	"Bank Transfer"	782679.34
"2025-04-01 00:00:00+04"	"Non-Cash Adjustment"	289085.00
"2025-05-01 00:00:00+04"	"Cash"	24835458.95
"2025-05-01 00:00:00+04"	"Card"	14710489.00
"2025-05-01 00:00:00+04"	"Bank Transfer"	572416.75
"2025-05-01 00:00:00+04"	"Non-Cash Adjustment"	241770.00
"2025-06-01 00:00:00+04"	"Cash"	15958263.71
"2025-06-01 00:00:00+04"	"Card"	9403299.98
"2025-06-01 00:00:00+04"	"Bank Transfer"	393453.03
"2025-06-01 00:00:00+04"	"Non-Cash Adjustment"	190800.00
"2025-07-01 00:00:00+04"	"Cash"	14171678.50
"2025-07-01 00:00:00+04"	"Card"	9225045.19
"2025-07-01 00:00:00+04"	"Bank Transfer"	392144.12
"2025-07-01 00:00:00+04"	"Non-Cash Adjustment"	234520.00
"2025-08-01 00:00:00+04"	"Cash"	15081799.86
"2025-08-01 00:00:00+04"	"Card"	8282431.13
"2025-08-01 00:00:00+04"	"Bank Transfer"	736360.61
"2025-08-01 00:00:00+04"	"Non-Cash Adjustment"	148730.00
"2025-09-01 00:00:00+04"	"Cash"	17437893.45
"2025-09-01 00:00:00+04"	"Card"	11409161.36
"2025-09-01 00:00:00+04"	"Bank Transfer"	1533187.36
"2025-09-01 00:00:00+04"	"Non-Cash Adjustment"	103220.00
"2025-10-01 00:00:00+04"	"Cash"	25669966.49
"2025-10-01 00:00:00+04"	"Card"	17849132.75
"2025-10-01 00:00:00+04"	"Bank Transfer"	2641449.65
"2025-10-01 00:00:00+04"	"Non-Cash Adjustment"	82920.00
"2025-11-01 00:00:00+04"	"Cash"	14405812.19
"2025-11-01 00:00:00+04"	"Card"	10536592.07
"2025-11-01 00:00:00+04"	"Bank Transfer"	280234.55
"2025-11-01 00:00:00+04"	"Non-Cash Adjustment"	71610.00
"2025-12-01 00:00:00+04"	"Cash"	17522052.10
"2025-12-01 00:00:00+04"	"Card"	12771984.00
"2025-12-01 00:00:00+04"	"Bank Transfer"	394207.19
"2025-12-01 00:00:00+04"	"Non-Cash Adjustment"	51250.00
"2026-01-01 00:00:00+04"	"Cash"	30491521.20
"2026-01-01 00:00:00+04"	"Card"	18688247.01
"2026-01-01 00:00:00+04"	"Bank Transfer"	5830760.25
"2026-01-01 00:00:00+04"	"Non-Cash Adjustment"	126060.00
"2026-02-01 00:00:00+04"	"Cash"	9286863.23
"2026-02-01 00:00:00+04"	"Card"	3588206.00
"2026-02-01 00:00:00+04"	"Bank Transfer"	3246752.98
"2026-02-01 00:00:00+04"	"Non-Cash Adjustment"	21500.00

*/
---------------------------------------------

--3. KPI: Payment Mode by Branch

SELECT 
    b.branch_name,
    pm.payment_type,

    ROUND(CAST(SUM(fsp.amount) AS NUMERIC),2) AS total_value,

    ROUND(CAST(
        SUM(fsp.amount) * 100.0 /
        SUM(SUM(fsp.amount)) OVER (PARTITION BY b.branch_name)
    AS NUMERIC),2) AS pct_share

FROM fact_sales_payment fsp

JOIN vw_sales_clean fs 
    ON fsp.invoice_id = fs.invoice_id

JOIN dim_branch b 
    ON fs.branch_id = b.branch_id

JOIN dim_payment_mode pm 
    ON fsp.payment_mode_id = pm.payment_mode_id

WHERE fs.is_return = false

GROUP BY b.branch_name, pm.payment_type
ORDER BY b.branch_name, pct_share DESC;

/*
"Branch 01"	"CASH"	52210654.20	80.43
"Branch 01"	"CARD"	12535365.00	19.31
"Branch 01"	"TRANSFER"	169372.50	0.26
"Branch 02"	"CASH"	57315679.06	70.77
"Branch 02"	"CARD"	16471317.28	20.34
"Branch 02"	"TRANSFER"	7200528.00	8.89
"Branch 02"	"LOYALTY_POINT_REDEMPTION"	4100.00	0.01
"Branch 03"	"CASH"	29374695.00	76.68
"Branch 03"	"CARD"	7675967.55	20.04
"Branch 03"	"TRANSFER"	1257385.00	3.28
"Branch 04"	"CASH"	6733122.00	65.54
"Branch 04"	"CARD"	3539439.00	34.46
"Branch 05"	"CARD"	31749823.99	54.00
"Branch 05"	"CASH"	25819312.00	43.91
"Branch 05"	"TRANSFER"	1166905.00	1.98
"Branch 05"	"LOYALTY_POINT_REDEMPTION"	59850.00	0.10
"Branch 06"	"CASH"	3378265.00	58.00
"Branch 06"	"CARD"	2340269.00	40.18
"Branch 06"	"TRANSFER"	89770.00	1.54
"Branch 06"	"CHEQUE"	16140.00	0.28
"Branch 07"	"CARD"	31216508.00	53.94
"Branch 07"	"CASH"	26592893.00	45.95
"Branch 07"	"TRANSFER"	59770.00	0.10
"Branch 07"	"LOYALTY_POINT_REDEMPTION"	500.00	0.00
"Branch 08"	"CASH"	32530431.00	45.49
"Branch 08"	"TRANSFER"	23053540.00	32.24
"Branch 08"	"CARD"	15918766.50	22.26
"Branch 08"	"LOYALTY_POINT_REDEMPTION"	3200.00	0.00
"Branch 09"	"CASH"	31269402.50	66.60
"Branch 09"	"CARD"	15003499.50	31.96
"Branch 09"	"TRANSFER"	678017.00	1.44
"Branch 10"	"CASH"	28228180.00	80.47
"Branch 10"	"CARD"	6346625.00	18.09
"Branch 10"	"TRANSFER"	502575.00	1.43
"Branch 12"	"CASH"	25736559.00	49.99
"Branch 12"	"CARD"	23397334.00	45.44
"Branch 12"	"TRANSFER"	2350801.00	4.57
"Branch 12"	"LOYALTY_POINT_REDEMPTION"	500.00	0.00
"Branch 13"	"CASH"	32574986.00	68.62
"Branch 13"	"CARD"	14895229.00	31.38
"Branch 15"	"CASH"	3390806.00	51.89
"Branch 15"	"CARD"	3130519.00	47.91
"Branch 15"	"LOYALTY_POINT_REDEMPTION"	12800.00	0.20
"Branch 16"	"CASH"	51151903.00	69.83
"Branch 16"	"CARD"	19887147.00	27.15
"Branch 16"	"TRANSFER"	2187365.00	2.99
"Branch 16"	"LOYALTY_POINT_REDEMPTION"	23220.00	0.03
"Branch 17"	"CASH"	949410.00	61.76
"Branch 17"	"CARD"	586667.00	38.16
"Branch 17"	"TRANSFER"	1110.00	0.07
"Branch 18"	"TRANSFER"	45805003.80	58.89
"Branch 18"	"CASH"	31827654.94	40.92
"Branch 18"	"CARD"	150650.00	0.19
"Branch 19"	"CASH"	34294131.00	76.03
"Branch 19"	"CARD"	9775330.15	21.67
"Branch 19"	"TRANSFER"	1035735.00	2.30
"Branch 20"	"CASH"	475200.00	90.83
"Branch 20"	"TRANSFER"	48000.00	9.17
*/

--------------------------------------------

--04: 4. Transaction Size vs Payment Mode 
WITH payment_ranked AS (
    SELECT 
        invoice_id,
        payment_type,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY invoice_id 
            ORDER BY amount DESC
        ) AS rn
    FROM public.vw_payment_clean
),

primary_payment AS (
    SELECT 
        invoice_id,
        payment_type
    FROM payment_ranked
    WHERE rn = 1
),

invoice_values AS (
    SELECT 
        invoice_id,
        SUM(total_amount) AS invoice_value
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY invoice_id
),

base AS (
    SELECT 
        pp.payment_type,
        iv.invoice_value
    FROM primary_payment pp
    JOIN invoice_values iv
        ON pp.invoice_id = iv.invoice_id
)

SELECT 
    CASE 
        WHEN invoice_value < 1000 THEN '<1K'
        WHEN invoice_value < 5000 THEN '1K-5K'
        WHEN invoice_value < 10000 THEN '5K-10K'
        ELSE '10K+'
    END AS txn_bucket,

    payment_type,

    COUNT(*) AS txn_count,

    ROUND(SUM(invoice_value)::NUMERIC, 2) AS total_value,

    ROUND(
        100.0 * COUNT(*) 
        / SUM(COUNT(*)) OVER (PARTITION BY 
            CASE 
                WHEN invoice_value < 1000 THEN '<1K'
                WHEN invoice_value < 5000 THEN '1K-5K'
                WHEN invoice_value < 10000 THEN '5K-10K'
                ELSE '10K+'
            END
        ),
        2
    ) AS pct_within_bucket

FROM base
GROUP BY 
    CASE 
        WHEN invoice_value < 1000 THEN '<1K'
        WHEN invoice_value < 5000 THEN '1K-5K'
        WHEN invoice_value < 10000 THEN '5K-10K'
        ELSE '10K+'
    END,
    payment_type
ORDER BY txn_bucket, total_value DESC;

SELECT 
    payment_type,
    ROUND(CAST(SUM(total_amount)AS NUMERIC),2) AS total_value,
    COUNT(*) AS txn_count
FROM vw_sales_clean s
JOIN vw_payment_clean p
    ON s.invoice_id = p.invoice_id
WHERE is_return = false
GROUP BY payment_type
ORDER BY total_value DESC;
/*
"payment_type"	"total_value"	"txn_count"
"Cash"	259582443.24	66119
"Card"	161917533.04	39425
"Bank Transfer"	17788519.99	2221
"Non-Cash Adjustment"	2443470.00	681
"Cheque"	9270.00	2
*/

--5 What percentage of transactions involve advance receipts or multiple payment modes?
WITH payment_counts AS (
    SELECT 
        invoice_id,
        COUNT(DISTINCT payment_type) AS payment_mode_count
    FROM vw_payment_clean
    GROUP BY invoice_id
),

base AS (
    SELECT 
        COUNT(*) AS total_invoices,
        
        COUNT(CASE 
            WHEN payment_mode_count > 1 THEN 1 
        END) AS multi_payment_invoices
    FROM payment_counts
)

SELECT 
    total_invoices,
    multi_payment_invoices,
    
    ROUND(
        100.0 * multi_payment_invoices / total_invoices,
        2
    ) AS pct_multi_payment_transactions
FROM base;

/*
"total_invoices"	"multi_payment_invoices"	"pct_multi_payment_transactions"
62151	10485	16.87
*/
--How does payment mode differ between regular sales and old gold buy-back settlements?
WITH old_gold_customers AS (
    SELECT DISTINCT customer_id
    FROM fact_old_gold_purchase
)

SELECT 
    CASE 
        WHEN og.customer_id IS NOT NULL THEN 'Old Gold Linked Sale'
        ELSE 'Regular Sale'
    END AS transaction_type,
    
    v.payment_type,
    
    ROUND(CAST(SUM(v.amount) AS NUMERIC), 2) AS total_value,
    
    ROUND(
        CAST(
            SUM(v.amount) * 100.0 
            / SUM(SUM(v.amount)) OVER (
                PARTITION BY 
                    CASE 
                        WHEN og.customer_id IS NOT NULL THEN 'Old Gold Linked Sale'
                        ELSE 'Regular Sale'
                    END
            )
        AS NUMERIC),
        2
    ) AS pct_share

FROM vw_payment_clean v

JOIN vw_sales_clean s 
    ON v.invoice_id = s.invoice_id

LEFT JOIN old_gold_customers og
    ON s.customer_id = og.customer_id

WHERE s.is_return = false

GROUP BY 
    transaction_type,
    v.payment_type

ORDER BY transaction_type, total_value DESC;

/*
"transaction_type"	"payment_type"	"total_value"	"pct_share"
"Old Gold Linked Sale"	"Cash"	77662594.13	52.92
"Old Gold Linked Sale"	"Card"	44468957.82	30.30
"Old Gold Linked Sale"	"Bank Transfer"	24576334.31	16.75
"Old Gold Linked Sale"	"Non-Cash Adjustment"	56450.00	0.04
"Regular Sale"	"Cash"	396190689.57	63.14
"Regular Sale"	"Card"	170151499.15	27.12
"Regular Sale"	"Bank Transfer"	61029542.99	9.73
"Regular Sale"	"Non-Cash Adjustment"	47720.00	0.01
"Regular Sale"	"Cheque"	16140.00	0.00
*/