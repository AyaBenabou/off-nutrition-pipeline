WITH nettoye AS (
  SELECT
    code,
    NULLIF(TRIM(COALESCE(
      (SELECT t.text FROM UNNEST(product_name) t WHERE t.lang = 'main' LIMIT 1),
      product_name[SAFE_OFFSET(0)].text
    )), '') AS nom,
    NULLIF(LOWER(TRIM(SPLIT(brands, ',')[SAFE_OFFSET(0)])), '') AS marque,
    ARRAY(SELECT c FROM UNNEST(categories_tags) c
          WHERE c IS NOT NULL AND c != 'en:null') AS categories,
    ARRAY(SELECT p FROM UNNEST(countries_tags) p
          WHERE p IS NOT NULL AND p != 'en:world') AS pays,
    IF(nutriscore_grade IN ('a','b','c','d','e'), nutriscore_grade, NULL) AS nutriscore_lettre,
    nutriscore_score,
    IFNULL(nutriscore_grade, '') != 'not-applicable' AS nutriscore_applicable,
    no_nutrition_data,
    nutrition_data_per,
    IF(energie_kcal_100g BETWEEN 0 AND 900, energie_kcal_100g, NULL) AS energie_kcal_100g,
    IF(graisses_100g BETWEEN 0 AND 100, graisses_100g, NULL) AS graisses_100g,
    IF(graisses_saturees_100g BETWEEN 0 AND 100, graisses_saturees_100g, NULL) AS graisses_saturees_100g,
    IF(glucides_100g BETWEEN 0 AND 100, glucides_100g, NULL) AS glucides_100g,
    IF(sucres_100g BETWEEN 0 AND 100, sucres_100g, NULL) AS sucres_100g,
    IF(fibres_100g BETWEEN 0 AND 100, fibres_100g, NULL) AS fibres_100g,
    IF(proteines_100g BETWEEN 0 AND 100, proteines_100g, NULL) AS proteines_100g,
    IF(sel_100g BETWEEN 0 AND 100, sel_100g, NULL) AS sel_100g
  FROM {{ source('bronze', 'produits') }}
  WHERE code IS NOT NULL AND TRIM(code) != ''
)
SELECT * FROM nettoye
WHERE TRUE
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY code
  ORDER BY CAST(nom IS NOT NULL AS INT64) + CAST(marque IS NOT NULL AS INT64)
         + CAST(nutriscore_lettre IS NOT NULL AS INT64)
         + CAST(nutriscore_score IS NOT NULL AS INT64)
         + CAST(nutrition_data_per IS NOT NULL AS INT64) DESC
) = 1