
# installation et configuration complète de dbeaver avec psql
1er:
- installer psql
2eme:
- installer dbeaver (version community)

# importation du CSV dans dbeaver
1ere étape:
- créer une table "brut"
- faire clic droit sur la table "brut" puis "import data"
- choisir le fichier csv
- spécifier les types des colonnes
- cliquer sur "finish"

# Création du dictionnaire de données dans google sheet
Pour une meilleure lisibilité, "ouvrir l'appercu" du readme

| Code | Libellé | Type | Taille | E/C | Règle de calcul | Règle de gestion | Document |
|------|---------|------|--------|-----|-----------------|------------------|----------|
| id | Identifiant unique de l'adresse | AN | 50 | E | - | Unique, auto-incrémenté, format: {code_insee}{id_fantoir}{numero} | Base Adresse Nationale |
| id_fantoir | Identifiant FANTOIR de la voie | AN | 10 | E | - | Format: {code_insee}_{code_voie}, peut être vide | Base Adresse Nationale |
| numero | Numéro dans la voie | N | 5 | E | - | Peut être vide pour certaines adresses | Base Adresse Nationale |
| rep | Indice de répétition | A | 3 | E | - | Valeurs possibles: bis, ter, quater, etc. Peut être vide | Base Adresse Nationale |
| nom_voie | Nom de la voie | A | 255 | E | - | Obligatoire | Base Adresse Nationale |
| code_postal | Code postal | N | 5 | E | - | Obligatoire, format: 5 chiffres | Base Adresse Nationale |
| code_insee | Code INSEE de la commune | N | 5 | E | - | Obligatoire, identifiant unique de la commune | Base Adresse Nationale |
| nom_commune | Nom officiel de la commune | A | 100 | E | - | Obligatoire | Base Adresse Nationale |
| code_insee_ancienne_commune | Code INSEE de l'ancienne commune | N | 5 | E | - | Facultatif, utilisé en cas de fusion de communes | Base Adresse Nationale |
| nom_ancienne_commune | Nom de l'ancienne commune | A | 100 | E | - | Facultatif, renseigné si fusion communale | Base Adresse Nationale |
| x | Coordonnée X (Lambert 93) | N | 10,2 | C | Projection Lambert 93 | Coordonnée géographique en mètres | Base Adresse Nationale |
| y | Coordonnée Y (Lambert 93) | N | 10,2 | C | Projection Lambert 93 | Coordonnée géographique en mètres | Base Adresse Nationale |
| lon | Longitude (WGS84) | N | 10,6 | C | Conversion depuis Lambert 93 | Coordonnée géographique en degrés décimaux | Base Adresse Nationale |
| lat | Latitude (WGS84) | N | 10,6 | C | Conversion depuis Lambert 93 | Coordonnée géographique en degrés décimaux | Base Adresse Nationale |
| type_position | Type de positionnement | A | 50 | E | - | Valeurs: entrée, délivrance postale, bâtiment, cage d'escalier, logement, parcelle, segment, service technique | Base Adresse Nationale |
| alias | Nom(s) alternatif(s) de la voie | A | 255 | E | - | Facultatif, anciens noms ou noms usuels | Base Adresse Nationale |
| nom_ld | Nom du lieu-dit | A | 100 | E | - | Facultatif, pour les adresses en lieu-dit | Base Adresse Nationale |
| libelle_acheminement | Libellé d'acheminement postal | A | 100 | E | - | Nom de la commune pour l'acheminement du courrier | Base Adresse Nationale |
| nom_afnor | Nom normalisé AFNOR de la voie | A | 255 | E | - | Normalisation selon règles AFNOR | Base Adresse Nationale |
| source_position | Source du positionnement | A | 50 | E | - | Valeurs: commune, IGN, La Poste, cadastre, etc. | Base Adresse Nationale |
| source_nom_voie | Source du nom de voie | A | 50 | E | - | Valeurs: commune, IGN, La Poste, cadastre, etc. | Base Adresse Nationale |
| certification_commune | Certification par la commune | N | 1 | E | - | 0 = non certifié, 1 = certifié par la commune | Base Adresse Nationale |
| cad_parcelles | Références cadastrales | AN | 255 | E | - | Format: {code_insee}{préfixe}{section}{numéro}, peut contenir plusieurs parcelles séparées par des virgules | Base Adresse Nationale |


# création du merise
# MCD (Modèle Conceptuel de Données)
  1. Entités et justifications
  - Commune : Représente les communes avec leur code INSEE et gestion des fusions (anciennes communes)
  - Voie : Identifiée par FANTOIR (fichier national des voies), contient les noms normalisés (AFNOR)
  - Adresse : Point central du modèle, contient les coordonnées géographiques (lon/lat, x/y) et métadonnées de qualité
  - Code Postal : Entité séparée car un même code postal peut couvrir plusieurs adresses
  - Parcelles : Référence cadastrale liée optionnellement aux adresses

2. Relations et cardinalités clés
  - Voie ↔ Commune (1,1)-(1,n) : Chaque voie appartient à UNE seule commune, une commune peut avoir plusieurs voies
  - Voie ↔ Adresse (0,n)-(1,1) : Une voie peut avoir plusieurs adresses (numéros), chaque adresse est sur UNE voie
  - Adresse ↔ Code Postal (0,1)-(1,n) : Cardinalité (0,1) car certaines adresses peuvent ne pas avoir de code postal assigné
  - Adresse ↔ Parcelles (0,1)-(0,n) : Relation optionnelle, toutes les adresses n'ont pas forcément de parcelle cadastrale

  4. Choix de normalisation
  - Séparation du code postal en entité propre pour éviter la redondance (un code postal est partagé par plusieurs adresses)
  - Séparation des parcelles pour gérer les cas où l'information cadastrale n'est pas disponible
  - Conservation des coordonnées multiples (lon/lat ET x/y) car différents systèmes de projection géographique

# Passage du MCD au MLD (Modèle Logique de Données)

1. Placement des clés étrangères selon les cardinalités

  Table VOIE
  id_commune INTEGER NOT NULL → FOREIGN KEY commune(id)
  - Justification : Cardinalité (1,1) côté Voie → la FK est placée dans voie
  - NOT NULL car une voie doit obligatoirement appartenir à une commune

  Table ADRESSE (table centrale, reçoit 3 FKs)
  id_voie INTEGER NOT NULL → FOREIGN KEY voie(id)
  - Justification : Cardinalité (1,1) côté Adresse → FK dans adresse
  - NOT NULL car une adresse doit obligatoirement être sur une voie

  id_code_postal INTEGER → FOREIGN KEY code_postal(id)
  - Justification : Cardinalité (0,1) côté Adresse → FK nullable dans adresse
  - Nullable car certaines adresses peuvent ne pas avoir de code postal

  id_cad_parcelles INTEGER → FOREIGN KEY parcelles(id)
  - Justification : Cardinalité (0,1) côté Adresse → FK nullable dans adresse
  - Nullable car toutes les adresses n'ont pas forcément de parcelle cadastrale

# Passage du MLD au MPD (Modèle Physique de Données)
Exemples de typage :

  -- Clés primaires auto-incrémentées
  id SERIAL PRIMARY KEY

  -- Codes à taille fixe
  code_postal CHAR(5)

  -- Textes de longueur variable
  nom_voie VARCHAR(255)
  nom_commune VARCHAR(100)

  -- Coordonnées géographiques avec haute précision
  lon DOUBLE PRECISION
  lat DOUBLE PRECISION

  -- Valeurs booléennes
  certification_commune BOOLEAN DEFAULT FALSE

  Contraintes d'intégrité :

  -- Unicité métier
  code_insee VARCHAR(5) UNIQUE NOT NULL

  -- Clés étrangères
  id_commune INTEGER NOT NULL,
  CONSTRAINT fk_commune FOREIGN KEY (id_commune) REFERENCES commune(id)

  -- Clés étrangères optionnelles (nullable)
  id_code_postal INTEGER,
  CONSTRAINT fk_code_postal FOREIGN KEY (id_code_postal) REFERENCES code_postal(id)

# insérer les données de brut dans les tables
exemple avec "commune" et "code_postal"
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

# exemples de requêtes

1. Lister toutes les communes distinctes présentes (issues du fichier)
SELECT
    code_insee,
    nom_commune,
    libelle_acheminement,
    code_insee_ancienne_commune,
    nom_ancienne_commune
FROM commune
ORDER BY
    nom_commune;

2. Compter le nombre d’adresses par commune
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

# observer les performances

1. savoir le temps d'execution d'une ou plusieurs requêtes
- mettre le mot clé "EXPLAIN ANALYZE" au début de la requête puis tester :
Gather Merge  (cost=6755.11..6833.26 rows=671 width=54) (actual time=47.047..51.206 rows=349.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=4526
  ->  Sort  (cost=5755.08..5755.78 rows=280 width=54) (actual time=20.908..20.916 rows=116.33 loops=3)
        Sort Key: voie.nom_voie, adresse.numero, adresse.rep
        Sort Method: quicksort  Memory: 48kB
        Buffers: shared hit=4526
        Worker 0:  Sort Method: quicksort  Memory: 25kB
        Worker 1:  Sort Method: quicksort  Memory: 25kB
        ->  Hash Join  (cost=619.84..5743.70 rows=280 width=54) (actual time=12.718..20.701 rows=116.33 loops=3)
              Hash Cond: (adresse.id_voie = voie.id)
              Buffers: shared hit=4510
              ->  Parallel Seq Scan on adresse  (cost=0.00..4709.76 rows=109676 width=31) (actual time=0.010..13.150 rows=87740.67 loops=3)
                    Buffers: shared hit=3613
              ->  Hash  (cost=619.04..619.04 rows=64 width=35) (actual time=3.415..3.418 rows=56.00 loops=3)
                    Buckets: 1024  Batches: 1  Memory Usage: 12kB
                    Buffers: shared hit=897
                    ->  Hash Join  (cost=8.91..619.04 rows=64 width=35) (actual time=0.389..3.406 rows=56.00 loops=3)
                          Hash Cond: (voie.id_commune = commune.id)
                          Buffers: shared hit=897
                          ->  Seq Scan on voie  (cost=0.00..544.04 rows=24904 width=27) (actual time=0.123..2.188 rows=24904.00 loops=3)
                                Buffers: shared hit=885
                          ->  Hash  (cost=8.90..8.90 rows=1 width=16) (actual time=0.133..0.134 rows=1.00 loops=3)
                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                Buffers: shared hit=12
                                ->  Seq Scan on commune  (cost=0.00..8.90 rows=1 width=16) (actual time=0.105..0.126 rows=1.00 loops=3)
                                      Filter: ((nom_commune)::text = 'Argis'::text)
                                      Rows Removed by Filter: 391
                                      Buffers: shared hit=12
Planning:
  Buffers: shared hit=39 dirtied=2
Planning Time: 1.485 ms
Execution Time: 51.288 ms

2. Pour accélérer les requêtes, créer des index.sql sur les tables principales pour y mettre les index:
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

2. éxécuter le script index.sql puis relancer la requête

voir le résultat qui est : 
"Sort  (cost=145.22..146.90 rows=671 width=54) (actual time=0.521..0.528 rows=349.00 loops=1)
  Sort Key: voie.nom_voie, adresse.numero, adresse.rep
  Sort Method: quicksort  Memory: 48kB
  Buffers: shared hit=239
  ->  Nested Loop  (cost=0.98..113.72 rows=671 width=54) (actual time=0.020..0.154 rows=349.00 loops=1)
        Buffers: shared hit=239
        ->  Nested Loop  (cost=0.56..18.36 rows=64 width=35) (actual time=0.016..0.025 rows=56.00 loops=1)
              Buffers: shared hit=6
              ->  Index Scan using idx_commune_nom_commune on commune  (cost=0.27..8.29 rows=1 width=16) (actual time=0.013..0.013 rows=1.00 loops=1)
                    Index Cond: ((nom_commune)::text = 'Argis'::text)
                    Index Searches: 1
                    Buffers: shared hit=3
              ->  Index Scan using idx_voie_id_commune on voie  (cost=0.29..9.43 rows=64 width=27) (actual time=0.002..0.008 rows=56.00 loops=1)
                    Index Cond: (id_commune = commune.id)
                    Index Searches: 1
                    Buffers: shared hit=3
        ->  Index Scan using idx_adresse_id_voie on adresse  (cost=0.42..1.33 rows=16 width=31) (actual time=0.001..0.002 rows=6.23 loops=56)
              Index Cond: (id_voie = voie.id)
              Index Searches: 56
              Buffers: shared hit=233
Planning:
  Buffers: shared hit=27
Planning Time: 0.321 ms
Execution Time: 0.557 ms"

3. résultat :

## Comparaison des performances (AVEC vs SANS index)

### SANS index (requête initiale)
- **Temps d'exécution : 51.288 ms**
- **Temps de planification : 1.485 ms**
- **Méthode utilisée :** Gather Merge avec parallélisation (2 workers)
- **Buffers partagés :** 4526 hits
- **Type de scan :** Sequential Scan (parcours complet des tables)

### AVEC index (après création des index)
- **Temps d'exécution : 0.557 ms**
- **Temps de planification : 0.321 ms**
- **Méthode utilisée :** Nested Loop avec Index Scan
- **Buffers partagés :** 239 hits
- **Type de scan :** Index Scan (accès direct via index)

### Amélioration constatée
- **Gain de performance : x92 fois plus rapide** (de 51.288 ms à 0.557 ms)
- **Réduction de la planification : x4.6 fois plus rapide** (de 1.485 ms à 0.321 ms)
- **Réduction des accès disque : 95% de buffers en moins** (de 4526 à 239)
- **Changement de stratégie :** Le planificateur PostgreSQL privilégie désormais les Index Scan au lieu des Sequential Scan, ce qui est beaucoup plus efficace pour les requêtes avec filtres et jointures.

### Conclusion
Les index ont permis une amélioration spectaculaire des performances en permettant à PostgreSQL d'accéder directement aux données pertinentes plutôt que de parcourir l'intégralité des tables. Cette optimisation est particulièrement visible sur :
- Les jointures (idx_voie_id_commune, idx_adresse_id_voie)
- Les filtres sur les noms (idx_commune_nom_commune)

