--create view

CREATE OR REPLACE VIEW vw_sales_clean AS
WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                invoice_id,
                invoice_date,
                branch_id,
                customer_id,
                salesperson_id,
                item_id,
                item_code,
                item_description,
                pieces,
                gross_weight,
                net_weight,
                stone_weight,
                pure_weight,
                purity,
                metal_rate,
                making_rate,
                stone_rate,
                metal_amount,
                making_amount,
                stone_amount,
                discount,
                discount_percentage,
                tax_rate,
                tax_amount,
                gross_amount,
                total_amount,
                is_return
            ORDER BY line_item_id
        ) AS rn
    FROM fact_sales
    WHERE total_amount IS NOT NULL
      AND total_amount <> 0
)

SELECT 
    d.line_item_id,
    d.invoice_id,
    d.invoice_date,

    -- Branch
    d.branch_id,
    b.branch_name,

    -- Customer & Sales
    d.customer_id,
    d.salesperson_id,
    d.financial_year,

    -- Item
    d.item_id,
    d.item_code,
    d.item_description,

    -- Category
    i.category_id,
    c.category_name,

    -- Quantity
    d.pieces,

    -- FIXED WEIGHT LOGIC
    d.gross_weight,
    CASE 
        WHEN d.net_weight = 0 THEN d.gross_weight - d.stone_weight
        ELSE d.net_weight
    END AS net_weight,

    d.stone_weight,
    d.pure_weight,
    d.purity,

    -- Rates
    d.metal_rate,
    d.making_rate,
    d.stone_rate,

    -- Amounts
    d.metal_amount,
    d.making_amount,
    d.stone_amount,

    -- FIX DISCOUNT SIGN
    ABS(d.discount) AS discount,
    d.discount_percentage,

    -- Tax
    d.tax_rate,
    d.tax_amount,

    -- Totals
    d.gross_amount,
    d.total_amount,

    -- Return flag
    d.is_return

FROM deduplicated d

LEFT JOIN dim_branch b
    ON d.branch_id = b.branch_id

LEFT JOIN vw_dim_item_clean i
    ON d.item_id = i.item_id

LEFT JOIN dim_category c
    ON i.category_id = c.category_id

WHERE d.rn = 1;


--select * from fact_sales


SELECT *
FROM fact_sales f
WHERE NOT EXISTS (
    SELECT 1
    FROM vw_sales_clean v
    WHERE 
        f.invoice_id = v.invoice_id
        AND f.item_id = v.item_id
        AND f.branch_id = v.branch_id
        AND f.customer_id = v.customer_id
        AND f.salesperson_id = v.salesperson_id
        AND f.total_amount = v.total_amount
        AND f.is_return = v.is_return
);

2q2w2
SELECT 
    s.*,
    CASE 
        WHEN og.purchase_id IS NOT NULL THEN 'POSSIBLE_EXCHANGE'
        ELSE 'NORMAL_SALE'
    END AS transaction_type

FROM fact_sales s
LEFT JOIN fact_old_gold_purchase og
    ON s.customer_id = og.customer_id
   AND s.invoice_date = og.purchase_date;
