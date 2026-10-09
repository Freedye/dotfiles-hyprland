import QtQuick

// icon + value with an optional hover tooltip line
Item {
    id: root

    property string glyph: ""
    property string value: ""
    property color tint: Theme.fg
    property string tip: ""
    property alias hovered: hover.hovered
    signal clicked

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.barHeight

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            color: root.tint
            font.pixelSize: 15
        }

        Txt {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.value !== ""
            text: root.value
            color: root.tint
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        onTapped: root.clicked()
    }

    Tip {
        target: root
        show: hover.hovered && root.tip !== ""

        Txt {
            text: root.tip
            lineHeight: 1.2
        }
    }
}
