# coding=utf-8
"""Dialog test.

.. note:: This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.

"""

import uuid
import unittest
from unittest.mock import patch
from nose.plugins.attrib import attr
import requests
import requests_mock

from qgis.PyQt.QtWidgets import QDialog

from qgis.core import QgsVectorLayer, QgsDataSourceUri, QgsProject

from meta_gam.Meta_GAM_dialog import MetaGAMDialog
from meta_gam.Meta_GAM_Geonetwork import CATALOG

from meta_gam.test.utilities import get_qgis_app

__author__ = "demande_sit@grenoblealpesmetropole.fr"
__date__ = "2022-12-22"
__copyright__ = "Copyright 2022, Service SIT - Amr HAMADEH"

QGIS_APP = get_qgis_app()


class MetaGAMDialogTest(unittest.TestCase):
    """Test dialog works."""

    def setUp(self):
        """Runs before each test."""
        self.dialog = MetaGAMDialog(None)
        self.dialog.leUsername.setText("admin")
        self.dialog.lePassword.setText("admin")
        self.id = str(uuid.uuid4())

    def tearDown(self):
        """Runs after each test."""
        self.dialog.mgGN.close()
        self.dialog = None

    @attr("localDB")
    def test_dialog_auto_fill(self):
        """Test we can click AutoFill."""
        self.dialog.UserPassword = "geonetwork"
        uri = QgsDataSourceUri(
            "service='bd_prod' sslmode=disable key='idinformation'"
            "srid=3945 type=Polygon checkPrimaryKeyUnicity='1' "
            'table="urba_plui_public"."plan_2_c2_inf_99_decheterie_surf" (geom)\''
        )
        layer = QgsVectorLayer(
            uri.uri(), "plan_2_c2_inf_99_decheterie_surf", "postgres"
        )
        QgsProject.instance().addMapLayer(layer)

        root = self.dialog.treeWidget.invisibleRootItem()
        assert root.childCount() == 0
        self.dialog.pbAutoMeta.click()
        assert root.childCount() == 1
        self.assertTrue(self.dialog.connexion_postgresql()[0])
        QgsProject.instance().removeMapLayer(layer)

    def test_mocked_connect(self):
        with requests_mock.Mocker() as m:
            cookies = requests_mock.CookieJar()
            cookies.set("XSRF-TOKEN", "dummy_xsrf", path="/geonetwork")
            m.get(
                "http://geonetwork:8080/geonetwork/srv/api/me",
                json={"profile": "Admin"},
            )
            self.dialog.pbConnexion.click()
            assert m.call_count == 1

    def test_mocked_publish(self):
        tempLayer = QgsVectorLayer("polygon", "monPolygon", "memory")
        meta = tempLayer.metadata()
        meta.setIdentifier(self.id)
        tempLayer.setMetadata(meta)
        QgsProject.instance().addMapLayer(tempLayer)

        for user_json in [
            {"profile": "Admin"},
            {"profile": "UserAdmin", "groupsWithUserAdmin": ["monGroupe"]},
        ]:
            with requests_mock.Mocker() as m:
                cookies = requests_mock.CookieJar()
                cookies.set("XSRF-TOKEN", "dummy_xsrf", path="/geonetwork")
                m.get("http://geonetwork:8080/geonetwork/srv/api/me", json=user_json)
                m.get(
                    f"http://geonetwork:8080/geonetwork/srv/api/records/{self.id}/formatters/xml",
                    text='<main xmlns:gco="http://www.isotc211.org/2005/gco"><gco:Date>1-1-2011</gco:Date></main>',
                )
                m.post(
                    "http://geonetwork:8080/geonetwork/srv/api/records",
                    json={"success": True},
                )

                def cb_status(cl):
                    cl.tree_checkbox_status = {0: True}

                with patch(
                    "meta_gam.Meta_GAM_dialog.MetaGAMDialog.get_tree_checkbox_status",
                    cb_status,
                ), patch(
                    "meta_gam.Meta_GAM_dialog.MetaGAMDialog.check_tree_title",
                    lambda c: True,
                ), patch(
                    "meta_gam.Meta_GAM_dialog.MetaGAMDialog.get_meta_ID",
                    lambda c, id: [self.id],
                ):
                    self.dialog.mgGN.connect("admin", "admin")
                    self.dialog.pbPost.click()
                assert m.call_count == 3
                post_requests = [
                    r
                    for r in m.request_history
                    if r.path == "/geonetwork/srv/api/records"
                    and r._request.method == "POST"
                ]
                # Check that metadata post method has been called with or without group
                if user_json["profile"] == "UserAdmin":
                    assert all("group=" in r.query for r in post_requests)
                else:
                    assert not any("group=" in r.query for r in post_requests)
        assert self.dialog.model.rowCount() == 1
        assert self.dialog.model.item(0, 0).text() == "monPolygon"
        assert (
            self.dialog.model.item(0, 1).text()
            == f"http://geonetwork:8080/geonetwork/srv/fre/catalog.search#/metadata/{self.id}"
        )
        QgsProject.instance().removeMapLayer(tempLayer)

    @attr("localGN")
    def test_publish(self):
        """Test we can publish the data."""
        self.dialog.UserPassword = "geonetwork"
        uri = QgsDataSourceUri(
            "service='bd_prod' sslmode=disable key='idinformation'"
            "srid=3945 type=Polygon checkPrimaryKeyUnicity='1' table=\"urba_plui_pu"
            'blic"."plan_2_c2_inf_99_decheterie_surf" (geom)\''
        )
        layer = QgsVectorLayer(
            uri.uri(), "plan_2_c2_inf_99_decheterie_surf", "postgres"
        )
        QgsProject.instance().addMapLayer(layer)

        root = self.dialog.treeWidget.invisibleRootItem()
        assert root.childCount() == 0
        self.dialog.pbAutoMeta.click()
        assert root.childCount() == 1
        assert self.dialog.check_tree_title()
        assert self.dialog.pbPost.isHidden()
        abstract_treeitem = next(
            root.child(0).child(i)
            for i in range(root.child(0).childCount())
            if root.child(0).child(i).text(2) == "Résumé de la couche"
        )
        self.dialog.treeWidget.itemWidget(abstract_treeitem, 3).setText(
            "En quelques mots..."
        )
        self.dialog.update_meta()
        self.dialog.treeWidget.itemWidget(root.child(0), 0).setChecked(True)
        assert self.dialog.tableGN.model() is None
        self.dialog.pbConnexion.click()
        assert not self.dialog.pbPost.isHidden()
        self.dialog.pbPost.click()
        assert self.dialog.model.rowCount() == 1

        QgsProject.instance().removeMapLayer(layer)

        url = self.dialog.model.data(self.dialog.model.index(0, 1))
        uuid = "50e3a04d-4744-46a0-8a70-09da72860a3f"
        uuid = url.split("/")[-1]
        test_layer = requests.get(
            CATALOG + "/srv/api/records/" + uuid,
            headers={"accept": "application/json"},
            timeout=30,
        )
        assert test_layer.status_code == 200
        ss = requests.Session()
        me = ss.get(
            CATALOG + "/srv/api/me",
            headers={"accept": "application/json"},
            auth=("admin", "admin"),
            timeout=30,
        )
        assert me.json()["profile"] == "Administrator"
        xsrf = ss.cookies.get("XSRF-TOKEN")

        # query editor is necessary to enable validation
        edit_form = ss.get(
            CATALOG + "/srv/api/records/" + uuid + "/editor",
            auth=("admin", "admin"),
            headers={"X-XSRF-TOKEN": xsrf},
            timeout=30,
        )
        assert edit_form.status_code == 200

        validity = ss.put(
            CATALOG + "/srv/api/records/" + uuid + "/validate/internal",
            auth=("admin", "admin"),
            headers={
                "X-XSRF-TOKEN": xsrf,
                "accept": "application/json",
            },
            timeout=30,
        )
        assert validity.status_code == 201
        validation_errors = [
            (p["title"], r)
            for r in validity.json()["report"]
            for p in r["patterns"]["pattern"]
            for r in p["rules"]["rule"]
            if r["type"] != "success"
        ]
        assert all(report["error"] == 0 for report in validity.json()["report"])
        assert len(validation_errors) == 0

        deletion = ss.delete(
            CATALOG + "/srv/api/records/" + uuid,
            auth=("admin", "admin"),
            headers={"X-XSRF-TOKEN": xsrf},
            timeout=30,
        )
        assert deletion.status_code == 204
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
