--KPI 1: Karat Revenue Split
SELECT 
    CASE 
        WHEN purity >= 0.99 THEN '24K'
        WHEN purity >= 0.90 THEN '22K'
        WHEN purity >= 0.75 THEN '18K'
        ELSE 'Other'
    END AS karat,
    ROUND(SUM(total_amount)::NUMERIC,2) AS revenue,
    ROUND(SUM(gross_weight)::NUMERIC,2) AS weight
FROM vw_sales_clean
WHERE is_return = false
GROUP BY 
    CASE 
        WHEN purity >= 0.99 THEN '24K'
        WHEN purity >= 0.90 THEN '22K'
        WHEN purity >= 0.75 THEN '18K'
        ELSE 'Other'
    END
ORDER BY revenue DESC;

"karat"	"revenue"	"weight"
"22K"	209410314.27	471513.92
"24K"	122909976.33	2069395.69
"18K"	9767103.18	26007.07
"Other"	6162691.95	10321.52

--KPI 2: Karat by Branch

SELECT 
    branch_name,    
    CASE 
        WHEN purity >= 0.90 THEN '22K+'
        ELSE 'Lower Karat'
    END AS karat_group,
    
    SUM(total_amount) AS revenue

FROM vw_sales_clean
WHERE is_return = false
GROUP BY branch_name, karat_group;

/*
"branch_name"	"karat_group"	"revenue"
"Branch 01"	"22K+"	31254582
"Branch 01"	"Lower Karat"	2213608.7
"Branch 02"	"22K+"	30212671.540000003
"Branch 02"	"Lower Karat"	5359670.2
"Branch 03"	"22K+"	18661680.55
"Branch 03"	"Lower Karat"	1065983.5
"Branch 04"	"22K+"	4134194.87
"Branch 04"	"Lower Karat"	434928.13
"Branch 05"	"22K+"	23028869.990000002
"Branch 05"	"Lower Karat"	733695
"Branch 06"	"22K+"	2348854
"Branch 06"	"Lower Karat"	178850
"Branch 07"	"22K+"	26513573
"Branch 07"	"Lower Karat"	1412233
"Branch 08"	"22K+"	25725193.5
"Branch 08"	"Lower Karat"	891009
"Branch 09"	"22K+"	21128945
"Branch 09"	"Lower Karat"	390593
"Branch 10"	"22K+"	20142705
"Branch 10"	"Lower Karat"	332600
"Branch 12"	"22K+"	22635233
"Branch 12"	"Lower Karat"	588155
"Branch 13"	"22K+"	25785400
"Branch 13"	"Lower Karat"	397564
"Branch 15"	"22K+"	2081475
"Branch 15"	"Lower Karat"	78690
"Branch 16"	"22K+"	36544940
"Branch 16"	"Lower Karat"	399720
"Branch 17"	"22K+"	700522
"Branch 17"	"Lower Karat"	72235
"Branch 18"	"22K+"	14658038.599999992
"Branch 18"	"Lower Karat"	84823.60000000002
"Branch 19"	"22K+"	26566612.55
"Branch 19"	"Lower Karat"	1295437
"Branch 20"	"22K+"	196800
*/
--KPI 3: Item Type Revenue

SELECT 
    category_name,    
    SUM(total_amount) AS revenue
FROM vw_sales_clean
WHERE is_return = false
GROUP BY category_name
ORDER BY revenue DESC;
/*
"category_name"	"revenue"
"New Gold"	305383103.28
"NEW SILVER"	18124579.949999996
"Old Gold"	14254689.2
"Non-Categorised"	4332636.350000001
"Diamond Jewellery"	4031459.7
"General"	1744128
"CNSM"	253709.26
"DNP"	123475
"NULL"	1924.99
"EARING"	380
*/

--KPI 4: Making Charge per Gram
SELECT 
    CASE 
        WHEN LOWER(item_description) LIKE '%ring%' THEN 'Ring'
        WHEN LOWER(item_description) LIKE '%chain%' THEN 'Chain'
        WHEN LOWER(item_description) LIKE '%bangle%' THEN 'Bangle'
        WHEN LOWER(item_description) LIKE '%coin%' THEN 'Coin'
        WHEN LOWER(item_description) LIKE '%earing%' 
          OR LOWER(item_description) LIKE '%earring%' THEN 'Earring'
        WHEN LOWER(item_description) LIKE '%necklace%' THEN 'Necklace'
        ELSE 'Others'
    END AS item_type,
    ROUND(
        CAST(SUM(making_amount) / NULLIF(SUM(gross_weight),0) AS NUMERIC),
        2
    ) AS making_per_gram,
    ROUND(
        CAST(SUM(making_amount) AS NUMERIC),
        2
    ) AS total_making_revenue,
    ROUND(
        CAST(SUM(gross_weight) AS NUMERIC),
        2
    ) AS total_weight
FROM vw_sales_clean
WHERE is_return = false
GROUP BY item_type
ORDER BY making_per_gram DESC;

"item_type"	"making_per_gram"	"total_making_revenue"	"total_weight"
"Ring"	79.21	8368848.98	105648.24
"Necklace"	54.67	4621277.50	84534.84
"Chain"	43.93	5728365.85	130402.49
"Bangle"	43.44	3580576.21	82420.17
"Coin"	15.24	277577.09	18213.50
"Others"	3.27	7053917.63	2156018.96

--5:Branch-wise Product Performance
SELECT 
    branch_name,
    category_name,

    ROUND(CAST(SUM(total_amount) AS NUMERIC),2) AS revenue,

    ROUND(CAST(SUM(gross_weight) AS NUMERIC),2) AS total_weight,

    COUNT(DISTINCT invoice_id) AS transactions

FROM vw_sales_clean
WHERE is_return = false

GROUP BY 
    branch_name,
    category_name

ORDER BY revenue desc  "branch_name"	"category_name"	"revenue"	"total_weight"	"transactions"
"Branch 16"	"New Gold"	35563445.00	84512.86	6025
"Branch 01"	"New Gold"	28727683.00	67299.74	4787
"Branch 02"	"New Gold"	26489158.54	62347.53	3829
"Branch 13"	"New Gold"	25458785.00	61185.59	4473
"Branch 07"	"New Gold"	25279199.00	51789.74	4332
"Branch 08"	"New Gold"	24845073.50	50758.56	6731
"Branch 19"	"New Gold"	24707397.55	57887.73	4189
"Branch 12"	"New Gold"	21347650.00	46371.31	3909
"Branch 05"	"New Gold"	20645669.99	49030.70	3813
"Branch 09"	"New Gold"	20580168.00	49231.59	3383
"Branch 10"	"New Gold"	19812215.00	44814.32	3967
"Branch 03"	"New Gold"	17082470.55	34267.33	3073
"Branch 18"	"NEW SILVER"	7860858.45	665561.50	354
"Branch 02"	"Old Gold"	7796338.00	21716.23	328
"Branch 18"	"New Gold"	5334453.15	12929.38	587
"Branch 04"	"New Gold"	4247259.00	12823.12	805
"Branch 01"	"Old Gold"	3377116.70	8909.92	129
"Branch 06"	"New Gold"	2430009.00	6341.39	584
"Branch 05"	"NEW SILVER"	2131445.00	195874.10	194
"Branch 15"	"New Gold"	2090035.00	5454.08	480
"Branch 18"	"Non-Categorised"	1496277.85	57095.22	36
"Branch 19"	"Old Gold"	1461247.00	3722.70	35
"Branch 03"	"Old Gold"	1222700.50	2656.73	75
"Branch 07"	"NEW SILVER"	1165972.00	114295.10	125
"Branch 16"	"NEW SILVER"	1004510.00	86291.20	82
"Branch 07"	"Diamond Jewellery"	924072.00	677.00	569
"Branch 08"	"NEW SILVER"	894279.00	70080.30	30
"Branch 03"	"NEW SILVER"	846042.00	70404.80	51
"Branch 01"	"NEW SILVER"	839800.00	66859.90	51
"Branch 19"	"Non-Categorised"	818330.00	24500.00	13
"Branch 17"	"New Gold"	742432.00	2118.41	182
"Branch 12"	"Non-Categorised"	701353.50	16010.90	12
"Branch 02"	"NEW SILVER"	693686.00	75267.20	48
"Branch 12"	"NEW SILVER"	653471.50	60309.60	82
"Branch 08"	"Diamond Jewellery"	607745.00	662.00	590
"Branch 19"	"NEW SILVER"	589900.00	54698.70	57
"Branch 09"	"NEW SILVER"	502944.00	50574.10	48
"Branch 10"	"NEW SILVER"	469600.00	49883.30	82
"Branch 12"	"Diamond Jewellery"	428051.00	310.00	273
"Branch 05"	"Diamond Jewellery"	411454.50	373.00	338
"Branch 07"	"General"	398825.00	440.67	363
"Branch 05"	"Non-Categorised"	328205.00	25127.50	21
"Branch 02"	"Non-Categorised"	273595.00	35041.40	11
"Branch 03"	"General"	264768.00	339.04	293
"Branch 13"	"NEW SILVER"	257075.00	24635.20	36
"Branch 01"	"Diamond Jewellery"	221550.00	227.00	204
"Branch 13"	"Diamond Jewellery"	219210.00	329.00	281
"Branch 08"	"General"	216035.00	244.00	219
"Branch 03"	"Non-Categorised"	207750.00	24000.00	12
"Branch 09"	"Diamond Jewellery"	205580.00	243.00	190
"Branch 20"	"NEW SILVER"	196800.00	14000.00	5
"Branch 04"	"Old Gold"	193348.00	624.70	7
"Branch 02"	"Diamond Jewellery"	192733.00	249.00	212
"Branch 05"	"General"	182220.00	426.50	365
"Branch 01"	"General"	179341.00	250.69	228
"Branch 16"	"Diamond Jewellery"	166205.00	227.00	203
"Branch 19"	"Diamond Jewellery"	152005.00	197.00	174
"Branch 16"	"Non-Categorised"	121050.00	12001.00	11
"Branch 10"	"Diamond Jewellery"	115675.00	131.00	119
"Branch 19"	"General"	115480.00	161.00	147
"Branch 02"	"General"	109364.00	127.48	118
"Branch 04"	"Diamond Jewellery"	104285.00	125.00	108
"Branch 13"	"Old Gold"	102620.00	277.41	24
"Branch 01"	"Non-Categorised"	102170.00	10065.85	6
"Branch 09"	"Old Gold"	101088.00	258.35	13
"Branch 07"	"Non-Categorised"	99455.00	6070.00	9
"Branch 03"	"Diamond Jewellery"	90107.00	103.00	96
"Branch 06"	"Diamond Jewellery"	85995.00	68.00	61
"Branch 16"	"General"	77660.00	119.00	109
"Branch 09"	"Non-Categorised"	66150.00	8000.00	6
"Branch 13"	"General"	59255.00	87.00	75
"Branch 13"	"Non-Categorised"	56370.00	6000.00	6
"Branch 07"	"CNSM"	53008.00	288.00	264
"Branch 15"	"Diamond Jewellery"	51465.00	43.00	35
"Branch 09"	"General"	47365.00	106.03	87
"Branch 05"	"CNSM"	47250.50	474.00	443
"Branch 12"	"CNSM"	45332.00	439.00	423
"Branch 12"	"General"	38930.00	83.00	78
"Branch 10"	"Non-Categorised"	37330.00	3010.20	4
"Branch 10"	"General"	29380.00	27.00	26
"Branch 17"	"Diamond Jewellery"	28585.00	28.00	25
"Branch 18"	"Diamond Jewellery"	26742.20	27.00	22
"Branch 08"	"Non-Categorised"	24600.00	2000.00	1
"Branch 13"	"DNP"	20965.00	38.00	35
"Branch 05"	"DNP"	16320.00	26.00	25
"Branch 18"	"CNSM"	15398.56	229.00	67
"Branch 08"	"CNSM"	14655.00	80.00	64
"Branch 19"	"DNP"	13950.00	18.00	18
"Branch 01"	"CNSM"	13740.00	110.00	101
"Branch 09"	"CNSM"	13613.00	225.00	208
"Branch 08"	"DNP"	13435.00	14.00	14
"Branch 03"	"CNSM"	11876.00	99.00	89
"Branch 04"	"DNP"	11665.00	18.00	18
"Branch 02"	"CNSM"	10487.20	141.00	134
"Branch 16"	"DNP"	9205.00	16.00	15
"Branch 15"	"General"	9040.00	60.00	53
"Branch 13"	"CNSM"	8684.00	138.00	136
"Branch 12"	"DNP"	8600.00	9.00	9
"Branch 06"	"NEW SILVER"	7785.00	1357.60	8
"Branch 10"	"CNSM"	7525.00	59.00	57
"Branch 02"	"DNP"	6980.00	9.00	9
"Branch 18"	"General"	6976.00	17.00	9
"Branch 01"	"DNP"	6790.00	10.00	9
"Branch 15"	"NEW SILVER"	6710.00	1000.00	2
"Branch 04"	"General"	6674.00	61.00	49
"Branch 07"	"DNP"	5275.00	5.00	5
"Branch 19"	"CNSM"	3740.00	31.00	25
"Branch 04"	"NEW SILVER"	3702.00	608.00	7
"Branch 10"	"DNP"	3580.00	6.00	5
"Branch 06"	"General"	2815.00	26.00	24
"Branch 09"	"DNP"	2630.00	5.00	4
"Branch 16"	"CNSM"	2585.00	37.00	26
"Branch 04"	"CNSM"	2190.00	26.00	24
"Branch 03"	"DNP"	1950.00	3.00	3
"Branch 18"	"NULL"	1924.99	65.00	62
"Branch 15"	"CNSM"	1915.00	33.00	31
"Branch 15"	"DNP"	1000.00	1.00	1
"Branch 17"	"CNSM"	890.00	9.00	8
"Branch 17"	"DNP"	850.00	1.00	1
"Branch 06"	"CNSM"	820.00	27.00	26
"Branch 08"	"EARING"	380.00	1.00	1
"Branch 06"	"DNP"	280.00	1.00	1
"Branch 18"	"Old Gold"	231.00	0.70	1