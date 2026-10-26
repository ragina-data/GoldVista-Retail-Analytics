-- View: public.vw_branch_daily_summary

-- DROP VIEW public.vw_branch_daily_summary;

CREATE OR REPLACE VIEW public.vw_branch_daily_summary
 AS
 SELECT summary_id,
    branch_id,
    summary_date,
    gold_weight,
    gold_amount,
    silver_weight,
    silver_amount,
    diamond_pieces,
    diamond_amount,
    watch_pieces,
    watch_amount,
    non_jewellery_pieces,
    non_jewellery_amount,
    profit_making,
    profit_metal,
    profit_others,
    COALESCE(gold_amount, 0::double precision) + COALESCE(silver_amount, 0::double precision) + COALESCE(diamond_amount, 0::double precision) + COALESCE(watch_amount, 0::double precision) + COALESCE(non_jewellery_amount, 0::double precision) AS total_amount,
    is_return
   FROM ( SELECT fact_branch_daily_summary.summary_id,
            fact_branch_daily_summary.branch_id,
            fact_branch_daily_summary.summary_date,
            fact_branch_daily_summary.gold_weight,
            fact_branch_daily_summary.gold_amount,
            fact_branch_daily_summary.silver_weight,
            fact_branch_daily_summary.silver_amount,
            fact_branch_daily_summary.diamond_pieces,
            fact_branch_daily_summary.diamond_amount,
            fact_branch_daily_summary.watch_pieces,
            fact_branch_daily_summary.watch_amount,
            fact_branch_daily_summary.non_jewellery_pieces,
            fact_branch_daily_summary.non_jewellery_amount,
            fact_branch_daily_summary.profit_making,
            fact_branch_daily_summary.profit_metal,
            fact_branch_daily_summary.profit_others,
            fact_branch_daily_summary.total_amount,
            fact_branch_daily_summary.is_return,
            row_number() OVER (PARTITION BY fact_branch_daily_summary.branch_id, fact_branch_daily_summary.summary_date ORDER BY fact_branch_daily_summary.summary_id) AS rn
           FROM fact_branch_daily_summary) t
  WHERE rn = 1;

ALTER TABLE public.vw_branch_daily_summary
    OWNER TO postgres;

