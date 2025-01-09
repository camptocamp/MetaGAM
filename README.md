# METAGAM

Plugin QGIS "maison" qui permet de transférer les métadonnées au format XML, depuis des informations en base de données (`sit_hydre.gest_bdd_rel_objets_thematique`) et/ou dans des projets QGIS spécifiques (remplissage de l'onglet "métadonnées" dans les propriétés de la couche), vers un geonetwork en utilisant l'API.

# Vérification pre-commit

pour garantir la qualité du code source, certaines vérifications sont effectuées systématiquement avant chaque commit:

* formattage correct des json, yaml, requirements, etc.
* formattage forcé des fichiers python suivant le standard "black"
* correction des variables, imports, etc avec autoflake

Lors de la commande `git commit` le 'hook' est déclenché et effectue toutes les vérifications.

On peut désactiver cette vérification pour un commit avec la commande `git commit -n` (--no-verify). Si par exemple l'installation des outils n'est pas encore opérationnelle (exécutable pre-commit, docker, etc.) et le commit échoue.

# Lancement docker

```
docker compose up
```
