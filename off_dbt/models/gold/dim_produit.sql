SELECT code, nom
FROM {{ ref('produits') }}