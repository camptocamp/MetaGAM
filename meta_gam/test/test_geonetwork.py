"""
test fonctionnel principal
"""
import unittest
from unittest.mock import patch
from nose.plugins.attrib import attr
from requests.structures import CaseInsensitiveDict
from ..Meta_GAM_Geonetwork import connexion_geonetwork, get_meta_date_gn


@patch(
    "meta_gam.Meta_GAM_Geonetwork.get_catalog",
    lambda: "https://geonetwork.grenoblealpesmetropole.fr/geonetwork",
)
class MyTestClass(unittest.TestCase):
    """
    TestCase structure
    """

    def setUp(self):
        """
        Initialisation des objets nécessaires pour le test
        """
        self.user = "TestCICD"
        self.password = "Git12345@"
        self.uuid = "26bc16bb-0a63-421d-8a07-c91ae7fbc8e7"

    def tearDown(self):
        """
        Nettoyage après le test si nécessaire
        """
        pass  # pylint: disable=unnecessary-pass

    @attr("onlineGN")
    def test_connexionGeonetwork(self):
        """
        Test de la connexion au GeoNetwork en ligne
        """
        result = connexion_geonetwork(self.user, self.password)

        # Assertions pour vérifier le comportement attendu
        self.assertEqual(len(result), 7)  # Vérifie le nombre de valeurs renvoyées
        self.assertTrue(
            result[0]
        )  # Vérifie que la connexion a réussi (result[0] est True)
        self.assertIsInstance(
            result[1], str
        )  # Vérifie que le deuxième élément est une chaîne de caractères
        self.assertIsInstance(
            result[2], str
        )  # Vérifie que le troisième élément est une chaîne de caractères
        self.assertIsInstance(
            result[3], CaseInsensitiveDict
        )  # Vérifie que le quatrième élément est un CaseInsensitiveDict
        self.assertIsInstance(
            result[4], str
        )  # Vérifie que le cinquième élément est une chaîne de caractères
        self.assertIsInstance(
            result[5], str
        )  # Vérifie que le sixième élément est une chaîne de caractères
        self.assertIsNone(result[6])  # Vérifie que le septième élément est None

    @attr("onlineGN")
    def test_getMetaDateGN(self):
        """
        Test d'accès à une ressource du Geonetwork en ligne
        """
        date_publication = get_meta_date_gn(self.user, self.password, self.uuid)
        self.assertIsNotNone(
            date_publication
        )  # Vérifier que la date de publication n'est pas None qui veut dire que la fiche existe


if __name__ == "__main__":
    unittest.main()
