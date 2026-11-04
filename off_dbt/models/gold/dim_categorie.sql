WITH paires AS (
  SELECT
    categories[SAFE_OFFSET(0)] AS cat_generale,
    categories[SAFE_OFFSET(ARRAY_LENGTH(categories) - 1)] AS cat_precise
  FROM {{ ref('produits') }}
  WHERE ARRAY_LENGTH(categories) > 0
)
SELECT
  ROW_NUMBER() OVER (ORDER BY nb_produits DESC, cat_generale, cat_precise) AS categorie_id,
  cat_generale,
  cat_precise,
  INITCAP(REPLACE(REGEXP_REPLACE(cat_generale, r'^[a-z]{2}:', ''), '-', ' ')) AS generale_nom,
  INITCAP(REPLACE(REGEXP_REPLACE(cat_precise, r'^[a-z]{2}:', ''), '-', ' ')) AS precise_nom,
  STARTS_WITH(cat_generale, 'en:') AS normalisee,
  nb_produits
FROM (
  SELECT cat_generale, cat_precise, COUNT(*) AS nb_produits
  FROM paires
  GROUP BY cat_generale, cat_precise
)