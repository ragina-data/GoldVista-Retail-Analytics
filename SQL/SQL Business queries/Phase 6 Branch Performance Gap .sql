--Phase 6 Business Challenges
--Branch Performance Overview

SELECT 
    branch_id,
    branch_name,
    COUNT(DISTINCT invoice_id) AS invoices,
    ROUND(CAST(SUM(total_amount)AS NUMERIC),2) AS revenue,
    ROUND(CAST(SUM(gross_weight)AS NUMERIC),2) AS total_weight,
    ROUND(CAST(SUM(total_amount) / COUNT(DISTINCT invoice_id) AS NUMERIC),2) AS avg_transaction_value,
    ROUND(CAST(SUM(making_amount)AS NUMERIC),2) AS making_revenue
FROM vw_sales_clean
WHERE is_return = false
GROUP BY branch_id, branch_name
ORDER BY revenue DESC;

/*
18	"Branch 16"	6335	36944660.00	183204.06	5831.83	1971036.71
4	"Branch 02"	4468	35572341.74	194898.84	7961.58	1706682.35
3	"Branch 01"	5336	33468190.70	153733.10	6272.15	2000890.75
9	"Branch 07"	5177	27925806.00	173565.51	5394.21	4103448.22
21	"Branch 19"	4536	27862049.55	141216.13	6142.43	1422717.47
10	"Branch 08"	7397	26616202.50	123839.86	3598.24	4340041.05
15	"Branch 13"	4815	26182964.00	92690.20	5437.79	1531984.28
7	"Branch 05"	4483	23762564.99	271331.80	5300.59	2559897.12
14	"Branch 12"	4249	23223388.00	123532.81	5465.61	3174999.47
11	"Branch 09"	3628	21519538.00	108643.07	5931.52	1387178.58
12	"Branch 10"	4188	20475305.00	97930.82	4889.04	2107545.09
5	"Branch 03"	3504	19727664.05	131872.90	5630.04	956319.57
20	"Branch 18"	979	14742862.20	735924.80	15059.10	1047672.99
6	"Branch 04"	900	4569123.00	14285.82	5076.80	460839.81
8	"Branch 06"	641	2527704.00	7820.99	3943.38	410888.96
17	"Branch 15"	509	2160165.00	6591.08	4243.94	360452.92
19	"Branch 17"	211	772757.00	2156.41	3662.36	74237.92
22	"Branch 20"	5	196800.00	14000.00	39360.00	13730.00
*/
------------------------------------------------------------------

--Volume vs Value Comparison

SELECT 
    branch_id,
    branch_name,
    SUM(total_amount) AS revenue,
    SUM(gross_weight) AS weight
FROM vw_sales_clean
WHERE is_return = false
GROUP BY branch_id, branch_name
ORDER BY weight DESC;

/*
20	"Branch 18"	14742862.200000007	735924.7999999986
7	"Branch 05"	23762564.990000002	271331.80400000006
4	"Branch 02"	35572341.74	194898.84100000182
18	"Branch 16"	36944660	183204.06000000113
9	"Branch 07"	27925806	173565.51000000103
3	"Branch 01"	33468190.7	153733.10000000053
21	"Branch 19"	27862049.55	141216.1300000015
5	"Branch 03"	19727664.05	131872.9000000004
10	"Branch 08"	26616202.5	123839.8580000013
14	"Branch 12"	23223388	123532.81200000008
11	"Branch 09"	21519538	108643.07000000004
12	"Branch 10"	20475305	97930.8200000006
15	"Branch 13"	26182964	92690.20000000022
6	"Branch 04"	4569123	14285.820000000029
22	"Branch 20"	196800	14000
8	"Branch 06"	2527704	7820.989999999997
17	"Branch 15"	2160165	6591.08
19	"Branch 17"	772757	2156.4100000000003
*/
--Karat Mix Ny Branch

SELECT 
    branch_name,
    CASE 
        WHEN purity >= 0.99 THEN '24K'
        WHEN purity >= 0.90 THEN '22K'
        WHEN purity >= 0.75 THEN '18K'
        ELSE 'Other'
    END AS karat,
    SUM(total_amount) AS revenue
FROM vw_sales_clean
WHERE is_return = false
GROUP BY branch_name, karat
ORDER BY branch_name;

/*
"Branch 01"	"18K"	1791177.7
"Branch 01"	"22K"	21195342
"Branch 01"	"24K"	10059240
"Branch 01"	"Other"	422431
"Branch 02"	"18K"	5040106
"Branch 02"	"22K"	16935015.6
"Branch 02"	"24K"	13277655.94
"Branch 02"	"Other"	319564.2
"Branch 03"	"18K"	697282.5
"Branch 03"	"22K"	12474319.3
"Branch 03"	"24K"	6187361.25
"Branch 03"	"Other"	368701
"Branch 04"	"18K"	305214.13
"Branch 04"	"22K"	3203467.870000001
"Branch 04"	"24K"	930727
"Branch 04"	"Other"	129714
"Branch 05"	"18K"	76095
"Branch 05"	"22K"	14339044.99
"Branch 05"	"24K"	8689825
"Branch 05"	"Other"	657600
"Branch 06"	"18K"	88940
"Branch 06"	"22K"	1990979
"Branch 06"	"24K"	357875
"Branch 06"	"Other"	89910
"Branch 07"	"18K"	31053
"Branch 07"	"22K"	16480008
"Branch 07"	"24K"	10033565
"Branch 07"	"Other"	1381180
"Branch 08"	"18K"	38759
"Branch 08"	"22K"	20156493
"Branch 08"	"24K"	5568700.5
"Branch 08"	"Other"	852250
"Branch 09"	"18K"	121405
"Branch 09"	"22K"	14120808
"Branch 09"	"24K"	7008137
"Branch 09"	"Other"	269188
"Branch 10"	"18K"	176440
"Branch 10"	"22K"	14567720
"Branch 10"	"24K"	5574985
"Branch 10"	"Other"	156160
"Branch 12"	"18K"	66792
"Branch 12"	"22K"	16263668
"Branch 12"	"24K"	6371565
"Branch 12"	"Other"	521363
"Branch 13"	"18K"	89450
"Branch 13"	"22K"	16364372
"Branch 13"	"24K"	9421028
"Branch 13"	"Other"	308114
"Branch 15"	"18K"	15270
"Branch 15"	"22K"	1706740
"Branch 15"	"24K"	374735
"Branch 15"	"Other"	63420
"Branch 16"	"18K"	143165
"Branch 16"	"22K"	23074010
"Branch 16"	"24K"	13470930
"Branch 16"	"Other"	256555
"Branch 17"	"18K"	41910
"Branch 17"	"22K"	559060
"Branch 17"	"24K"	141462
"Branch 17"	"Other"	30325
"Branch 18"	"18K"	33781.85
"Branch 18"	"22K"	194227.46
"Branch 18"	"24K"	14463811.139999995
"Branch 18"	"Other"	51041.75
"Branch 19"	"18K"	1010262
"Branch 19"	"22K"	15785039.05
"Branch 19"	"24K"	10781573.5
"Branch 19"	"Other"	285175
"Branch 20"	"24K"	196800
*/

--Growth Trend (Monthly)

SELECT 
    branch_name,
    DATE_TRUNC('month', invoice_date) AS month,
    SUM(total_amount) AS revenue
FROM vw_sales_clean
WHERE is_return = false
GROUP BY branch_name, month
ORDER BY branch_name, month;

--Item type Mix
create or replace view vw_item_type_mix
as
SELECT 
    branch_name,
    category_name,
    SUM(total_amount) AS revenue
FROM vw_sales_clean
WHERE is_return = false
GROUP BY branch_name, category_name
ORDER BY branch_name;

SELECT 
    b.branch_name,

    CASE 
        WHEN LOWER(i.item_description) LIKE '%ring%' THEN 'Rings'
        WHEN LOWER(i.item_description) LIKE '%chain%' THEN 'Chains'
        WHEN LOWER(i.item_description) LIKE '%coin%' THEN 'Coins'
        ELSE 'Others'
    END AS item_group,

    SUM(fs.total_amount) AS revenue,
    SUM(fs.gross_weight) AS weight,

    ROUND(cast(
        SUM(fs.total_amount) * 100.0 /
        SUM(SUM(fs.total_amount)) OVER (PARTITION BY b.branch_name)as numeric),
        2
    ) AS revenue_pct

FROM vw_sales_clean fs

JOIN dim_branch b 
    ON fs.branch_id = b.branch_id

JOIN vw_dim_item_clean i
    ON fs.item_id = i.item_id

WHERE fs.is_return = false

GROUP BY 
    b.branch_name,
    item_group

ORDER BY 
    b.branch_name,
    revenue DESC; 

/*
"branch_name"	"item_group"	"revenue"	"weight"	"revenue_pct"
"Branch 01"	"Others"	22539849.7	128727.85000000014	67.35
"Branch 01"	"Chains"	5642809	13434.410000000005	16.86
"Branch 01"	"Rings"	4453504	9552.670000000026	13.31
"Branch 01"	"Coins"	832028	2018.17	2.49
"Branch 02"	"Others"	27761403.14	176749.9210000001	78.04
"Branch 02"	"Chains"	3748298.2	9097.180000000002	10.54
"Branch 02"	"Rings"	3151826.8	6820.740000000003	8.86
"Branch 02"	"Coins"	910813.6	2231	2.56
"Branch 03"	"Others"	12768891.25	117670.38000000009	64.73
"Branch 03"	"Chains"	3553074	7488.909999999997	18.01
"Branch 03"	"Rings"	2948613.8	5727.810000000008	14.95
"Branch 03"	"Coins"	457085	985.8	2.32
"Branch 04"	"Others"	2983679	10046.099999999995	65.30
"Branch 04"	"Chains"	766720	2189.000000000002	16.78
"Branch 04"	"Rings"	757664	1866.020000000001	16.58
"Branch 04"	"Coins"	61060	184.7	1.34
"Branch 05"	"Others"	15547735	254347.70999999982	65.43
"Branch 05"	"Rings"	3994439.99	7748.523999999997	16.81
"Branch 05"	"Chains"	3705075	8181.120000000001	15.59
"Branch 05"	"Coins"	515315	1054.45	2.17
"Branch 06"	"Others"	1451980	5224.3499999999985	57.44
"Branch 06"	"Rings"	600374	1333.3400000000008	23.75
"Branch 06"	"Chains"	434990	1150.3000000000002	17.21
"Branch 06"	"Coins"	40360	113	1.60
"Branch 07"	"Others"	19297260	157896.3600000003	69.10
"Branch 07"	"Rings"	5322451	8901.160000000024	19.06
"Branch 07"	"Chains"	3228800	6592.990000000001	11.56
"Branch 07"	"Coins"	77295	175	0.28
"Branch 08"	"Others"	13010220.5	96976.37899999997	48.88
"Branch 08"	"Rings"	7637327	14532.540000000066	28.69
"Branch 08"	"Chains"	5926220	12233.939000000053	22.27
"Branch 08"	"Coins"	42435	97	0.16
"Branch 09"	"Others"	13875081	90935.14000000017	64.48
"Branch 09"	"Chains"	3830535	9159.450000000008	17.80
"Branch 09"	"Rings"	3018263	6558.550000000012	14.03
"Branch 09"	"Coins"	795659	1989.9299999999998	3.70
"Branch 10"	"Others"	12155875	79351.21000000012	59.37
"Branch 10"	"Chains"	4453930	10426.629999999997	21.75
"Branch 10"	"Rings"	3394955	7049.9799999999805	16.58
"Branch 10"	"Coins"	470545	1103	2.30
"Branch 12"	"Others"	14969815	107010.61200000002	64.46
"Branch 12"	"Rings"	4234198	7827.069999999995	18.23
"Branch 12"	"Chains"	3628343	7851.630000000004	15.62
"Branch 12"	"Coins"	391032	843.5	1.68
"Branch 13"	"Others"	16804822	70935.49999999997	64.18
"Branch 13"	"Chains"	5121827	12281.890000000027	19.56
"Branch 13"	"Rings"	3347558	7163.409999999998	12.79
"Branch 13"	"Coins"	908757	2309.4	3.47
"Branch 15"	"Others"	1188955	4198.250000000002	55.04
"Branch 15"	"Rings"	501895	1149.600000000001	23.23
"Branch 15"	"Chains"	443685	1169.2299999999996	20.54
"Branch 15"	"Coins"	25630	74	1.19
"Branch 16"	"Others"	23546800	151555.41000000015	63.74
"Branch 16"	"Chains"	7238650	17396.640000000047	19.59
"Branch 16"	"Rings"	5193140	11895.010000000018	14.06
"Branch 16"	"Coins"	966070	2357	2.61
"Branch 17"	"Others"	428297	1221.82	55.42
"Branch 17"	"Chains"	157865	457.75000000000006	20.43
"Branch 17"	"Rings"	151445	368.8400000000002	19.60
"Branch 17"	"Coins"	35150	108	4.55
"Branch 18"	"Others"	14526741.020000001	735473.3999999963	98.53
"Branch 18"	"Coins"	124815.33	232.55	0.85
"Branch 18"	"Chains"	62119.38999999999	167.79000000000002	0.42
"Branch 18"	"Rings"	29186.459999999995	51.06	0.20
"Branch 19"	"Others"	19065767	120653.58000000073	68.43
"Branch 19"	"Chains"	4613900	11123.63000000002	16.56
"Branch 19"	"Rings"	3253662	7101.920000000021	11.68
"Branch 19"	"Coins"	928720.55	2337	3.33
"Branch 20"	"Others"	196800	14000	100.00
*/