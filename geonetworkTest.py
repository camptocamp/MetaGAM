
import unittest
from unittest.mock import Mock
from geonetworkDate import getMetaDateGN

class TestGetMetaDateGN(unittest.TestCase):
    @patch('geonetworkDate.connexionGeonetwork')
    @patch('geonetworkDate.requests.get')
    def test_getMetaDateGN(self):
        # Préparer les données de test
        user = "TestCICD"
        password = "Git12345@"
        uuid = "6b37a124-1e66-468f-b295-32213a0a4de3"
        
        # Mock de la fonction connexionGeonetwork
        connexionGeonetwork = Mock()
        connexionGeonetwork.return_value = (True, "https://geonetworkt.grenoblealpesmetropole.fr/geonetwork", "test_token", {}, user, password, None)
        
        # Mock de la réponse de la requête
        response_mock = Mock()
        response_mock.status_code = 200
        response_mock.text = '''
            <root>
                <element>
                    <Date>2023-04-27</Date>
                </element>
            </root>
        '''
        
        # Mock de la fonction requests.get
        requests_get = Mock()
        requests_get.return_value = response_mock
        
        # Exécuter la fonction à tester
        date_publication = getMetaDateGN(user, password, uuid)
        
        # Vérifier les appels de fonctions
        connexionGeonetwork.assert_called_once_with(user, password)
        requests_get.assert_called_once_with(
            "https://geonetworkt.grenoblealpesmetropole.fr/geonetwork/srv/api/records/6b37a124-1e66-468f-b295-32213a0a4de3/formatters/xml?addSchemaLocation=false&increasePopularity=false&approved=false",
            headers={"Accept": "application/xml", "Content-Type": "application/xml"},
            cookies={"XSRF-TOKEN": "test_token"},
            auth=(user, password)
        )
        
        # Vérifier le résultat
        self.assertEqual(date_publication, "2023-04-27")

if __name__ == '__main__':
    unittest.main()
