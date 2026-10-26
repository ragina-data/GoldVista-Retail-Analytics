-- View: public.vw_sales_clean

-- DROP VIEW public.vw_sales_clean;

CREATE OR REPLACE VIEW public.vw_sales_clean
 AS
 WITH deduplicated AS (
         SELECT fact_sales.line_item_id,
            fact_sales.invoice_id,
            fact_sales.invoice_date,
            fact_sales.branch_id,
            fact_sales.customer_id,
            fact_sales.salesperson_id,
            fact_sales.financial_year,
            fact_sales.item_id,
            fact_sales.item_code,
            fact_sales.item_description,
            fact_sales.pieces,
            fact_sales.gross_weight,
            fact_sales.net_weight,
            fact_sales.stone_weight,
            fact_sales.pure_weight,
            fact_sales.purity,
            fact_sales.metal_rate,
            fact_sales.making_rate,
            fact_sales.stone_rate,
            fact_sales.metal_amount,
            fact_sales.making_amount,
            fact_sales.stone_amount,
            fact_sales.discount,
            fact_sales.discount_percentage,
            fact_sales.tax_rate,
            fact_sales.tax_amount,
            fact_sales.gross_amount,
            fact_sales.total_amount,
            fact_sales.is_return,
            row_number() OVER (PARTITION BY fact_sales.invoice_id, fact_sales.invoice_date, fact_sales.branch_id, fact_sales.customer_id, fact_sales.salesperson_id, fact_sales.item_id, fact_sales.item_code, fact_sales.item_description, fact_sales.pieces, fact_sales.gross_weight, fact_sales.net_weight, fact_sales.stone_weight, fact_sales.pure_weight, fact_sales.purity, fact_sales.metal_rate, fact_sales.making_rate, fact_sales.stone_rate, fact_sales.metal_amount, fact_sales.making_amount, fact_sales.stone_amount, fact_sales.discount, fact_sales.discount_percentage, fact_sales.tax_rate, fact_sales.tax_amount, fact_sales.gross_amount, fact_sales.total_amount, fact_sales.is_return ORDER BY fact_sales.line_item_id) AS rn
           FROM fact_sales
          WHERE fact_sales.total_amount IS NOT NULL AND fact_sales.total_amount <> 0::double precision
        )
 SELECT d.line_item_id,
    d.invoice_id,
    d.invoice_date,
    d.branch_id,
    b.branch_name,
    d.customer_id,
    d.salesperson_id,
    d.financial_year,
    d.item_id,
    d.item_code,
    d.item_description,
    i.category_id,
    c.category_name,
    d.pieces,
    d.gross_weight,
        CASE
            WHEN d.net_weight = 0::double precision THEN d.gross_weight - d.stone_weight
            ELSE d.net_weight
        END AS net_weight,
    d.stone_weight,
    d.pure_weight,
    d.purity,
        CASE
            WHEN d.purity >= 0.99::double precision THEN '24K'::text
            WHEN d.purity >= 0.90::double precision THEN '22K'::text
            WHEN d.purity >= 0.75::double precision THEN '18K'::text
            ELSE 'Other'::text
        END AS karat,
    d.metal_rate,
    d.making_rate,
    d.stone_rate,
    d.metal_amount,
    d.making_amount,
    d.stone_amount,
    round(
        CASE
            WHEN d.net_weight > 0::double precision THEN d.metal_amount / d.net_weight
            ELSE d.metal_rate
        END::numeric, 2) AS gold_rate,
    round(
        CASE
            WHEN d.net_weight > 0::double precision THEN d.making_amount / d.net_weight
            ELSE NULL::double precision
        END::numeric, 2) AS making_per_gram,
    abs(d.discount) AS discount,
    d.discount_percentage,
    round(
        CASE
            WHEN d.gross_amount > 0::double precision THEN abs(d.discount) * 100.0::double precision / d.gross_amount
            ELSE NULL::double precision
        END::numeric, 2) AS discount_pct_calc,
    d.tax_rate,
    d.tax_amount,
    d.gross_amount,
    d.total_amount,
    d.is_return
   FROM deduplicated d
     LEFT JOIN dim_branch b ON d.branch_id = b.branch_id
     LEFT JOIN vw_dim_item_clean i ON d.item_id = i.item_id
     LEFT JOIN dim_category c ON i.category_id = c.category_id
  WHERE d.rn = 1;

ALTER TABLE public.vw_sales_clean
    OWNER TO postgres;

