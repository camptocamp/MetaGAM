"""
test fonctionnel principal
"""
import unittest
import requests_mock
from tempfile import NamedTemporaryFile
from ..Meta_GAM_Geonetwork import MetaGamGeonetwork
from unittest.mock import patch, PropertyMock
from nose.plugins.attrib import attr


class MockedTestClass(unittest.TestCase):
    def test_mocked_post(self):
        with requests_mock.Mocker() as m:
            m.get(
                "http://geonetwork:8080/geonetwork/srv/api/me",
                json={"profile": "Admin"},
            )
            m.post(
                "http://geonetwork:8080/geonetwork/srv/api/records", json={"OK": True}
            )
            mgGN = MetaGamGeonetwork()
            mgGN.connect("user", "user")
            with NamedTemporaryFile() as f:
                resp = mgGN.post_meta_gn(f.name)
                assert resp == {"status_code": 200, "detail": {"OK": True}}

    def test_mocked_post_no_json(self):
        with requests_mock.Mocker() as m:
            m.get(
                "http://geonetwork:8080/geonetwork/srv/api/me",
                json={"profile": "Admin"},
            )
            m.post(
                "http://geonetwork:8080/geonetwork/srv/api/records", content=b"not OK"
            )
            mgGN = MetaGamGeonetwork()
            mgGN.connect("user", "user")
            with NamedTemporaryFile() as f:
                resp = mgGN.post_meta_gn(f.name)
            assert resp == {"status_code": 200, "detail": "not OK"}


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
        self.patch = patch(
            "meta_gam.Meta_GAM_Geonetwork.MetaGamGeonetwork.CATALOG",
            new_callable=PropertyMock,
        )
        self.mock_gn = self.patch.__enter__()
        self.mock_gn.return_value = (
            "https://geonetwork.grenoblealpesmetropole.fr/geonetwork"
        )
        self.mgGN = MetaGamGeonetwork()
        self.mgGN.connect(self.user, self.password)

    def tearDown(self):
        """
        Nettoyage après le test si nécessaire
        """
        self.mgGN.close()
        self.patch.__exit__(None, None, None)

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
