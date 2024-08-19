
-- si problème de "couche principale"

UPDATE
    sit_hydre.gest_bdd_rel_objets_thematique
SET
    niveau = 1
WHERE
    objet_id =?
    AND thematique_id =?;