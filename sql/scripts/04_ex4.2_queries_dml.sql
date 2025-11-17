-- 4.2 Requêtes d’insertion / mise à jour / suppression

BEGIN;

-- 1) Créer la commune (si elle n'existe pas déjà)
INSERT INTO commune (
    code_insee,
    nom_commune,
    libelle_acheminement,
    code_insee_ancienne_commune,
    nom_ancienne_commune
)
VALUES (
    '99999',
    'Commune Démo',
    'COMMUNE DEMO',
    NULL,
    NULL
)
ON CONFLICT (code_insee) DO NOTHING;

-- 2) Créer le code postal (si besoin)
INSERT INTO code_postal (code_postal)
VALUES ('99999')
ON CONFLICT (code_postal) DO NOTHING;

-- 3) Créer la voie
INSERT INTO voie (id_commune, id_fantoir, nom_voie, nom_afnor, source_nom_voie)
VALUES (
    (SELECT id FROM commune WHERE code_insee = '99999'),
    NULL,
    'Rue de la Démo',
    'RUE DE LA DEMO',
    'commune'
);

-- 4) Créer la parcelle (optionnel)
INSERT INTO parcelles (cad_parcelles)
VALUES ('999990000A0001');

-- 5) Créer l’adresse
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
VALUES (
    '10',
    NULL,
    5.000000,
    45.000000,
    800000.00,
    6500000.00,
    'entrée',
    NULL,
    NULL,
    'commune',
    TRUE,
    (SELECT id FROM voie WHERE nom_voie = 'Rue de la Démo' AND id_commune = (SELECT id FROM commune WHERE code_insee = '99999')),
    (SELECT id FROM parcelles WHERE cad_parcelles = '999990000A0001'),
    (SELECT id FROM code_postal WHERE code_postal = '99999')
);

COMMIT;


-- Mettre à jour le nom d’une voie pour une adresse spécifique
UPDATE voie
SET nom_voie = 'Nouveau nom de voie'
WHERE id = (
    SELECT id_voie
    FROM adresse
    WHERE id = 123
);


-- Supprimer toutes les adresses avec un champ critique manquant (numéro de voie vide)
DELETE FROM adresse
WHERE numero IS NULL
   OR TRIM(numero) = '';