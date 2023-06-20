import os
from qgis.core import QgsProject
from qgis.core import *
import re
from PyQt5 import QtWidgets
from qgis.PyQt import *
from qgis.PyQt import QtWidgets, QtCore, QtGui
from qgis.PyQt.QtWidgets import *
import requests
from requests.structures import CaseInsensitiveDict
from pandas import *
from qgis.core import QgsVectorFileWriter
import json
import xml.etree.ElementTree as ET
def getMetaDateGN(user,password,uuid):
    """_summary_

    Cette fonction récupere la date de publication pour une fiche donnée .Elle utilise la fonction connexionGeonetwork pour établir une connexion à l'instance de GeoNetwork en fournissant les informations d'authentification de l'utilisateur.

    Args:
        user (str): nom d'utilisateur saisie dans le plugin.
        password (str): mot de pass saisie dans le plugin.
        uuid (str): identifiant fiche de métadonnées.
    """
    connexionGN=connexionGeonetwork(user,password)
    userGroup = connexionGN[6]
    headersGN = connexionGN[3]
    headersGN["Accept"] = "application/xml"
    headersGN["Content-Type"] = "application/xml"
    if userGroup == None:
        response = requests.get(connexionGN[1]+"/srv/api/records/"+uuid+"/formatters/xml?addSchemaLocation=false&increasePopularity=false&approved=false", 
                headers=headersGN,
                cookies = {"XSRF-TOKEN": connexionGN[2]},
                auth=(connexionGN[4],connexionGN[5]))
    if response.status_code == 200:
        reponse_xml = response.text
        root = ET.fromstring(reponse_xml)
        date_element = root.find(".//{http://www.isotc211.org/2005/gco}Date")
        date_publication = date_element.text
        return(date_publication)
