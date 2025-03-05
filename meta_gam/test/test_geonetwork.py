"""
test fonctionnel principal
"""
import unittest
from ..Meta_GAM_Geonetwork import MetaGamGeonetwork
from unittest.mock import patch
from nose.plugins.attrib import attr


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
        self.mgGN = MetaGamGeonetwork()
        self.mgGN.connect(self.user, self.password)

    def tearDown(self):
        """
        Nettoyage après le test si nécessaire
        """
        self.mgGN.close()

    @attr("onlineGN")
    def test_connexionGeonetwork(self):
        """
        Test de la connexion au GeoNetwork en ligne
        """

        # Assertions pour vérifier le comportement attendu
        self.assertTrue(self.mgGN.connected)  # Vérifie que la connexion est valide
        self.assertIsNone(self.mgGN.group)  # Vérifie que le septième élément est None

    @attr("onlineGN")
    def test_getMetaDateGN(self):
        """
        Test d'accès à une ressource du Geonetwork en ligne
        """
        date_publication = self.mgGN.get_meta_date_gn(self.uuid)
        self.assertIsNotNone(
            date_publication
        )  # Vérifier que la date de publication n'est pas None qui veut dire que la fiche existe


if __name__ == "__main__":
    unittest.main()
