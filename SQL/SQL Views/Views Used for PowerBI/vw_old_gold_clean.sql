-- View: public.vw_old_gold_clean

-- DROP VIEW public.vw_old_gold_clean;

CREATE OR REPLACE VIEW public.vw_old_gold_clean
 AS
 SELECT og.line_item_id,
    og.purchase_id,
    og.purchase_date,
    date_trunc('month'::text, og.purchase_date::timestamp with time zone) AS purchase_month,
    og.branch_id,
    og.customer_id,
    og.salesperson_id,
    og.financial_year,
    og.item_id,
    di.item_code,
    di.item_description,
    dit.item_type_name,
    og.pieces,
    COALESCE(og.gross_weight, 0::double precision) AS gross_weight,
    COALESCE(og.net_weight, 0::double precision) AS net_weight,
    COALESCE(og.stone_weight, 0::double precision) AS stone_weight,
    COALESCE(og.pure_weight, 0::double precision) AS pure_weight,
    og.purity,
    COALESCE(og.metal_rate, 0::double precision) AS metal_rate,
    COALESCE(og.market_rate, 0::double precision) AS market_rate,
    COALESCE(og.stone_rate, 0::double precision) AS stone_rate,
    COALESCE(og.metal_amount, 0::double precision) AS metal_amount,
    COALESCE(og.stone_amount, 0::double precision) AS stone_amount,
    COALESCE(og.total_amount, 0::double precision) AS total_amount,
        CASE
            WHEN og.total_amount < 1000::double precision THEN '<1K'::text
            WHEN og.total_amount < 5000::double precision THEN '1K-5K'::text
            WHEN og.total_amount < 10000::double precision THEN '5K-10K'::text
            ELSE '10K+'::text
        END AS value_bucket
   FROM fact_old_gold_purchase og
     LEFT JOIN vw_dim_item_clean di ON og.item_id = di.item_id
     LEFT JOIN dim_item_type dit ON di.item_type_id = dit.item_type_id;

ALTER TABLE public.vw_old_gold_clean
    OWNER TO postgres;

