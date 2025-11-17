-- 4.1 Requêtes de consultation
EXPLAIN ANALYZE
-- Lister toutes les adresses d’une commune donnée, triées par voie.
SELECT
    commune.nom_commune,
    voie.nom_voie,
    adresse.numero,
    adresse.rep,
    adresse.nom_ld,
    adresse.alias,
    adresse.lon,
    adresse.lat
FROM adresse
JOIN voie
  ON adresse.id_voie = voie.id
JOIN commune
  ON voie.id_commune = commune.id
LEFT JOIN code_postal
  ON adresse.id_code_postal = code_postal.id
WHERE commune.nom_commune = 'Argis'
ORDER BY
    voie.nom_voie,
    adresse.numero,
    adresse.rep;

-- Compter le nombre d’adresses par commune
SELECT
    commune.code_insee,
    commune.nom_commune,
    COUNT(adresse.id) AS nombre_adresses
FROM adresse
JOIN voie
  ON adresse.id_voie = voie.id
JOIN commune
  ON voie.id_commune = commune.id
GROUP BY
    commune.code_insee,
    commune.nom_commune
ORDER BY
    commune.nom_commune;

-- Lister toutes les communes distinctes présentes (issues du fichier)
SELECT
    code_insee,
    nom_commune,
    libelle_acheminement,
    code_insee_ancienne_commune,
    nom_ancienne_commune
FROM commune
ORDER BY
    nom_commune;


-- Rechercher toutes les adresses dont le nom de voie contient un mot-clé
SELECT
    commune.nom_commune,
    voie.nom_voie,
    adresse.numero,
    adresse.rep,
    adresse.nom_ld,
    adresse.alias,
    adresse.lon,
    adresse.lat
FROM adresse
JOIN voie
  ON adresse.id_voie = voie.id
JOIN commune
  ON voie.id_commune = commune.id
LEFT JOIN code_postal
  ON adresse.id_code_postal = code_postal.id
WHERE voie.nom_voie ILIKE '%Rue%'   -- ⬅️ mot-clé ici (insensible à la casse)
ORDER BY
    commune.nom_commune,
    voie.nom_voie,
    adresse.numero,
    adresse.rep;


-- Adresses où le code postal est vide mais la commune est renseignée
SELECT
    commune.nom_commune,
    voie.nom_voie,
    adresse.numero,
    adresse.rep,
    adresse.nom_ld,
    adresse.alias,
    adresse.lon,
    adresse.lat
FROM adresse
JOIN voie
  ON adresse.id_voie = voie.id
JOIN commune
  ON voie.id_commune = commune.id
LEFT JOIN code_postal
  ON adresse.id_code_postal = code_postal.id
WHERE adresse.id_code_postal IS NULL
ORDER BY
    commune.nom_commune,
    voie.nom_voie,
    adresse.numero,
    adresse.rep;




