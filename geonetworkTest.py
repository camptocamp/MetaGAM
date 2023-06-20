import unittest
from unittest.mock import patch
from my_module import getMetaDateGN

class TestGetMetaDateGN(unittest.TestCase):

    @patch('my_module.connexionGeonetwork')
    @patch('my_module.requests.get')
    @patch('my_module.ET.fromstring')
    def test_getMetaDateGN(self, mock_fromstring, mock_get, mock_connexionGeonetwork):
        # Données de test
        user = "test_user"
        password = "test_password"
        uuid = "test_uuid"
        xml_response = '''
            <?xml version="1.0" encoding="UTF-8"?>
            <root>
                <gco:Date xmlns:gco="http://www.isotc211.org/2005/gco">2021-06-20</gco:Date>
            </root>
        '''
        
        # Mock des fonctions dépendantes
        mock_connexionGeonetwork.return_value = (None, "http://example.com", "token", {}, "username", "password", None)
        mock_get.return_value.status_code = 200
        mock_get.return_value.text = xml_response
        mock_fromstring.return_value.find.return_value.text = "2021-06-20"

        # Exécution de la fonction à tester
        result = getMetaDateGN(user, password, uuid)

        # Assertion
        self.assertEqual(result, "2021-06-20")

if __name__ == '__main__':
    unittest.main()
