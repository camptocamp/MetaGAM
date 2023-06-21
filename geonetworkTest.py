import unittest
from geonetworkDate import connexionGeonetwork
from requests.structures import CaseInsensitiveDict

class MyTestClass(unittest.TestCase):
    def setUp(self):
        # Initialisation des objets nécessaires pour le test
        self.user = "TestCICD"
        self.password = "Git12345@"

    def tearDown(self):
        # Nettoyage après le test si nécessaire
        pass

    def test_connexionGeonetwork(self):
        # Appel de la fonction à tester
        result = connexionGeonetwork(self.user, self.password)

        # Assertions pour vérifier le comportement attendu
        self.assertEqual(len(result), 7)  # Vérifie le nombre de valeurs renvoyées
        self.assertTrue(result[0])  # Vérifie que la connexion a réussi (result[0] est True)
        self.assertIsInstance(result[1], str)  # Vérifie que le deuxième élément est une chaîne de caractères
        self.assertIsInstance(result[2], str)  # Vérifie que le troisième élément est une chaîne de caractères
        self.assertTrue(isinstance(result[3], CaseInsensitiveDict)) # Vérifie que le quatrième élément est un CaseInsensitiveDict
        self.assertIsInstance(result[4], str)  # Vérifie que le cinquième élément est une chaîne de caractères
        self.assertIsInstance(result[5], str)  # Vérifie que le sixième élément est une chaîne de caractères
        self.assertIsNone(result[6])  # Vérifie que le septième élément est None

if __name__ == '__main__':
    unittest.main()

