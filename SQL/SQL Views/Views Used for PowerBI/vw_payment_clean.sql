-- View: public.vw_payment_clean

-- DROP VIEW public.vw_payment_clean;

CREATE OR REPLACE VIEW public.vw_payment_clean
 AS
 SELECT fsp.invoice_id,
    fsp.payment_id,
    fsp.amount,
    pm.payment_mode_name,
        CASE
            WHEN pm.payment_type::text = 'CASH'::text THEN 'Cash'::text
            WHEN pm.payment_type::text = 'CARD'::text THEN 'Card'::text
            WHEN pm.payment_type::text = 'CHEQUE'::text THEN 'Cheque'::text
            WHEN pm.payment_type::text = 'TRANSFER'::text THEN 'Bank Transfer'::text
            WHEN pm.payment_type::text = 'LOYALTY_POINT_REDEMPTION'::text THEN 'Non-Cash Adjustment'::text
            ELSE 'Others'::text
        END AS payment_type
   FROM fact_sales_payment fsp
     JOIN dim_payment_mode pm ON fsp.payment_mode_id = pm.payment_mode_id;

ALTER TABLE public.vw_payment_clean
    OWNER TO postgres;

