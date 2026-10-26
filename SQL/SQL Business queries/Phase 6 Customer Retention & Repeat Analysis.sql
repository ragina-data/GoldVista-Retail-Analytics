--Q1: One-time vs Repeat Customers

WITH customer_txn AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_id) AS purchase_count
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY customer_id
)

SELECT 
    CASE 
        WHEN purchase_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM customer_txn
GROUP BY customer_type;

/*
"customer_type"	"customers"	"percentage"
"One-time"	38116	84.02
"Repeat"	7247	15.98
*/
--------------------------------------------------------------------
--Q2: Avg Time Between 1st & 2nd Purchase

WITH ranked_txn AS (
    SELECT 
        customer_id,
        invoice_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY invoice_date) AS rn
    FROM vw_sales_clean
    WHERE is_return = false
),
first_second AS (
    SELECT 
        customer_id,
        MAX(CASE WHEN rn = 1 THEN invoice_date END) AS first_date,
        MAX(CASE WHEN rn = 2 THEN invoice_date END) AS second_date
    FROM ranked_txn
    GROUP BY customer_id
)

SELECT 
    ROUND(AVG(second_date - first_date), 2) AS avg_days_between
FROM first_second
WHERE second_date IS NOT NULL;

/*"avg_days_between"
8.76
*/
---------------------------------------------------------------------

--Q3: Repeat Rate by Branch

WITH customer_branch AS (
    SELECT 
        branch_id,
        customer_id,
        COUNT(DISTINCT invoice_id) AS purchase_count
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY branch_id, customer_id
)

SELECT 
    b.branch_name,
    ROUND(CAST(COUNT(CASE WHEN purchase_count >= 2 THEN 1 END) * 100.0 
        / COUNT(*) AS NUMERIC),2) AS repeat_rate
FROM customer_branch cb
JOIN dim_branch b ON cb.branch_id = b.branch_id
GROUP BY b.branch_name
ORDER BY repeat_rate DESC;

/*

"branch_name"	"repeat_rate"
"Branch 05"	36.09
"Branch 18"	22.07
"Branch 02"	18.61
"Branch 01"	17.13
"Branch 12"	16.19
"Branch 07"	15.53
"Branch 17"	14.53
"Branch 09"	13.81
"Branch 10"	13.16
"Branch 04"	11.44
"Branch 08"	8.32
"Branch 06"	7.96
"Branch 15"	7.86
"Branch 16"	2.66
"Branch 13"	0.95
"Branch 19"	0.51
"Branch 03"	0.09
"Branch 20"	0.00
*/

--Q4: Old Gold Customers → Do They Return More?

WITH old_gold_customers AS (
    SELECT DISTINCT customer_id
    FROM fact_old_gold_purchase
),
customer_txn AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_id) AS purchase_count
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY customer_id
)

SELECT 
    CASE 
        WHEN og.customer_id IS NOT NULL THEN 'Old Gold Customer'
        ELSE 'Normal Customer'
    END AS customer_type,
    ROUND(CAST(AVG(purchase_count)AS NUMERIC),2) AS avg_purchases
FROM customer_txn ct
LEFT JOIN old_gold_customers og 
    ON ct.customer_id = og.customer_id
GROUP BY customer_type;

/*
"customer_type"	"avg_purchases"
"Normal Customer"	1.21
"Old Gold Customer"	4.36
*/
------------------------------------------------

--Q5: Customer Lifetime Value (CLV)

WITH customer_spend AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_id) AS purchase_count,
        SUM(total_amount) AS total_spend
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY customer_id
)

SELECT 
    CASE 
        WHEN purchase_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    ROUND(CAST(AVG(total_spend)AS NUMERIC),2) AS avg_clv
FROM customer_spend
GROUP BY customer_type;

/*
"customer_type"	"avg_clv"
"One-time"	5216.92
"Repeat"	20615.68
*/
---------------------------------------------------------------
--Q6: Customer Segmentation

WITH customer_metrics AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT invoice_id) AS purchase_count,
        SUM(total_amount) AS total_spend
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY customer_id
)

SELECT 
    CASE 
        WHEN purchase_count = 1 THEN 'One-time'
        WHEN purchase_count BETWEEN 2 AND 3 THEN 'Occasional'
        WHEN purchase_count >= 4 AND total_spend < 50000 THEN 'Regular'
        ELSE 'High-Value'
    END AS segment,
    COUNT(*) AS customers
FROM customer_metrics
GROUP BY segment;

/*
"segment"	"customers"
"High-Value"	255
"Occasional"	6368
"One-time"	38116
"Regular"	624
*/
--------------------------------------------------------------
--Q7: Cohort Analysis (Retention by Month)

WITH first_purchase AS (
    SELECT 
        customer_id,
        MIN(DATE_TRUNC('month', invoice_date)) AS cohort_month
    FROM vw_sales_clean
    WHERE is_return = false
    GROUP BY customer_id
),
activity AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', invoice_date) AS activity_month
    FROM vw_sales_clean
    WHERE is_return = false
)

SELECT 
    f.cohort_month,
    a.activity_month,
    COUNT(DISTINCT a.customer_id) AS active_customers
FROM first_purchase f
JOIN activity a 
    ON f.customer_id = a.customer_id
GROUP BY f.cohort_month, a.activity_month
ORDER BY f.cohort_month, a.activity_month;

/*
"cohort_month"	"activity_month"	"active_customers"
"2025-01-01 00:00:00+04"	"2025-01-01 00:00:00+04"	2886
"2025-01-01 00:00:00+04"	"2025-02-01 00:00:00+04"	108
"2025-01-01 00:00:00+04"	"2025-03-01 00:00:00+04"	61
"2025-01-01 00:00:00+04"	"2025-04-01 00:00:00+04"	38
"2025-01-01 00:00:00+04"	"2025-05-01 00:00:00+04"	64
"2025-01-01 00:00:00+04"	"2025-06-01 00:00:00+04"	35
"2025-01-01 00:00:00+04"	"2025-07-01 00:00:00+04"	31
"2025-01-01 00:00:00+04"	"2025-08-01 00:00:00+04"	21
"2025-01-01 00:00:00+04"	"2025-09-01 00:00:00+04"	30
"2025-01-01 00:00:00+04"	"2025-10-01 00:00:00+04"	28
"2025-01-01 00:00:00+04"	"2025-11-01 00:00:00+04"	12
"2025-01-01 00:00:00+04"	"2025-12-01 00:00:00+04"	25
"2025-01-01 00:00:00+04"	"2026-01-01 00:00:00+04"	16
"2025-01-01 00:00:00+04"	"2026-02-01 00:00:00+04"	3
"2025-02-01 00:00:00+04"	"2025-02-01 00:00:00+04"	4111
"2025-02-01 00:00:00+04"	"2025-03-01 00:00:00+04"	81
"2025-02-01 00:00:00+04"	"2025-04-01 00:00:00+04"	36
"2025-02-01 00:00:00+04"	"2025-05-01 00:00:00+04"	69
"2025-02-01 00:00:00+04"	"2025-06-01 00:00:00+04"	47
"2025-02-01 00:00:00+04"	"2025-07-01 00:00:00+04"	35
"2025-02-01 00:00:00+04"	"2025-08-01 00:00:00+04"	36
"2025-02-01 00:00:00+04"	"2025-09-01 00:00:00+04"	42
"2025-02-01 00:00:00+04"	"2025-10-01 00:00:00+04"	50
"2025-02-01 00:00:00+04"	"2025-11-01 00:00:00+04"	29
"2025-02-01 00:00:00+04"	"2025-12-01 00:00:00+04"	21
"2025-02-01 00:00:00+04"	"2026-01-01 00:00:00+04"	36
"2025-02-01 00:00:00+04"	"2026-02-01 00:00:00+04"	13
"2025-03-01 00:00:00+04"	"2025-03-01 00:00:00+04"	4574
"2025-03-01 00:00:00+04"	"2025-04-01 00:00:00+04"	51
"2025-03-01 00:00:00+04"	"2025-05-01 00:00:00+04"	75
"2025-03-01 00:00:00+04"	"2025-06-01 00:00:00+04"	52
"2025-03-01 00:00:00+04"	"2025-07-01 00:00:00+04"	46
"2025-03-01 00:00:00+04"	"2025-08-01 00:00:00+04"	51
"2025-03-01 00:00:00+04"	"2025-09-01 00:00:00+04"	35
"2025-03-01 00:00:00+04"	"2025-10-01 00:00:00+04"	44
"2025-03-01 00:00:00+04"	"2025-11-01 00:00:00+04"	27
"2025-03-01 00:00:00+04"	"2025-12-01 00:00:00+04"	26
"2025-03-01 00:00:00+04"	"2026-01-01 00:00:00+04"	41
"2025-03-01 00:00:00+04"	"2026-02-01 00:00:00+04"	10
"2025-04-01 00:00:00+04"	"2025-04-01 00:00:00+04"	3741
"2025-04-01 00:00:00+04"	"2025-05-01 00:00:00+04"	78
"2025-04-01 00:00:00+04"	"2025-06-01 00:00:00+04"	38
"2025-04-01 00:00:00+04"	"2025-07-01 00:00:00+04"	32
"2025-04-01 00:00:00+04"	"2025-08-01 00:00:00+04"	44
"2025-04-01 00:00:00+04"	"2025-09-01 00:00:00+04"	31
"2025-04-01 00:00:00+04"	"2025-10-01 00:00:00+04"	37
"2025-04-01 00:00:00+04"	"2025-11-01 00:00:00+04"	23
"2025-04-01 00:00:00+04"	"2025-12-01 00:00:00+04"	26
"2025-04-01 00:00:00+04"	"2026-01-01 00:00:00+04"	34
"2025-04-01 00:00:00+04"	"2026-02-01 00:00:00+04"	13
"2025-05-01 00:00:00+04"	"2025-05-01 00:00:00+04"	3971
"2025-05-01 00:00:00+04"	"2025-06-01 00:00:00+04"	67
"2025-05-01 00:00:00+04"	"2025-07-01 00:00:00+04"	43
"2025-05-01 00:00:00+04"	"2025-08-01 00:00:00+04"	40
"2025-05-01 00:00:00+04"	"2025-09-01 00:00:00+04"	37
"2025-05-01 00:00:00+04"	"2025-10-01 00:00:00+04"	45
"2025-05-01 00:00:00+04"	"2025-11-01 00:00:00+04"	27
"2025-05-01 00:00:00+04"	"2025-12-01 00:00:00+04"	30
"2025-05-01 00:00:00+04"	"2026-01-01 00:00:00+04"	32
"2025-05-01 00:00:00+04"	"2026-02-01 00:00:00+04"	7
"2025-06-01 00:00:00+04"	"2025-06-01 00:00:00+04"	2844
"2025-06-01 00:00:00+04"	"2025-07-01 00:00:00+04"	63
"2025-06-01 00:00:00+04"	"2025-08-01 00:00:00+04"	29
"2025-06-01 00:00:00+04"	"2025-09-01 00:00:00+04"	28
"2025-06-01 00:00:00+04"	"2025-10-01 00:00:00+04"	24
"2025-06-01 00:00:00+04"	"2025-11-01 00:00:00+04"	20
"2025-06-01 00:00:00+04"	"2025-12-01 00:00:00+04"	20
"2025-06-01 00:00:00+04"	"2026-01-01 00:00:00+04"	19
"2025-06-01 00:00:00+04"	"2026-02-01 00:00:00+04"	3
"2025-07-01 00:00:00+04"	"2025-07-01 00:00:00+04"	2508
"2025-07-01 00:00:00+04"	"2025-08-01 00:00:00+04"	67
"2025-07-01 00:00:00+04"	"2025-09-01 00:00:00+04"	38
"2025-07-01 00:00:00+04"	"2025-10-01 00:00:00+04"	32
"2025-07-01 00:00:00+04"	"2025-11-01 00:00:00+04"	17
"2025-07-01 00:00:00+04"	"2025-12-01 00:00:00+04"	16
"2025-07-01 00:00:00+04"	"2026-01-01 00:00:00+04"	20
"2025-07-01 00:00:00+04"	"2026-02-01 00:00:00+04"	4
"2025-08-01 00:00:00+04"	"2025-08-01 00:00:00+04"	2752
"2025-08-01 00:00:00+04"	"2025-09-01 00:00:00+04"	57
"2025-08-01 00:00:00+04"	"2025-10-01 00:00:00+04"	34
"2025-08-01 00:00:00+04"	"2025-11-01 00:00:00+04"	23
"2025-08-01 00:00:00+04"	"2025-12-01 00:00:00+04"	17
"2025-08-01 00:00:00+04"	"2026-01-01 00:00:00+04"	21
"2025-08-01 00:00:00+04"	"2026-02-01 00:00:00+04"	10
"2025-09-01 00:00:00+04"	"2025-09-01 00:00:00+04"	3076
"2025-09-01 00:00:00+04"	"2025-10-01 00:00:00+04"	83
"2025-09-01 00:00:00+04"	"2025-11-01 00:00:00+04"	29
"2025-09-01 00:00:00+04"	"2025-12-01 00:00:00+04"	40
"2025-09-01 00:00:00+04"	"2026-01-01 00:00:00+04"	36
"2025-09-01 00:00:00+04"	"2026-02-01 00:00:00+04"	11
"2025-10-01 00:00:00+04"	"2025-10-01 00:00:00+04"	3977
"2025-10-01 00:00:00+04"	"2025-11-01 00:00:00+04"	80
"2025-10-01 00:00:00+04"	"2025-12-01 00:00:00+04"	52
"2025-10-01 00:00:00+04"	"2026-01-01 00:00:00+04"	50
"2025-10-01 00:00:00+04"	"2026-02-01 00:00:00+04"	24
"2025-11-01 00:00:00+04"	"2025-11-01 00:00:00+04"	2863
"2025-11-01 00:00:00+04"	"2025-12-01 00:00:00+04"	74
"2025-11-01 00:00:00+04"	"2026-01-01 00:00:00+04"	39
"2025-11-01 00:00:00+04"	"2026-02-01 00:00:00+04"	13
"2025-12-01 00:00:00+04"	"2025-12-01 00:00:00+04"	3111
"2025-12-01 00:00:00+04"	"2026-01-01 00:00:00+04"	66
"2025-12-01 00:00:00+04"	"2026-02-01 00:00:00+04"	19
"2026-01-01 00:00:00+04"	"2026-01-01 00:00:00+04"	3719
"2026-01-01 00:00:00+04"	"2026-02-01 00:00:00+04"	49
"2026-02-01 00:00:00+04"	"2026-02-01 00:00:00+04"	1230*/