select * from "dim_branch" LIMIT 10
select * from "dim_category" LIMIT 10
select * from "dim_customer" LIMIT 10
select * from "dim_date" LIMIT 10
select * from "dim_division" LIMIT 10 
select * from "dim_item" LIMIT 10
select * from "dim_item_type" LIMIT 10
select * from "dim_karat" LIMIT 10
select * from "dim_payment_mode" LIMIT 10
select * from "dim_salesperson" LIMIT 10
select * from "dim_sub_category" LIMIT 10	
select * from "fact_branch_daily_summary" LIMIT 10
select * from "fact_group_daily_summary" where total_amount !=0  LIMIT 10
select * from "fact_old_gold_payment" LIMIT 10
select * from "fact_old_gold_purchase" LIMIT 10
select * from "fact_return_payment" LIMIT 10
select * from "fact_returns" LIMIT 100
select * from "fact_sales"  where tax_rate != 0
select * from "fact_sales_payment" order by invoice_id desc
