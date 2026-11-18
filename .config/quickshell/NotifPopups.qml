import QtQuick
import Quickshell
import Quickshell.Wayland

// Popup column in the top-right corner, under the bar. Clicks outside the cards pass through.
PanelWindow {
    id: win

    required property var modelData

    screen: modelData
    anchors {
        top: true
        right: true
    }
    margins {
        top: 8
        right: 8
    }
    implicitWidth: 340
    implicitHeight: Math.max(1, col.implicitHeight)
    color: "transparent"
    visible: Notifs.popups.length > 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-notifications"
    mask: Region { item: col }

    Column {
        id: col
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups

            NotifCard {
                required property var modelData
                notif: modelData
                popup: true
            }
        }
    }
}
