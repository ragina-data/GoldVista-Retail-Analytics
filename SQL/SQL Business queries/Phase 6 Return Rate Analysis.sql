	--Challenge C-03: Return Rate Analysis
	
	SELECT 
	    ROUND(CAST(COUNT(DISTINCT CASE WHEN is_return = true THEN invoice_id END) * 100.0 
	        / COUNT(DISTINCT invoice_id)AS NUMERIC),2) AS return_rate_count,
	
	    ROUND(CAST(SUM(CASE WHEN is_return = true THEN total_amount END) * 100.0
	        / SUM(total_amount) AS NUMERIC),2) AS return_rate_value
	FROM vw_sales_clean;
	/*
	1.71	1.22
	*/
	
	--2. KPI: Return Rate by Branch
	
	SELECT 
	    b.branch_name,
	
	    ROUND(CAST(COUNT(CASE WHEN fs.is_return = true THEN 1 END) * 100.0
	        / COUNT(*)AS NUMERIC),2) AS return_rate_count,
	
	    ROUND(CAST(SUM(CASE WHEN fs.is_return = true THEN fs.total_amount END) * 100.0
	        / SUM(fs.total_amount)AS NUMERIC),2) AS return_rate_value
	
	FROM vw_sales_clean fs
	JOIN dim_branch b ON fs.branch_id = b.branch_id
	
	GROUP BY b.branch_name
	ORDER BY return_rate_value DESC;
	
	/*
	"Branch 20"	0.00	
	"Branch 06"	3.50	4.35
	"Branch 18"	2.20	3.15
	"Branch 08"	2.18	2.34
	"Branch 09"	1.67	1.55
	"Branch 07"	1.82	1.49
	"Branch 15"	1.47	1.36
	"Branch 05"	1.55	1.21
	"Branch 12"	1.51	1.16
	"Branch 17"	1.35	1.09
	"Branch 16"	1.51	1.08
	"Branch 01"	1.48	1.04
	"Branch 03"	1.21	1.00
	"Branch 04"	1.17	0.78
	"Branch 19"	0.93	0.77
	"Branch 02"	1.05	0.75
	"Branch 10"	0.59	0.55
	"Branch 13"	0.83	0.48
	*/
	
	---------------------------------------
	--3. KPI: Return Pattern by Karat
	
	SELECT 
	    CASE 
	        WHEN purity >= 0.99 THEN '24K'
	        WHEN purity >= 0.90 THEN '22K'
	        WHEN purity >= 0.75 THEN '18K'
	        ELSE 'Other'
	    END AS karat,
	
	    ROUND(CAST(COUNT(CASE WHEN fs.is_return = true THEN 1 END) * 100.0
	        / COUNT(*)AS NUMERIC),2) AS return_rate
	
	FROM vw_sales_clean fs
	GROUP BY karat
	ORDER BY return_rate DESC;
	
	/*
	"22K"	1.58
	"18K"	1.57
	"Other"	1.49
	"24K"	0.76
	*/
	
	--4. KPI: Return Pattern by Item Type
	
	SELECT 
	    CASE 
	        WHEN LOWER(i.item_description) LIKE '%ring%' THEN 'Rings'
	        WHEN LOWER(i.item_description) LIKE '%chain%' THEN 'Chains'
	        WHEN LOWER(i.item_description) LIKE '%coin%' THEN 'Coins'
	        ELSE 'Others'
	    END AS item_group,
	
	    ROUND(CAST(COUNT(CASE WHEN fs.is_return = true THEN 1 END) * 100.0
	        / COUNT(*)AS NUMERIC),2) AS return_rate
	
	FROM vw_sales_clean fs
	JOIN vw_dim_item_clean i ON fs.item_id = i.item_id
	
	GROUP BY item_group
	ORDER BY return_rate DESC;
	
	/*
	"Rings"	1.72
	"Chains"	1.42
	"Others"	1.33
	"Coins"	0.20
	*/
	--5. KPI: Avg Time Between Purchase & Return
	
	WITH txn AS (
	    SELECT 
	        customer_id,
	        invoice_id,
	        invoice_date,
	        is_return,
	        LAG(invoice_date) OVER (
	            PARTITION BY customer_id 
	            ORDER BY invoice_date
	        ) AS prev_date
	    FROM vw_sales_clean
	)
	
	SELECT 
	    ROUND(AVG(invoice_date - prev_date),2) AS avg_days_to_return
	FROM txn
	WHERE is_return = true;
	
	/*
	"avg_days_to_return"
	5.68
	*/
	
	--
	
	--6. KPI: Discount vs Return Correlation
	SELECT 
	    CASE 
	        WHEN discount < 5 THEN 'Low Discount'
	        WHEN discount BETWEEN 5 AND 15 THEN 'Medium Discount'
	        ELSE 'High Discount'
	    END AS discount_band,
	
	    COUNT(CASE WHEN is_return = true THEN 1 END) * 100.0
	        / COUNT(*) AS return_rate
	
	FROM vw_sales_clean
	GROUP BY discount_band
	ORDER BY return_rate DESC;
	
	/*
	"discount_band"	"return_rate"
	"Low Discount"	1.4564443807907986
	"High Discount"	0.00000000000000000000
	"Medium Discount"	0.00000000000000000000
	*/
	
	-------------------------------------------
	
	--7. KPI: Financial Impact of Returns
	SELECT 
	    ROUND(CAST(SUM(total_amount)AS NUMERIC),2) AS total_return_value,
	    ROUND(CAST(SUM(gross_weight)AS NUMERIC),2) AS total_return_weight
	FROM vw_sales_clean
	WHERE is_return = true;
	
	/*
	"total_return_value"	"total_return_weight"
	4309542.62	52711.77
	*/
	
	---------------------------------------------------------------------------
	--