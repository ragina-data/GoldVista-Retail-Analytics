SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (
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
                profit_making,
                profit_metal,
                profit_others,
                total_amount,
                is_return
    )) AS unique_rows
FROM fact_branch_daily_summary;