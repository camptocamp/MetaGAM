# METAGAM

Plugin QGIS "maison" qui permet de transférer les métadonnées au format XML, depuis des informations en base de données (`sit_hydre.gest_bdd_rel_objets_thematique`) et/ou dans des projets QGIS spécifiques (remplissage de l'onglet "métadonnées" dans les propriétés de la couche), vers un geonetwork en utilisant l'API.

# Installation

## Configuration

la connexion DB s'appuie sur le service bd_prod. Il faut donc définir ce service dans le fichier `pg_service.conf`

Ce fichier aura le contenu suivant:
```
[bd_prod]
host=db_server.internal.com
port=5432
#sslmode=require
user=geonetwork
password=geonetwork
dbname=sig
```

On peut inclure ou non le mot de passe dans ce fichier. Si le mot de passe se trouve dans le fichier de définition de service, le bouton "Auto-Remplir" ne demande pas de saisie de mot de passe de BD. Si le mot de passe n'est pas défini, il faut le saisir une fois.

# Développement

Dans cette partie, il y a quelques conseils pour le développement sous linux et docker

## Vérification pre-commit automatique au moment du commit

pour garantir la qualité du code source, certaines vérifications sont effectuées systématiquement avant chaque commit:

* formattage correct des json, yaml, requirements, etc.
* formattage forcé des fichiers python suivant le standard "black"
* correction des variables, imports, etc avec autoflake

Lors de la commande `git commit` le 'hook' est déclenché et effectue toutes les vérifications.

On peut désactiver cette vérification pour un commit avec la commande `git commit -n` (--no-verify). Si par exemple l'installation des outils n'est pas encore opérationnelle (exécutable pre-commit, docker, etc.) et le commit échoue.

## vérification pylint

test plus complet, avec un contexte non réalisable avec pylint:
```
docker compose run --rm -w /app/meta_gam qgis pylint .
```
- Par rapport à PEP8, la longuer de ligne est autorisée à 120 charactères.
- Les retours à la ligne seront autorisés selon le style black (et PEP8) plutot que le W503 de PEP8
  => on met un opérateur binaire juste après le retour à la ligne

Pour vérifier expressément la conformité des noms de variable, on peut activer (--enable) certains check pylint:

Exemple pour le check du snake_case pur:
```
docker compose run --rm -w /app/meta_gam qgis pylint -e invalid-name .
```

## Tests

par simplicité les tests dont appelés dans un environnement docker par:

```
docker compose run --rm -w /app/meta_gam qgis make test
```

Actuellement, il n'y a pas de runner dédié metagam en CI, donc ces tests doivent être effectués en local.


# Lancement docker

```
docker compose up
```

Au premier démarrage, geonetwork met un certain temps pour s'initialiser, il faut rester patient.

# Configuration QGIS

## Créer la connexion à la DB

Pour utiliser la docker compo de développement, il faut créer une connextion à la base de données dev.

- Aller dans Couche->Gestionnaire des sources de données
- Sélectionner PostgreSQL
- Cliquer sur Nouveau

Nom: DB (sans importance)
Service: bd_prod (ce service est pré-renseigné dans le docker container via le fichier `pg_service.conf`

Tester puis OK

Il est désormais possible d'ouvrir des couches dans DB->urba_plui_public

## Activer plugin

Les volumes de la compo docker ont déjà rendu accessible le code source du plugin dans le bon dossier.

Il suffit maintenant d'activer le plugin:
Extensions ->Installer/Gérer les extensions
Aller dans l'onglet Installées
Cocher MetaGAM

Maintenant les 2 icones MetaGAM devraient apparaitre dans la barre d'outils

## Utilisation plugin

Workflow pour tester le bon fonctionnement du plugin:

- Rajouter des couches depuis le schéma urba_plui_public
- Ouvrir le plugin
- Auto-Remplir les métadonnées
- mot de passe "geonetwork"
- compléter des métadonnées
- Cliquer sur le bouton Sauvegarder les modifications
- Cocher des métadonnées à publier
- Aller sur l'onglet "Pulication Geonetwork"
  - Nom-utilisateur: admin
  - Mot de pass: admin
  - Cliquer sur Connexion
- En cas d'absence d'erreur cliquer sur Envoi

## Consultation GeoNetwork

Par défaut, le portail geonetwork est accessible en local à l'adresse: http://localhost:8080/geonetwork
Les métadonnées exporteées au préalable devraient maintenant être accessibles dans le catalogue GeoNetwork. Y compris une icone et l'étendue de la couche.
