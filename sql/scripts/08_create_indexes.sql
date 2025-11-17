-- Index pour accélérer les JOIN entre voie et commune
CREATE INDEX IF NOT EXISTS idx_voie_id_commune
    ON voie (id_commune);

-- Index pour accélérer les JOIN entre adresse et voie
CREATE INDEX IF NOT EXISTS idx_adresse_id_voie
    ON adresse (id_voie);

-- Index pour accélérer les JOIN entre adresse et code_postal
CREATE INDEX IF NOT EXISTS idx_adresse_id_code_postal
    ON adresse (id_code_postal);

-- Index pour accélérer les filtres sur le nom de la commune
CREATE INDEX IF NOT EXISTS idx_commune_nom_commune
    ON commune (nom_commune);

-- Index pour accélérer les filtres / tris sur le nom de voie
CREATE INDEX IF NOT EXISTS idx_voie_nom_voie
    ON voie (nom_voie);
