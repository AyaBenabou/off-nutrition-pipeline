SELECT
  s.code,
  p.pays_id,
  m.marque_id,
  c.categorie_id,
  s.nutriscore_lettre,
  s.nutriscore_score,
  s.nutriscore_applicable,
  s.energie_kcal_100g,
  s.graisses_100g,
  s.graisses_saturees_100g,
  s.glucides_100g,
  s.sucres_100g,
  s.fibres_100g,
  s.proteines_100g,
  s.sel_100g
FROM {{ ref('produits') }} s
LEFT JOIN UNNEST(s.pays) AS pc
LEFT JOIN {{ ref('dim_pays') }} p ON p.pays_code = pc
LEFT JOIN {{ ref('dim_marque') }} m ON m.marque = s.marque
LEFT JOIN {{ ref('dim_categorie') }} c
  ON c.cat_generale = s.categories[SAFE_OFFSET(0)]
 AND c.cat_precise = s.categories[SAFE_OFFSET(ARRAY_LENGTH(s.categories) - 1)]