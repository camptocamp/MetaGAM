from zipfile import ZipFile

from qgis.core import QgsVectorLayer, QgsDataSourceUri, QgsProject

from meta_gam.Meta_GAM_dialog import MetaGAMDialog
from meta_gam.test.utilities import get_qgis_app


QGIS_APP = get_qgis_app()


def test_zip():
    dialog = MetaGAMDialog(None)
    uri = QgsDataSourceUri(
        "service='bd_prod' sslmode=disable key='idinformation'"
        "srid=3945 type=Polygon checkPrimaryKeyUnicity='1' "
        'table="urba_plui_public"."plan_2_c2_inf_99_decheterie_surf" (geom)\''
    )
    layer = QgsVectorLayer(uri.uri(), "test", "postgres")
    QgsProject.instance().addMapLayer(layer)

    dialog.auto_fill_meta()
    root = dialog.treeWidget.invisibleRootItem()
    dialog.treeWidget.itemWidget(root.child(0), 0).setChecked(True)

    dialog.add_INSPIRE_to_xml()
    meta_ids = dialog.get_meta_ID(layer.metadata().identifier())
    with ZipFile(f"./temp/{meta_ids[0]}.zip") as z:
        xml = z.read(f"{meta_ids[0]}/metadata/metadata.xml")
    with open("./test/dechetterie.xml", "rb") as f:
        assert xml == f.read()
