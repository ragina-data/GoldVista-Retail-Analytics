SELECT *
FROM fact_sales
WHERE 
    invoice_id IS NULL OR
    invoice_date IS NULL OR
    branch_id IS NULL OR
    customer_id IS NULL OR
    salesperson_id IS NULL OR
    item_id IS NULL OR
    item_code IS NULL OR
    pieces IS NULL OR
    gross_weight IS NULL OR
    net_weight IS NULL OR
    pure_weight IS NULL OR
    metal_amount IS NULL OR
    making_amount IS NULL OR
    total_amount IS NULL;