-- View: public.vw_dim_item_clean

-- DROP VIEW public.vw_dim_item_clean;

CREATE OR REPLACE VIEW public.vw_dim_item_clean
 AS
 SELECT item_id,
    item_code,
    item_description,
    division_id,
    karat_id,
    item_type_id,
        CASE
            WHEN COALESCE(category_id, 0::bigint) = ANY (ARRAY[0::bigint, 8::bigint]) THEN
            CASE
                WHEN lower(item_description::text) ~~ '%diamond%'::text OR lower(item_description::text) ~~ '%ring%'::text OR lower(item_description::text) ~~ '%earing%'::text OR lower(item_description::text) ~~ '%earring%'::text OR lower(item_description::text) ~~ '%pendant%'::text OR lower(item_description::text) ~~ '%nosepin%'::text THEN 6
                WHEN lower(item_description::text) ~~ '%18 karat%'::text OR lower(item_description::text) ~~ '%22 karat%'::text THEN 3
                WHEN lower(item_description::text) ~~ '%perfume%'::text OR lower(item_description::text) ~~ '%crown%'::text OR lower(item_description::text) ~~ '%jauhara%'::text THEN 1
                WHEN lower(item_description::text) ~~ '%golden rose%'::text THEN 1
                ELSE 2
            END::bigint
            ELSE category_id
        END AS category_id,
    sub_category_id,
    purity
   FROM dim_item;

ALTER TABLE public.vw_dim_item_clean
    OWNER TO postgres;

