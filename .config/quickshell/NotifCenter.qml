import QtQuick
import Quickshell
import Quickshell.Hyprland

// Bell in the bar: left click opens the history, right click toggles do-not-disturb.
Island {
    id: root

    readonly property int count: Notifs.history.length

    cursor: Qt.PointingHandCursor
    spacing: 5

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        text: Notifs.dnd ? Theme.ico.bellOff : Theme.ico.bell
        font.pixelSize: 15
        color: Notifs.dnd ? Theme.dim : root.hovered || panel.wantOpen || root.count > 0 ? Theme.accent : Theme.fg
    }
    Txt {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.count > 0
        text: root.count
        font.bold: true
    }

    overlay: [
        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: panel.wantOpen = !panel.wantOpen
        },
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: Notifs.dnd = !Notifs.dnd
        }
    ]

    PopupWindow {
        id: panel

        property bool wantOpen: false

        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        anchor.adjustment: PopupAdjustment.Slide
        color: "transparent"
        visible: wantOpen || card.opacity > 0.01
        implicitWidth: card.width
        implicitHeight: card.height + 8

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
            width: 360
            height: header.height + list.height + 20
            color: Theme.alpha(Theme.bg, 0.985)
            border.width: 1
            border.color: Theme.alpha(Theme.dim, 0.55)
            opacity: panel.wantOpen ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 140 } }
            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Item {
                id: header
                x: 10
                y: 8
                width: parent.width - 20
                height: 28

                Txt {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notifiche"
                    font.bold: true
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Txt {
                        text: Notifs.dnd ? "Non disturbare: sì" : "Non disturbare: no"
                        font.pixelSize: 12
                        color: dndHover.hovered ? Theme.accent : Notifs.dnd ? Theme.fg : Theme.dim
                        HoverHandler { id: dndHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: Notifs.dnd = !Notifs.dnd }
                    }
                    Txt {
                        visible: root.count > 0
                        text: "Cancella tutto"
                        font.pixelSize: 12
                        color: clearHover.hovered ? Theme.danger : Theme.dim
                        HoverHandler { id: clearHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: Notifs.clear() }
                    }
                }
            }

            Flickable {
                id: list
                x: 10
                anchors.top: header.bottom
                anchors.topMargin: 4
                width: 340
                height: root.count === 0 ? empty.height : Math.min(cards.implicitHeight, 600)
                contentHeight: cards.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Txt {
                    id: empty
                    visible: root.count === 0
                    width: parent.width
                    height: 40
                    horizontalAlignment: Text.AlignHCenter
                    text: "Nessuna notifica"
                    color: Theme.dim
                }

                Column {
                    id: cards
                    width: parent.width
                    spacing: 8

                    Repeater {
                        model: Notifs.history

                        NotifCard {
                            required property var modelData
                            notif: modelData
                        }
                    }
                }
            }
        }
    }
}
