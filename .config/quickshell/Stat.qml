import QtQuick

// icon + value with an optional hover tooltip line
Item {
    id: root

    property string glyph: ""
    property string value: ""
    // optional icon after the value (e.g. the charging bolt)
    property string badge: ""
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

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.badge !== ""
            text: root.badge
            color: root.tint
            font.pixelSize: 13
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
