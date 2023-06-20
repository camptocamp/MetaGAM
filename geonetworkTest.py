import unittest
from geonetworkDate import getMetaDateGN, connexionGeonetwork

class TestGetMetaDateGN(unittest.TestCase):

    def test_getMetaDateGN(self):
        user = "TestCICD"
        password = "Git12345@"
        uuid = "6b37a124-1e66-468f-b295-32213a0a4de3"

        def fake_connexionGeonetwork(user, password):
            return (True, "https://geonetworkt.grenoblealpesmetropole.fr/geonetwork", "fake_token", {}, user, password, None)

        original_connexionGeonetwork = connexionGeonetwork
        connexionGeonetwork = fake_connexionGeonetwork

        date_publication = getMetaDateGN(user, password, uuid)

        connexionGeonetwork = original_connexionGeonetwork

        self.assertEqual(date_publication, "27-04-2023")

if __name__ == '__main__':
    unittest.main()

