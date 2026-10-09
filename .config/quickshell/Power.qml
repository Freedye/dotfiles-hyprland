import QtQuick

Island {
    id: root

    cursor: Qt.PointingHandCursor

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        width: 11
        horizontalAlignment: Text.AlignLeft
        text: Theme.ico.power
        color: root.hovered || menu.wantOpen ? Theme.danger : Theme.fg
        scale: root.hovered ? 1.15 : 1

        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutBack }
        }
    }

    overlay: TapHandler {
        onTapped: menu.toggle()
    }

    PowerMenu {
        id: menu
        target: root
    }
}
