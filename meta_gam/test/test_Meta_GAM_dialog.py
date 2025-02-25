# coding=utf-8
"""Dialog test.

.. note:: This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.

"""

__author__ = "demande_sit@grenoblealpesmetropole.fr"
__date__ = "2022-12-22"
__copyright__ = "Copyright 2022, Service SIT - Amr HAMADEH"

import unittest
import requests

from qgis.PyQt.QtWidgets import QDialog

from qgis.core import QgsVectorLayer, QgsDataSourceUri, QgsProject

from meta_gam.Meta_GAM_dialog import MetaGAMDialog
from meta_gam.Meta_GAM_Geonetwork import CATALOG

from meta_gam.test.utilities import get_qgis_app

QGIS_APP = get_qgis_app()


class MetaGAMDialogTest(unittest.TestCase):
    """Test dialog works."""

    def setUp(self):
        """Runs before each test."""
        self.dialog = MetaGAMDialog(None)

    def tearDown(self):
        """Runs after each test."""
        self.dialog = None

    def test_dialog_auto_fill(self):
        """Test we can click AutoFill."""
        self.dialog.UserPassword = "geonetwork"
        uri = QgsDataSourceUri(
            "service='bd_prod' sslmode=disable key='idinformation'"
            "srid=3945 type=Polygon checkPrimaryKeyUnicity='1' "
            'table="urba_plui_public"."plan_2_c2_inf_99_decheterie_surf" (geom)\''
        )
        layer = QgsVectorLayer(uri.uri(), "test", "postgres")
        QgsProject.instance().addMapLayer(layer)

        root = self.dialog.treeWidget.invisibleRootItem()
        assert root.childCount() == 0
        self.dialog.pbAutoMeta.click()
        assert root.childCount() == 1
        self.assertTrue(self.dialog.connexion_postgresql()[0])

    def test_publish(self):
        """Test we can publish the data."""
        self.dialog.UserPassword = "geonetwork"
        uri = QgsDataSourceUri(
            "service='bd_prod' sslmode=disable key='idinformation'"
            "srid=3945 type=Polygon checkPrimaryKeyUnicity='1' table=\"urba_plui_pu"
            'blic"."plan_2_c2_inf_99_decheterie_surf" (geom)\''
        )
        layer = QgsVectorLayer(uri.uri(), "test", "postgres")
        QgsProject.instance().addMapLayer(layer)

        root = self.dialog.treeWidget.invisibleRootItem()
        assert root.childCount() == 0
        self.dialog.pbAutoMeta.click()
        assert root.childCount() == 2
        assert self.dialog.check_tree_title()
        self.dialog.leUsername.setText("admin")
        self.dialog.lePassword.setText("admin")
        assert self.dialog.pbPost.isHidden()
        self.dialog.pbConnexion.click()
        assert not self.dialog.pbPost.isHidden()
        self.dialog.treeWidget.itemWidget(root.child(0), 0).setChecked(True)
        assert self.dialog.tableGN.model() is None
        self.dialog.pbPost.click()
        assert self.dialog.model.rowCount() == 1
        url = self.dialog.model.data(self.dialog.model.index(0, 1))
        uuid = "50e3a04d-4744-46a0-8a70-09da72860a3f"
        uuid = url.split("/")[-1]
        test_layer = requests.get(
            CATALOG + "/srv/api/records/" + uuid, headers={"accept": "application/json"}
        )
        assert test_layer.status_code == 200
        ss = requests.Session()
        me = ss.get(
            CATALOG + "/srv/api/me",
            headers={"accept": "application/json"},
            auth=("admin", "admin"),
        )
        assert me.json()["profile"] == "Administrator"
        xsrf = ss.cookies.get("XSRF-TOKEN")
        deletion = ss.delete(
            CATALOG + "/srv/api/records/" + uuid,
            auth=("admin", "admin"),
            headers={"X-XSRF-TOKEN": xsrf},
        )
        ss.close()

    def test_dialog_cancel(self):
        """Test we can click cancel."""
        self.dialog.pbCancel.click()
        result = self.dialog.result()
        self.assertEqual(result, QDialog.Rejected)


if __name__ == "__main__":
    suite = unittest.makeSuite(MetaGAMDialogTest)
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)
