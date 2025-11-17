-- 4.4 Requêtes d'agrégation et analyse


-- 1) Nombre moyen d'adresses par commune et par voie
-- Moyenne par commune
SELECT
    'Par commune' AS type_calcul,
    ROUND(AVG(nb_adresses), 2) AS moyenne_adresses,
    MIN(nb_adresses) AS min_adresses,
    MAX(nb_adresses) AS max_adresses
FROM (
    SELECT
        commune.id,
        COUNT(adresse.id) AS nb_adresses
    FROM commune
    LEFT JOIN voie
      ON voie.id_commune = commune.id
    LEFT JOIN adresse
      ON adresse.id_voie = voie.id
    GROUP BY commune.id
) AS stats_commune

UNION ALL

-- Moyenne par voie
SELECT
    'Par voie' AS type_calcul,
    ROUND(AVG(nb_adresses), 2) AS moyenne_adresses,
    MIN(nb_adresses) AS min_adresses,
    MAX(nb_adresses) AS max_adresses
FROM (
    SELECT
        voie.id,
        COUNT(adresse.id) AS nb_adresses
    FROM voie
    LEFT JOIN adresse
      ON adresse.id_voie = voie.id
    GROUP BY voie.id
) AS stats_voie;


-- 2) Top 10 des communes avec le plus d'adresses
SELECT
    commune.code_insee,
    commune.nom_commune,
    commune.libelle_acheminement,
    COUNT(adresse.id) AS nombre_adresses,
    COUNT(DISTINCT voie.id) AS nombre_voies,
    ROUND(COUNT(adresse.id)::NUMERIC / COUNT(DISTINCT voie.id), 2) AS moyenne_adresses_par_voie
FROM commune
JOIN voie
  ON voie.id_commune = commune.id
JOIN adresse
  ON adresse.id_voie = voie.id
GROUP BY
    commune.code_insee,
    commune.nom_commune,
    commune.libelle_acheminement
ORDER BY
    nombre_adresses DESC
LIMIT 10;


-- 3) Vérifier la complétude des champs essentiels (numéro, voie, code postal, commune)
SELECT
    COUNT(*) AS total_adresses,
    
    -- Numéro
    COUNT(CASE WHEN numero IS NOT NULL AND TRIM(numero) <> '' THEN 1 END) AS numero_renseigne,
    ROUND(100.0 * COUNT(CASE WHEN numero IS NOT NULL AND TRIM(numero) <> '' THEN 1 END) / COUNT(*), 2) AS pct_numero,
    
    -- Voie (toujours renseignée car FK NOT NULL)
    COUNT(id_voie) AS voie_renseignee,
    ROUND(100.0 * COUNT(id_voie) / COUNT(*), 2) AS pct_voie,
    
    -- Code postal
    COUNT(id_code_postal) AS code_postal_renseigne,
    ROUND(100.0 * COUNT(id_code_postal) / COUNT(*), 2) AS pct_code_postal,
    
    -- Commune (via voie, toujours renseignée)
    COUNT(DISTINCT voie.id_commune) AS communes_distinctes,
    
    -- Coordonnées GPS (bonus)
    COUNT(CASE WHEN lon IS NOT NULL AND lat IS NOT NULL THEN 1 END) AS coords_gps_completes,
    ROUND(100.0 * COUNT(CASE WHEN lon IS NOT NULL AND lat IS NOT NULL THEN 1 END) / COUNT(*), 2) AS pct_coords_gps,
    
    -- Enregistrements 100% complets
    COUNT(CASE 
        WHEN numero IS NOT NULL 
         AND TRIM(numero) <> ''
         AND id_voie IS NOT NULL
         AND id_code_postal IS NOT NULL
         AND lon IS NOT NULL
         AND lat IS NOT NULL
        THEN 1 
    END) AS adresses_100_completes,
    ROUND(100.0 * COUNT(CASE 
        WHEN numero IS NOT NULL 
         AND TRIM(numero) <> ''
         AND id_voie IS NOT NULL
         AND id_code_postal IS NOT NULL
         AND lon IS NOT NULL
         AND lat IS NOT NULL
        THEN 1 
    END) / COUNT(*), 2) AS pct_100_complet
    
FROM adresse
JOIN voie
  ON adresse.id_voie = voie.id;