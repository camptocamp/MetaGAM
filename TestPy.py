"""
Ce module contient une fonction pour compter le nombre d'entités dans une couche vectorielle.
"""
from qgis.core import QgsVectorLayer

def count_entities(layer: QgsVectorLayer) -> int:
    """
    Compte le nombre d'entités dans une couche vectorielle.

    Args:
        layer (QgsVectorLayer): La couche vectorielle à compter.

    Returns:
        int: Le nombre total d'entités dans la couche..
    """
    entity_count = 0

    if layer.isValid():
        entity_count = layer.featureCount()

    return entity_count
