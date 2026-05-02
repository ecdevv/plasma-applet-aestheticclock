import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts as QtLayouts
import QtQuick.Dialogs

QtControls.Button {
    id: colorButton
    implicitWidth: 50

    property color value

    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.margins: 5
        radius: 3
        color: value
        opacity: enabled ? 1 : 0.4
    }

    MouseArea {
        anchors.fill: parent
        onClicked: dialog.open()
    }

    ColorDialog {
        id: dialog
        title: "Select Color"
        selectedColor: value
        options: {
            ShowAlphaChannel: true
        }
        onAccepted: {
            value = selectedColor
        }
    }
}