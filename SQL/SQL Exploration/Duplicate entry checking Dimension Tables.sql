--Dimension Tables Duplicate entry checking
--dim_branch

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
branch_id, branch_code, branch_name
) dup_count
FROM dim_branch)
SELECT * FROM d WHERE dup_count > 1;

--dim_customer

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
customer_id, customer_code, registration_date, branch_id
) dup_count
FROM dim_customer)
SELECT * FROM d WHERE dup_count > 1;

--dim_salesperson

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
salesperson_id, salesperson_code, salesperson_name, branch_id
) dup_count
FROM dim_salesperson)
SELECT * FROM d WHERE dup_count > 1;

--dim_item

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
item_id, item_code, item_description, division_id,
karat_id, item_type_id, category_id,
sub_category_id, purity
) dup_count
FROM dim_item)
SELECT * FROM d WHERE dup_count > 1;

--

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
date_key, day_of_month, day_name, day_of_week,
week_of_year, month_number, month_name,
quarter, year, is_weekend
) dup_count
FROM dim_date)
SELECT * FROM d WHERE dup_count > 1;

--

WITH d AS (
SELECT *,
COUNT(*) OVER (PARTITION BY 
payment_mode_id, payment_mode_code,
payment_mode_name, payment_type
) dup_count
FROM dim_payment_mode)
SELECT * FROM d WHERE dup_count > 1;


Unique checking

SELECT 
COUNT(*) AS total_rows,
COUNT(DISTINCT *) AS unique_rows
FROM table_name;