SELECT
  ROW_NUMBER() OVER (ORDER BY nb_produits DESC, marque) AS marque_id,
  marque,
  nb_produits,
  nb_produits >= 30 AS marque_retenue
FROM (
  SELECT marque, COUNT(*) AS nb_produits
  FROM {{ ref('produits') }}
  WHERE marque IS NOT NULL
  GROUP BY marque
)