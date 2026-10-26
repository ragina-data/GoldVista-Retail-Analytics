--5. vw_payment_analysis

CREATE OR REPLACE VIEW vw_payment_analysis AS
SELECT 
    pm.payment_type,
    COUNT(*) AS transactions,
    SUM(fsp.amount) AS total_amount
FROM fact_sales_payment fsp
JOIN dim_payment_mode pm
    ON fsp.payment_mode_id = pm.payment_mode_id
GROUP BY pm.payment_type;

/*
select * from dim_category
select * from dim_division
select * from fact_sales_payment
select * from dim_payment_mode
select sum(total_amount) from vw_payment_analysis 
union all
select sum(amount) from fact_sales_payment
union all
select sum(total_amount) from fact_sales where is_return=false
*/

