import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
    id: root

    required property var modelData
    readonly property bool menuOpen: menu.wantOpen

    width: 20
    height: Theme.barHeight

    IconImage {
        id: img
        anchors.centerIn: parent
        implicitSize: 16
        source: root.modelData.icon
        scale: hover.hovered ? 1.2 : 1

        Behavior on scale {
            NumberAnimation { duration: 140; easing.type: Easing.OutBack }
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: {
            if (root.modelData.onlyMenu && root.modelData.hasMenu)
                menu.open();
            else
                root.modelData.activate();
        }
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        // no dbusmenu (e.g. Wine apps): ask the application for its own menu on press, at the pointer
        onPressedChanged: {
            if (pressed && !root.modelData.hasMenu) {
                const p = root.mapToGlobal(point.position.x, point.position.y);
                Quickshell.execDetached(["bash", Quickshell.shellPath("scripts/tray-contextmenu.sh"), root.modelData.id, Math.round(p.x), Math.round(p.y)]);
            }
        }
        onTapped: {
            if (root.modelData.hasMenu)
                menu.open();
        }
    }
    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: root.modelData.secondaryActivate()
    }

    TrayMenu {
        id: menu
        target: root
        handle: root.modelData.menu
    }

    Tip {
        target: root
        show: hover.hovered && !menu.wantOpen && (root.modelData.tooltipTitle || root.modelData.title) !== ""

        Txt {
            text: root.modelData.tooltipTitle || root.modelData.title
        }
    }
}
