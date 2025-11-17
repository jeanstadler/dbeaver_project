-- 4.3 Détection de problèmes et qualité des données


-- 1) Identifier doublons exacts (mêmes numéro + nom de voie + code postal + commune)
SELECT
    commune.nom_commune,
    commune.code_insee,
    voie.nom_voie,
    code_postal.code_postal,
    adresse.numero,
    adresse.rep,
    COUNT(*) AS nombre_doublons,
    STRING_AGG(adresse.id::TEXT, ', ') AS liste_ids
FROM adresse
JOIN voie
  ON adresse.id_voie = voie.id
JOIN commune
  ON voie.id_commune = commune.id
LEFT JOIN code_postal
  ON adresse.id_code_postal = code_postal.id
GROUP BY
    commune.nom_commune,
    commune.code_insee,
    voie.nom_voie,
    code_postal.code_postal,
    adresse.numero,
    adresse.rep
HAVING COUNT(*) > 1
ORDER BY
    nombre_doublons DESC,
    commune.nom_commune,
    voie.nom_voie;


-- 2) Identifier les adresses incohérentes sans coordonnées GPS
SELECT
    commune.nom_commune,
    voie.nom_voie,
    adresse.numero,
    adresse.rep,
    adresse.nom_ld,
    adresse.alias,
    adresse.lon,
    adresse.lat,
    adresse.id
FROM adresse
JOIN voie
  ON adresse.id_voie = voie.id
JOIN commune
  ON voie.id_commune = commune.id
WHERE adresse.lon IS NULL
   OR adresse.lat IS NULL
ORDER BY
    commune.nom_commune,
    voie.nom_voie,
    adresse.numero;


-- 3) Lister les codes postaux avec plus de 10 000 adresses pour détecter les anomalies volumétriques
SELECT
    code_postal.code_postal,
    COUNT(adresse.id) AS nombre_adresses,
    STRING_AGG(DISTINCT commune.nom_commune, ', ') AS communes_concernees
FROM adresse
JOIN code_postal
  ON adresse.id_code_postal = code_postal.id
JOIN voie
  ON adresse.id_voie = voie.id
JOIN commune
  ON voie.id_commune = commune.id
GROUP BY
    code_postal.code_postal
HAVING COUNT(adresse.id) > 10000
ORDER BY
    nombre_adresses DESC;