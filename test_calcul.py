import unittest
from qgis.core import QgsVectorLayer, QgsFeature
from TestPy import count_entities

class CountEntitiesTest(unittest.TestCase):
    def test_count_entities(self):
        # Crée une couche vectorielle de test avec 3 entités
        layer = QgsVectorLayer("Point?field=id:integer", "test_layer", "memory")
        layer.startEditing()
        for i in range(3):
            layer.addFeature(QgsFeature())
        layer.commitChanges()

        # Vérifie le nombre d'entités comptées
        result = count_entities(layer)
        self.assertEqual(result, 3)

if __name__ == '__main__':
    unittest.main()
