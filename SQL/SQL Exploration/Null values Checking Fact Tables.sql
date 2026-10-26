SELECT
    COUNT(*) AS total_rows,

    COUNT(*) - COUNT(invoice_id) AS invoice_id_nulls,
    COUNT(*) - COUNT(invoice_date) AS invoice_date_nulls,
    COUNT(*) - COUNT(branch_id) AS branch_id_nulls,
    COUNT(*) - COUNT(customer_id) AS customer_id_nulls,
    COUNT(*) - COUNT(salesperson_id) AS salesperson_id_nulls,
    COUNT(*) - COUNT(item_id) AS item_id_nulls,
    COUNT(*) - COUNT(item_code) AS item_code_nulls,
    COUNT(*) - COUNT(pieces) AS pieces_nulls,
    COUNT(*) - COUNT(gross_weight) AS gross_weight_nulls,
    COUNT(*) - COUNT(net_weight) AS net_weight_nulls,
    COUNT(*) - COUNT(pure_weight) AS pure_weight_nulls,
    COUNT(*) - COUNT(metal_amount) AS metal_amount_nulls,
    COUNT(*) - COUNT(total_amount) AS total_amount_nulls

FROM fact_sales;