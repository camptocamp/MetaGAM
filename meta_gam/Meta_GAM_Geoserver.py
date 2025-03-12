import requests
from lxml import etree

from qgis.core import QgsAbstractMetadataBase


GAM_GEOFLUX_URL = "https://geoflux.grenoblealpesmetropole.fr/geoserver"

HTTP_TIMEOUT = 30

LINK_NAMES = {
    "KML": "Format KML",
    "GeoJSON": "Format Geojson",
}

LINK_TYPES = {
    "WMS": "OGC:WMS",
    "WFS": "OGC:WFS",
    "KML": "WWW:DOWNLOAD-1.0-http--download",
    "GeoJSON": "WWW:DOWNLOAD-1.0-http--download",
}

LINK_FORMATS = {"GeoJSON": "application%2Fjson"}


class GSLayerNotFound(Exception):
    def __init__(self, msg):
        super().__init__()
        self.msg = msg


def create_link(layer_schema, layer_name, link_type):
    link = QgsAbstractMetadataBase.Link()
    link.name = LINK_NAMES.get(link_type, layer_name)
    if link_type == "WFS":
        link.name = f"{layer_schema}:{layer_name}"
    link.type = LINK_TYPES.get(link_type, "https")
    link.description = layer_name
    link.url = create_url(layer_schema, layer_name, link_type)
    link.format = link_type
    return link


def create_url(layer_schema, layer_name, link_type):
    if link_type in ["WMS", "WFS"]:
        return f"{GAM_GEOFLUX_URL}/{layer_schema}/ows"
    output_format = LINK_FORMATS.get(link_type, link_type.lower())
    return (
        f"{GAM_GEOFLUX_URL}/{layer_schema}/ows?service=WFS&version=1.0.0&request=GetFeature"
        f"&typeName={layer_schema}%3A{layer_name}&outputFormat={output_format}"
    )


CAPABILITIES_PATTERNS = {
    "WMS": "Layer/Layer",
    "WFS": "FeatureType",
}


def check_link(link):
    if link.format in ["WMS", "WFS"]:
        params = {"request": "GetCapabilities", "service": link.format}
        try:
            response = requests.get(link.url, params=params, timeout=HTTP_TIMEOUT)
        except requests.RequestException:
            raise GSLayerNotFound(f"No response from {link.url}")
        if response.status_code == 200:
            try:
                capabilities = etree.fromstring(response.content)
                capabilities_pattern = CAPABILITIES_PATTERNS[link.format]
                if any(
                    el
                    for el in capabilities.iterfind(
                        f".//{capabilities_pattern}",
                        capabilities.nsmap,
                    )
                    if link.name in el.find("Name", capabilities.nsmap).text
                ):
                    return
                raise GSLayerNotFound(f"No layer {link.name} in {link.url}")
            except etree.LxmlError:
                pass
        raise GSLayerNotFound(f"No layer {link.name} from {link.url}")

    response = requests.get(link.url, timeout=HTTP_TIMEOUT)
    if response.status_code == 200:
        if "text/xml" in response.headers.get("Content-Type", ""):
            if "ServiceException" in response.text:
                raise GSLayerNotFound(
                    f"Error response {response.status_code} from {link.url}"
                )
        return
    raise GSLayerNotFound(f"Error response {response.status_code} from {link.url}")
