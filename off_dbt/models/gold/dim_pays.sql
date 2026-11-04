SELECT
  ROW_NUMBER() OVER (ORDER BY nb_produits DESC, pays_code) AS pays_id,
  pays_code,
  INITCAP(REPLACE(REGEXP_REPLACE(pays_code, r'^[a-z]{2}:', ''), '-', ' ')) AS pays_nom,
  nb_produits,
  nb_produits >= 25000 AS pays_retenu
FROM (
  SELECT p AS pays_code, COUNT(*) AS nb_produits
  FROM {{ ref('produits') }}, UNNEST(pays) AS p
  GROUP BY p
)