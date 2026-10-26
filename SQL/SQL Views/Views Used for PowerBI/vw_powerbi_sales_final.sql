-- View: public.vw_powerbi_sales_final

-- DROP VIEW public.vw_powerbi_sales_final;

CREATE OR REPLACE VIEW public.vw_powerbi_sales_final
 AS
 SELECT s.invoice_id,
    s.invoice_date,
    s.customer_id,
    s.branch_id,
    b.branch_name,
    s.item_id,
    i.item_description,
    it.item_type_name,
    s.category_id,
    c.category_name,
    s.total_amount,
    s.gross_weight,
    s.pure_weight,
    s.making_amount,
    s.is_return
   FROM vw_sales_clean s
     LEFT JOIN vw_dim_item_clean i ON s.item_id = i.item_id
     LEFT JOIN dim_item_type it ON i.item_type_id = it.item_type_id
     LEFT JOIN dim_category c ON s.category_id = c.category_id
     LEFT JOIN dim_branch b ON s.branch_id = b.branch_id;

ALTER TABLE public.vw_powerbi_sales_final
    OWNER TO postgres;

