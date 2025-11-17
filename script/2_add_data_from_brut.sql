BEGIN;

-- COMMUNE
INSERT INTO commune (
    code_insee,
    nom_commune,
    libelle_acheminement,
    code_insee_ancienne_commune,
    nom_ancienne_commune
)
SELECT DISTINCT ON (code_insee)
    TRIM(code_insee),
    nom_commune,
    libelle_acheminement,
    TRIM(code_insee_ancienne_commune),
    nom_ancienne_commune
FROM brut
WHERE code_insee IS NOT NULL
ORDER BY code_insee
ON CONFLICT (code_insee) DO NOTHING;


-- CODE_POSTAL
INSERT INTO code_postal (code_postal)
SELECT DISTINCT TRIM(code_postal)
FROM brut
WHERE code_postal IS NOT NULL
ON CONFLICT (code_postal) DO NOTHING;


-- VOIE
INSERT INTO voie (id_commune, id_fantoir, nom_voie, nom_afnor, source_nom_voie)
SELECT DISTINCT
    commune.id,
    brut.id_fantoir,
    brut.nom_voie,
    brut.nom_afnor,
    brut.source_nom_voie
FROM brut
JOIN commune
  ON commune.code_insee = TRIM(brut.code_insee)
WHERE brut.nom_voie IS NOT NULL;


-- PARCELLES
INSERT INTO parcelles (cad_parcelles)
SELECT DISTINCT cad_parcelles
FROM brut
WHERE cad_parcelles IS NOT NULL
  AND cad_parcelles <> '';


-- ADRESSE
INSERT INTO adresse (
    numero,
    rep,
    lon,
    lat,
    x,
    y,
    type_position,
    alias,
    nom_ld,
    source_position,
    certification_commune,
    id_voie,
    id_cad_parcelles,
    id_code_postal
)
SELECT
    brut.numero,
    brut.rep,
    brut.lon,
    brut.lat,
    brut.x,
    brut.y,
    brut.type_position,
    brut.alias,
    brut.nom_ld,
    brut.source_position,
    brut.certification_commune,
    voie.id,
    parcelles.id,
    code_postal.id
FROM brut
JOIN commune
  ON commune.code_insee = TRIM(brut.code_insee)
JOIN voie
  ON voie.id_commune = commune.id
 AND voie.nom_voie = brut.nom_voie
LEFT JOIN parcelles
  ON parcelles.cad_parcelles = brut.cad_parcelles
LEFT JOIN code_postal
  ON code_postal.code_postal = TRIM(brut.code_postal);

COMMIT;
