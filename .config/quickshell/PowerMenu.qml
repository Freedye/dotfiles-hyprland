import QtQuick
import Quickshell
import Quickshell.Hyprland

// The "Apple menu": a drop-down under the power button, right-aligned to it.
PopupWindow {
    id: root

    required property Item target
    property bool wantOpen: false

    readonly property var entries: [
        { id: "suspend", label: "Sospendi", glyph: Theme.ico.suspend },
        { id: "reboot", label: "Riavvia…", glyph: Theme.ico.restart },
        { id: "poweroff", label: "Spegni…", glyph: Theme.ico.power },
        { sep: true },
        { id: "lock", label: "Blocca schermo", glyph: Theme.ico.lock },
        { id: "logout", label: `Esci da ${Session.user}…`, glyph: Theme.ico.logout }
    ]

    function toggle() {
        wantOpen = !wantOpen;
    }

    anchor.item: target
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.adjustment: PopupAdjustment.Slide
    color: "transparent"
    visible: wantOpen || card.opacity > 0.01
    implicitWidth: card.width
    implicitHeight: card.height + 8

    HyprlandFocusGrab {
        windows: [root]
        active: root.wantOpen
        onCleared: root.wantOpen = false
    }

    // PopupWindow has no keyboard handling of its own; this scope gets it through the focus grab
    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: root.wantOpen = false
    }

    Rectangle {
        id: card
        y: 8 + (root.wantOpen ? 0 : -8)
        width: 224
        height: col.implicitHeight + 12
        color: Theme.alpha(Theme.bg, 0.985)
        border.width: 1
        border.color: Theme.alpha(Theme.dim, 0.55)
        opacity: root.wantOpen ? 1 : 0
        transformOrigin: Item.TopRight
        scale: root.wantOpen ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation { duration: 140 }
        }
        Behavior on y {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Column {
            id: col
            x: 6
            y: 6
            width: parent.width - 12
            spacing: 1

            Repeater {
                model: root.entries

                Item {
                    id: entry

                    required property var modelData
                    readonly property bool sep: modelData.sep === true

                    width: col.width
                    height: sep ? 9 : 30

                    Rectangle {
                        visible: entry.sep
                        anchors.centerIn: parent
                        width: parent.width - 12
                        height: 1
                        color: Theme.alpha(Theme.dim, 0.5)
                    }

                    // macOS-style solid highlight under the pointer
                    Rectangle {
                        anchors.fill: parent
                        visible: !entry.sep
                        color: hover.hovered ? Theme.accent : "transparent"

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 10
                            spacing: 10

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18
                                text: entry.modelData.glyph ?? ""
                                font.pixelSize: 15
                                color: hover.hovered ? Theme.bg : Theme.dim
                            }
                            Txt {
                                anchors.verticalCenter: parent.verticalCenter
                                text: entry.modelData.label ?? ""
                                color: hover.hovered ? Theme.bg : Theme.fg
                            }
                        }

                        HoverHandler {
                            id: hover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: {
                                root.wantOpen = false;
                                Session.request(entry.modelData.id);
                            }
                        }
                    }
                }
            }
        }
    }
}
