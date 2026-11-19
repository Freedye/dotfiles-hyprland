import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Bluetooth

// Bluetooth in the bar (replaces blueman): left click opens the device list, right click toggles the adapter.
Island {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter?.enabled ?? false
    readonly property var devices: adapter ? [...adapter.devices.values] : []
    // connected first, then paired, then the others found while scanning
    readonly property var sorted: devices.slice().sort((a, b) =>
        (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
    readonly property int connectedCount: devices.filter(d => d.connected).length

    present: adapter !== null
    cursor: Qt.PointingHandCursor
    spacing: 5

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        text: !root.on ? Theme.ico.btOff : root.connectedCount > 0 ? Theme.ico.btConnected : Theme.ico.bt
        font.pixelSize: 15
        color: !root.on ? Theme.dim : root.hovered || panel.wantOpen || root.connectedCount > 0 ? Theme.accent : Theme.fg
    }

    overlay: [
        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: panel.wantOpen = !panel.wantOpen
        },
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
        }
    ]

    // qs ipc call bluetooth toggle | power
    IpcHandler {
        target: "bluetooth"

        function toggle(): void { panel.wantOpen = !panel.wantOpen; }
        function power(): void { if (root.adapter) root.adapter.enabled = !root.adapter.enabled; }
    }

    PopupWindow {
        id: panel

        property bool wantOpen: false

        // stop scanning when the panel closes
        onWantOpenChanged: if (!wantOpen && root.adapter?.discovering) root.adapter.discovering = false

        // right edge in line with the notification popups, 8px from the screen edge
        anchor.item: root.QsWindow.contentItem
        anchor.rect.width: (root.QsWindow.contentItem?.width ?? 8) - 8
        anchor.rect.height: Theme.barHeight
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        anchor.adjustment: PopupAdjustment.Slide
        color: "transparent"
        visible: wantOpen || card.opacity > 0.01
        implicitWidth: card.width
        implicitHeight: card.height + 8

        // push the notification popups under this panel
        Binding {
            target: Notifs
            property: "panelInset"
            value: card.height + 8
            when: panel.wantOpen
        }

        HyprlandFocusGrab {
            windows: [panel]
            active: panel.wantOpen
            onCleared: panel.wantOpen = false
        }

        FocusScope {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: panel.wantOpen = false
        }

        Rectangle {
            id: card
            y: 8 + (panel.wantOpen ? 0 : -8)
            width: 340 // same as the notification cards
            height: header.height + list.implicitHeight + 22
            color: Theme.alpha(Theme.bg, 0.985)
            border.width: 1
            border.color: Theme.alpha(Theme.dim, 0.55)
            opacity: panel.wantOpen ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 140 } }
            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Item {
                id: header
                x: 14
                y: 8
                width: parent.width - 28
                height: 28

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth"
                    font.bold: true
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Txt {
                        visible: root.on
                        text: root.adapter?.discovering ? "Ricerca…" : "Cerca"
                        font.pixelSize: 12
                        color: scanHover.hovered || root.adapter?.discovering ? Theme.accent : Theme.dim
                        HoverHandler { id: scanHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: root.adapter.discovering = !root.adapter.discovering }
                    }
                    Txt {
                        text: root.on ? "Acceso" : "Spento"
                        font.pixelSize: 12
                        color: powerHover.hovered ? Theme.accent : root.on ? Theme.fg : Theme.dim
                        HoverHandler { id: powerHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: root.adapter.enabled = !root.adapter.enabled }
                    }
                }
            }

            Column {
                id: list
                anchors.top: header.bottom
                anchors.topMargin: 6
                width: parent.width
                spacing: 1

                Txt {
                    visible: !root.on || root.sorted.length === 0
                    width: parent.width
                    height: 36
                    horizontalAlignment: Text.AlignHCenter
                    text: !root.on ? "Bluetooth spento" : "Nessun dispositivo"
                    color: Theme.dim
                }

                Repeater {
                    model: root.on ? root.sorted : []

                    Rectangle {
                        id: row

                        required property var modelData
                        readonly property var dev: modelData
                        readonly property bool busy: dev.pairing
                            || dev.state === BluetoothDeviceState.Connecting
                            || dev.state === BluetoothDeviceState.Disconnecting

                        function activate() {
                            if (busy) return;
                            if (dev.connected) {
                                dev.disconnect();
                            } else if (dev.paired) {
                                dev.connect();
                            } else {
                                // devices that need a PIN/passkey: pair them with bluetoothctl
                                dev.trusted = true;
                                dev.pair();
                            }
                        }

                        width: list.width
                        height: 34
                        color: hover.hovered ? Theme.dim : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Rectangle {
                            width: 3
                            height: parent.height
                            color: Theme.accent
                            opacity: hover.hovered ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 120 } }
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 14
                            spacing: 10

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16
                                text: row.dev.connected ? Theme.ico.btConnected : Theme.ico.bt
                                font.pixelSize: 14
                                color: row.dev.connected ? Theme.accent : Theme.dim
                            }
                            Txt {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 190
                                text: row.dev.name || row.dev.address
                                elide: Text.ElideRight
                                color: row.dev.paired ? Theme.fg : Theme.alpha(Theme.fg, 0.7)
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Txt {
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 11
                                color: Theme.dim
                                text: row.dev.pairing ? "associo…"
                                    : row.dev.state === BluetoothDeviceState.Connecting ? "connetto…"
                                    : row.dev.state === BluetoothDeviceState.Disconnecting ? "disconnetto…"
                                    : row.dev.connected && row.dev.batteryAvailable ? `${Math.round(row.dev.battery * 100)}%`
                                    : row.dev.connected ? "connesso"
                                    : !row.dev.paired ? "associa" : ""
                            }
                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: row.dev.paired && hover.hovered
                                text: Theme.ico.close
                                font.pixelSize: 13
                                color: forgetHover.hovered ? Theme.danger : Theme.dim
                                HoverHandler { id: forgetHover }
                                TapHandler { onTapped: row.dev.forget() }
                            }
                        }

                        HoverHandler {
                            id: hover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler { onTapped: row.activate() }
                    }
                }
            }
        }
    }
}
