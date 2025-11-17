-- 4.5 Requêtes avancées

-- 1) Procédure stockée pour insérer ou mettre à jour une adresse selon qu'elle existe déjà
CREATE OR REPLACE FUNCTION upsert_adresse(
    p_numero VARCHAR(10),
    p_rep VARCHAR(10),
    p_lon DOUBLE PRECISION,
    p_lat DOUBLE PRECISION,
    p_x DOUBLE PRECISION,
    p_y DOUBLE PRECISION,
    p_type_position VARCHAR(50),
    p_alias VARCHAR(250),
    p_nom_ld VARCHAR(250),
    p_source_position VARCHAR(50),
    p_certification_commune BOOLEAN,
    p_id_voie INTEGER,
    p_id_cad_parcelles INTEGER,
    p_id_code_postal INTEGER
)
RETURNS INTEGER AS $$
DECLARE
    v_adresse_id INTEGER;
BEGIN
    -- Rechercher si l'adresse existe déjà (même numéro + voie + code postal)
    SELECT id INTO v_adresse_id
    FROM adresse
    WHERE numero = p_numero
      AND (rep = p_rep OR (rep IS NULL AND p_rep IS NULL))
      AND id_voie = p_id_voie
      AND (id_code_postal = p_id_code_postal OR (id_code_postal IS NULL AND p_id_code_postal IS NULL))
    LIMIT 1;

    IF v_adresse_id IS NOT NULL THEN
        -- L'adresse existe : mise à jour
        UPDATE adresse
        SET
            rep = p_rep,
            lon = p_lon,
            lat = p_lat,
            x = p_x,
            y = p_y,
            type_position = p_type_position,
            alias = p_alias,
            nom_ld = p_nom_ld,
            source_position = p_source_position,
            certification_commune = p_certification_commune,
            id_cad_parcelles = p_id_cad_parcelles
        WHERE id = v_adresse_id;
        
        RAISE NOTICE 'Adresse mise à jour avec ID: %', v_adresse_id;
    ELSE
        -- L'adresse n'existe pas : insertion
        INSERT INTO adresse (
            numero, rep, lon, lat, x, y, type_position,
            alias, nom_ld, source_position, certification_commune,
            id_voie, id_cad_parcelles, id_code_postal
        )
        VALUES (
            p_numero, p_rep, p_lon, p_lat, p_x, p_y, p_type_position,
            p_alias, p_nom_ld, p_source_position, p_certification_commune,
            p_id_voie, p_id_cad_parcelles, p_id_code_postal
        )
        RETURNING id INTO v_adresse_id;
        
        RAISE NOTICE 'Nouvelle adresse insérée avec ID: %', v_adresse_id;
    END IF;

    RETURN v_adresse_id;
END;
$$ LANGUAGE plpgsql;


-- 2) Trigger qui vérifie, avant insertion, que les coordonnées GPS sont valides 
--    et que le code postal est bien au format 5 chiffres
CREATE OR REPLACE FUNCTION validate_adresse_data()
RETURNS TRIGGER AS $$
DECLARE
    v_code_postal_value CHAR(5);
BEGIN
    -- Validation des coordonnées GPS (si renseignées)
    IF NEW.lat IS NOT NULL THEN
        IF NEW.lat < -90 OR NEW.lat > 90 THEN
            RAISE EXCEPTION 'Latitude invalide: % (doit être entre -90 et 90)', NEW.lat;
        END IF;
    END IF;

    IF NEW.lon IS NOT NULL THEN
        IF NEW.lon < -180 OR NEW.lon > 180 THEN
            RAISE EXCEPTION 'Longitude invalide: % (doit être entre -180 et 180)', NEW.lon;
        END IF;
    END IF;

    -- Validation du format du code postal (si renseigné)
    IF NEW.id_code_postal IS NOT NULL THEN
        SELECT code_postal INTO v_code_postal_value
        FROM code_postal
        WHERE id = NEW.id_code_postal;

        IF v_code_postal_value IS NOT NULL THEN
            IF v_code_postal_value !~ '^[0-9]{5}$' THEN
                RAISE EXCEPTION 'Code postal invalide: % (doit contenir exactement 5 chiffres)', v_code_postal_value;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Création du trigger sur la table adresse
DROP TRIGGER IF EXISTS trigger_validate_adresse ON adresse;
CREATE TRIGGER trigger_validate_adresse
    BEFORE INSERT OR UPDATE ON adresse
    FOR EACH ROW
    EXECUTE FUNCTION validate_adresse_data();

-- Validation également sur la table code_postal
CREATE OR REPLACE FUNCTION validate_code_postal_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.code_postal !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION 'Code postal invalide: % (doit contenir exactement 5 chiffres)', NEW.code_postal;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_code_postal ON code_postal;
CREATE TRIGGER trigger_validate_code_postal
    BEFORE INSERT OR UPDATE ON code_postal
    FOR EACH ROW
    EXECUTE FUNCTION validate_code_postal_format();


-- 3) Ajouter automatiquement une date de création / mise à jour à chaque modification via trigger

-- ajouter les colonnes de dates aux tables
ALTER TABLE adresse
ADD COLUMN IF NOT EXISTS date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE commune
ADD COLUMN IF NOT EXISTS date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE voie
ADD COLUMN IF NOT EXISTS date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE code_postal
ADD COLUMN IF NOT EXISTS date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE parcelles
ADD COLUMN IF NOT EXISTS date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Fonction générique pour mettre à jour la date de modification
CREATE OR REPLACE FUNCTION update_date_modification()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_modification = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour chaque table
DROP TRIGGER IF EXISTS trigger_adresse_date_modification ON adresse;
CREATE TRIGGER trigger_adresse_date_modification
    BEFORE UPDATE ON adresse
    FOR EACH ROW
    EXECUTE FUNCTION update_date_modification();

DROP TRIGGER IF EXISTS trigger_commune_date_modification ON commune;
CREATE TRIGGER trigger_commune_date_modification
    BEFORE UPDATE ON commune
    FOR EACH ROW
    EXECUTE FUNCTION update_date_modification();

DROP TRIGGER IF EXISTS trigger_voie_date_modification ON voie;
CREATE TRIGGER trigger_voie_date_modification
    BEFORE UPDATE ON voie
    FOR EACH ROW
    EXECUTE FUNCTION update_date_modification();

DROP TRIGGER IF EXISTS trigger_code_postal_date_modification ON code_postal;
CREATE TRIGGER trigger_code_postal_date_modification
    BEFORE UPDATE ON code_postal
    FOR EACH ROW
    EXECUTE FUNCTION update_date_modification();

DROP TRIGGER IF EXISTS trigger_parcelles_date_modification ON parcelles;
CREATE TRIGGER trigger_parcelles_date_modification
    BEFORE UPDATE ON parcelles
    FOR EACH ROW
    EXECUTE FUNCTION update_date_modification();
