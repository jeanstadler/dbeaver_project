
-- TABLE PARCELLES
CREATE TABLE IF NOT EXISTS parcelles (
    id SERIAL PRIMARY KEY,
    cad_parcelles TEXT
);


-- TABLE CODE_POSTAL
CREATE TABLE IF NOT EXISTS code_postal (
    id SERIAL PRIMARY KEY,
    code_postal CHAR(5) NOT NULL UNIQUE
);


-- TABLE COMMUNE
CREATE TABLE IF NOT EXISTS commune (
    id SERIAL PRIMARY KEY,
    code_insee VARCHAR(5) UNIQUE NOT NULL,
    nom_commune VARCHAR(100),
    libelle_acheminement VARCHAR(100),
    code_insee_ancienne_commune VARCHAR(5),
    nom_ancienne_commune VARCHAR(100)
);


-- TABLE VOIE
CREATE TABLE IF NOT EXISTS voie (
    id SERIAL PRIMARY KEY,
    id_commune INTEGER NOT NULL,
    id_fantoir VARCHAR(50),
    nom_voie VARCHAR(255) NOT NULL,
    nom_afnor VARCHAR(255),
    source_nom_voie VARCHAR(50),

    CONSTRAINT fk_commune
        FOREIGN KEY (id_commune) REFERENCES commune(id)
);


-- TABLE ADRESSE
CREATE TABLE IF NOT EXISTS adresse (
    id SERIAL PRIMARY KEY,
    numero VARCHAR(10),
    rep VARCHAR(10),
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    x DOUBLE PRECISION,
    y DOUBLE PRECISION,
    type_position VARCHAR(50),
    alias VARCHAR(250),
    nom_ld VARCHAR(250),
    source_position VARCHAR(50),
    certification_commune BOOLEAN DEFAULT FALSE,

    -- FKs
    id_voie INTEGER NOT NULL,
    id_cad_parcelles INTEGER,
    id_code_postal INTEGER,

    CONSTRAINT fk_voie
        FOREIGN KEY (id_voie) REFERENCES voie(id),

    CONSTRAINT fk_code_postal
        FOREIGN KEY (id_code_postal) REFERENCES code_postal(id),

    CONSTRAINT fk_cad_parcelles
        FOREIGN KEY (id_cad_parcelles) REFERENCES parcelles(id)
);
