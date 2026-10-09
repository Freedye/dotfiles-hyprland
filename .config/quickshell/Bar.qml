import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: win

    required property var modelData

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: Theme.bg
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "qs-bar"

    Item {
        anchors.fill: parent

        WindowTitle {
            anchors.left: parent.left
        }

        Media {
            anchors.horizontalCenter: parent.horizontalCenter
            appearDelay: 140
        }

        Row {
            spacing: 4
            anchors.right: parent.right

            AudioIsland {
                appearDelay: 210
            }
            Hardware {
                appearDelay: 280
            }
            Clock {
                appearDelay: 350
            }
            Power {
                appearDelay: 420
            }
        }
    }
}
