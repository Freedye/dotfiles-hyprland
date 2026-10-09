import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

// The "hardware" drawer: hover (or click the handle to pin) and it unfolds to the left.
Island {
    id: root

    property bool pinned: false
    property int openMenus: 0
    readonly property bool open: pinned || hovered || holdTimer.running || openMenus > 0
    // 0..1, drives the whole unfolding; the island follows it directly instead of animating twice
    property real reveal: open ? 1 : 0
    readonly property int gap: 12

    readonly property color tempTint: Stats.temp >= 80 ? Theme.danger : Stats.temp >= 70 ? Theme.warm : Theme.fg
    readonly property color cpuTint: Stats.cpu >= 90 ? Theme.danger : Theme.fg

    spacing: 0
    animateWidth: false

    Behavior on reveal {
        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    onHoveredChanged: if (!hovered) holdTimer.restart()

    Timer {
        id: holdTimer
        interval: 700
    }

    Item {
        id: drawer
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        width: (content.implicitWidth + root.gap) * root.reveal
        clip: true

        // anchored to the handle side, so the items slide out of it as the drawer opens
        Row {
            id: content
            anchors.right: parent.right
            anchors.rightMargin: root.gap
            height: parent.height
            spacing: root.gap
            opacity: Math.max(0, (root.reveal - 0.15) / 0.85)

            Stat {
                anchors.verticalCenter: parent.verticalCenter
                glyph: Stats.netType === "wifi" ? Theme.ico.wifi : Stats.netType === "ethernet" ? Theme.ico.ethernet : Theme.ico.warn
                value: Stats.netType === "wifi" ? `${Stats.netName} ${Stats.netSignal}%` : ""
                tint: Stats.netType === "none" ? Theme.danger : Theme.fg
                tip: Stats.netType === "none" ? "Disconnesso" : `${Stats.netType === "wifi" ? "Wi-Fi" : "Ethernet"}\n${Stats.netName}`
                onClicked: Quickshell.execDetached(["nm-connection-editor"])
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 14
                color: Theme.alpha(Theme.dim, 0.5)
            }

            Stat {
                anchors.verticalCenter: parent.verticalCenter
                glyph: Theme.ico.cpu
                value: `${Stats.cpu}%`
                tint: root.cpuTint
                tip: `CPU  ${Stats.cpu}%`
            }

            Stat {
                anchors.verticalCenter: parent.verticalCenter
                glyph: Theme.ico.mem
                value: `${Stats.mem}%`
                tip: `RAM  ${Stats.memUsedGiB.toFixed(1)} / ${Stats.memTotalGiB.toFixed(1)} GiB`
            }

            Stat {
                anchors.verticalCenter: parent.verticalCenter
                glyph: Theme.ico.temp
                value: `${Stats.temp}°C`
                tint: root.tempTint
                tip: Stats.temp >= 80 ? "Temperatura critica!" : `CPU  ${Stats.temp}°C`
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 14
                color: Theme.alpha(Theme.dim, 0.5)
                visible: SystemTray.items.values.length > 0
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Repeater {
                    model: SystemTray.items

                    TrayItem {
                        onMenuOpenChanged: root.openMenus += menuOpen ? 1 : -1
                    }
                }
            }
        }
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        width: 15
        horizontalAlignment: Text.AlignLeft
        text: Theme.ico.drawer
        color: root.pinned ? Theme.accent : handleHover.hovered ? Theme.accent : Theme.fg
        rotation: 180 * root.reveal

        HoverHandler {
            id: handleHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: root.pinned = !root.pinned
        }
    }
}
