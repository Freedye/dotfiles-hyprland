import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

// Themed replacement for the native tray menu, with drill-down submenus.
PopupWindow {
    id: root

    required property Item target
    required property var handle
    property bool wantOpen: false
    property var current: handle
    property var stack: []

    function open() {
        stack = [];
        current = handle;
        wantOpen = true;
    }

    function close() {
        wantOpen = false;
    }

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.Slide
    color: "transparent"
    visible: wantOpen
    implicitWidth: card.width
    implicitHeight: card.height + 8

    QsMenuOpener {
        id: opener
        menu: root.wantOpen ? root.current : null
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.wantOpen
        onCleared: root.close()
    }

    Rectangle {
        id: card
        y: 8
        width: 220
        height: col.implicitHeight + 12
        color: Theme.alpha(Theme.bg, 0.985)
        border.width: 1
        border.color: Theme.alpha(Theme.dim, 0.55)

        Column {
            id: col
            x: 6
            y: 6
            width: parent.width - 12
            spacing: 1

            // back row when inside a submenu
            Rectangle {
                width: parent.width
                height: 28
                visible: root.stack.length > 0
                color: backHover.hovered ? Theme.alpha(Theme.accent, 0.2) : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 8
                    spacing: 8
                    Icon {
                        text: Theme.ico.left
                        font.pixelSize: 11
                        color: Theme.accent
                    }
                    Txt {
                        text: "Indietro"
                        color: Theme.accent
                    }
                }
                HoverHandler { id: backHover }
                TapHandler {
                    onTapped: {
                        const s = root.stack.slice();
                        root.current = s.pop();
                        root.stack = s;
                    }
                }
            }

            Repeater {
                model: opener.children

                Item {
                    id: entry

                    required property var modelData

                    width: col.width
                    height: modelData.isSeparator ? 9 : 28

                    Rectangle {
                        visible: entry.modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width - 12
                        height: 1
                        color: Theme.alpha(Theme.dim, 0.5)
                    }

                    Rectangle {
                        anchors.fill: parent
                        visible: !entry.modelData.isSeparator
                        color: entryHover.hovered && entry.modelData.enabled ? Theme.alpha(Theme.accent, 0.2) : "transparent"

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            x: 8
                            spacing: 8

                            Item {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter

                                IconImage {
                                    anchors.fill: parent
                                    visible: entry.modelData.icon !== ""
                                    source: entry.modelData.icon
                                }
                                Icon {
                                    anchors.centerIn: parent
                                    visible: entry.modelData.icon === "" && entry.modelData.checkState === Qt.Checked
                                    text: Theme.ico.check
                                    font.pixelSize: 11
                                    color: Theme.accent
                                }
                            }

                            Txt {
                                anchors.verticalCenter: parent.verticalCenter
                                width: col.width - 16 - 8 - 8 - 8 - 14
                                text: entry.modelData.text.replace(/_/g, "")
                                elide: Text.ElideRight
                                color: entry.modelData.enabled ? Theme.fg : Theme.alpha(Theme.fg, 0.4)
                            }
                        }

                        Icon {
                            visible: entry.modelData.hasChildren
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: Theme.ico.right
                            font.pixelSize: 11
                            color: Theme.dim
                        }

                        HoverHandler {
                            id: entryHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            enabled: entry.modelData.enabled
                            onTapped: {
                                if (entry.modelData.hasChildren) {
                                    root.stack = root.stack.concat([root.current]);
                                    root.current = entry.modelData;
                                } else {
                                    entry.modelData.triggered();
                                    root.close();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
