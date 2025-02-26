"""
module for dockable text widget
"""

from PyQt5 import QtWidgets
from qgis.PyQt.QtWidgets import QDockWidget


class TextDockWidget(QDockWidget):  # pylint: disable=too-few-public-methods
    """
    dockable text widget
    """

    def __init__(self, parent=None):
        super().__init__(parent)

        self.setWindowTitle("Mon dockwidget texte")
        self.text_widget = QtWidgets.QWidget()
        self.text_layout = QtWidgets.QVBoxLayout()
        self.text_label = QtWidgets.QLabel("Texte à afficher")
        self.text_layout.addWidget(self.text_label)
        self.text_widget.setLayout(self.text_layout)
        self.setWidget(self.text_widget)
