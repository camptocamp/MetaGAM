import re
from contextlib import contextmanager
from zipfile import ZipFile
from nose.plugins.attrib import attr
import requests_mock

from qgis.core import QgsVectorLayer, QgsDataSourceUri, QgsProject

from meta_gam.Meta_GAM_dialog import MetaGAMDialog
from meta_gam.test.utilities import get_qgis_app


QGIS_APP = get_qgis_app()


def get_link_protocols(mock):
    return set(
        tuple([*r.qs.get("outputformat", [None]), *r.qs.get("service", [None])])
        for r in mock.request_history
        if r.qs.get("outputformat") or r.qs.get("service")
    )


@contextmanager
def mock_geoserver():
    with requests_mock.Mocker() as m:

        def ows_callback(request, context):
            if request.query == "request=getcapabilities&service=wms":
                return (
                    "<main><Layer><Layer><Name>urba_plui_public:plan_2_c2_inf_99_decheterie_surf"
                    "</Name></Layer></Layer></main>"
                )
            if request.query == "request=getcapabilities&service=wfs":
                return (
                    "<main><FeatureType><Name>urba_plui_public:plan_2_c2_inf_99_decheterie_surf"
                    "</Name></FeatureType></main>"
                )
            return ""

        m.get(
            "https://geoflux.grenoblealpesmetropole.fr/geoserver/urba_plui_public/ows",
            text=ows_callback,
        )
        m.post(requests_mock.ANY)
        m.get("http://geonetwork:8080/geonetwork/srv/api/me", json={"profile": "admin"})
        m.get("http://geonetwork:8080/geonetwork/srv/eng/info")
        m.get(
            re.compile("http://geonetwork:8080/geonetwork/srv/api/records"),
            status_code=404,
        )
        yield m


LINK_PROTOCOLS_REF = {
    (None, "wms"),
    (None, "wfs"),
    ("kml", "wfs"),
    ("application/json", "wfs"),
}


@attr("localDB")
def test_zip():
    dialog = MetaGAMDialog(None)
    uri = QgsDataSourceUri(
        "service='bd_prod' sslmode=disable key='idinformation'"
        "srid=3945 type=Polygon checkPrimaryKeyUnicity='1' "
        'table="urba_plui_public"."plan_2_c2_inf_99_decheterie_surf" (geom)\''
    )
    layer = QgsVectorLayer(uri.uri(), "plan_2_c2_inf_99_decheterie_surf", "postgres")
    meta = layer.metadata()
    meta.setLicenses(["Licence ouverte (OpenDATA)"])
    layer.setMetadata(meta)
    QgsProject.instance().addMapLayer(layer)

    with mock_geoserver() as m:

        dialog.auto_fill_meta()

        assert m.call_count == 4
        link_protocols = get_link_protocols(m)
        assert link_protocols == LINK_PROTOCOLS_REF

    root = dialog.treeWidget.invisibleRootItem()
    abstract_treeitem = next(
        root.child(0).child(i)
        for i in range(root.child(0).childCount())
        if root.child(0).child(i).text(2) == "Licence"
    )
    dialog.treeWidget.itemWidget(abstract_treeitem, 3).setCurrentIndex(1)
    assert (
        dialog.treeWidget.itemWidget(abstract_treeitem, 3).currentText()
        == "Licence ouverte (OpenDATA)"
    )

    with mock_geoserver() as m:

        dialog.update_meta()

        assert m.call_count == 4
        link_protocols = get_link_protocols(m)
        assert link_protocols == LINK_PROTOCOLS_REF
    dialog.treeWidget.itemWidget(root.child(0), 0).setChecked(True)

    with mock_geoserver() as m:
        dialog.add_INSPIRE_to_xml()
        assert m.call_count == 8
        link_protocols = get_link_protocols(m)
        assert link_protocols == LINK_PROTOCOLS_REF

    meta_ids = dialog.get_meta_ID(layer.metadata().identifier())
    with ZipFile(f"./temp/{meta_ids[0]}.zip") as z:
        xml = z.read(f"{meta_ids[0]}/metadata/metadata.xml")
    xml_generic_dates = re.sub(
        rb"<gco:DateTime>[^<>]*</gco:DateTime>",
        b"<gco:DateTime>today_now</gco:DateTime>",
        re.sub(
            rb"<gco:Date>[^<>]*</gco:Date>",
            b"<gco:Date>today</gco:Date>",
            xml,
        ),
    )

    with open("./test/dechetterie.xml", "rb") as f:
        xml_ref = f.read()
        assert xml_generic_dates == xml_ref
