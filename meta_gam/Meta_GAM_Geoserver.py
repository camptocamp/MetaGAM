import requests

from qgis.core import QgsAbstractMetadataBase


GAM_GEOFLUX_URL = "https://geoflux.grenoblealpesmetropole.fr/geoserver"

HTTP_TIMEOUT = 30

LINK_NAMES = {
    "KML": "Format KML",
    "GeoJSON": "Format Geojson",
}

LINK_TYPES = {
    "WMS": "OGC-WMS Capabilities service (ver 1.3.0)",
    "KML": "WWW:DOWNLOAD-1.0-http--download",
    "GeoJSON": "WWW:DOWNLOAD-1.0-http--download",
}

LINK_FORMATS = {"GeoJSON": "application%2Fjson"}


def create_link(layer_schema, layer_name, link_type):
    link = QgsAbstractMetadataBase.Link()
    link.name = LINK_NAMES.get(link_type, layer_name)
    link.type = LINK_TYPES.get(link_type, "https")
    link.description = layer_name
    link.url = create_url(layer_schema, layer_name, link_type)
    link.format = link_type
    return link


def create_url(layer_schema, layer_name, link_type):
    if link_type == "WMS":
        return f"{GAM_GEOFLUX_URL}/{layer_schema}/ows?SERVICE=WMS&"
    output_format = LINK_FORMATS.get(link_type, link_type.lower())
    return (
        f"{GAM_GEOFLUX_URL}/{layer_schema}/ows?service=WFS&version=1.0.0&request=GetFeature"
        f"&typeName={layer_schema}%3A{layer_name}&outputFormat={output_format}"
    )


def check_link(link):
    params = {}
    if link.format == "WMS":
        params = {"request": "GetCapabilities"}
    response = requests.get(link.url, params=params, timeout=HTTP_TIMEOUT)
    return response.status_code == 200
