import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Full-screen dim + centered confirmation card, one window per screen.
PanelWindow {
    id: win

    required property var modelData
    readonly property bool active: Session.pending !== ""
    readonly property bool hasCard: Hyprland.focusedMonitor?.name === modelData.name
    readonly property var action: Session.current ?? lastAction
    property var lastAction: null

    onActionChanged: if (Session.current) lastAction = Session.current

    screen: modelData
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: active || scrim.opacity > 0.01
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-power"
    WlrLayershell.keyboardFocus: active && hasCard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Theme.alpha(Theme.bg, 0.55)
        opacity: win.active ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 220 }
        }

        TapHandler {
            onTapped: Session.cancel()
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: Session.cancel()
        Keys.onReturnPressed: Session.confirm()
        Keys.onEnterPressed: Session.confirm()

        Rectangle {
            id: card
            visible: win.hasCard && win.action !== null
            anchors.centerIn: parent
            width: 380
            height: content.implicitHeight + 56
            color: Theme.alpha(Theme.bg, 0.97)
            border.width: 1
            border.color: Theme.alpha(Theme.dim, 0.6)
            opacity: win.active ? 1 : 0
            scale: win.active ? 1 : 0.92

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            Behavior on scale {
                NumberAnimation { duration: 280; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }

            // swallow clicks so the scrim doesn't cancel when the card is clicked
            TapHandler {}

            Column {
                id: content
                anchors.horizontalCenter: parent.horizontalCenter
                y: 28
                width: parent.width - 56
                spacing: 14

                // icon with a ring that drains as the countdown runs out
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 76
                    height: 76

                    Canvas {
                        id: ring
                        anchors.fill: parent
                        readonly property real frac: Session.remaining / Session.timeout
                        onFracChanged: requestPaint()
                        Component.onCompleted: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.lineWidth = 3;
                            ctx.lineCap = "round";
                            ctx.strokeStyle = Theme.alpha(Theme.dim, 0.35);
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, width / 2 - 3, 0, Math.PI * 2);
                            ctx.stroke();
                            ctx.strokeStyle = Theme.accent;
                            ctx.beginPath();
                            ctx.arc(width / 2, height / 2, width / 2 - 3, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * frac);
                            ctx.stroke();
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 56
                        height: 56
                        radius: 28
                        color: Theme.raised

                        Icon {
                            anchors.centerIn: parent
                            text: win.action?.glyph ?? ""
                            font.pixelSize: 26
                            color: Theme.accent
                        }
                    }
                }

                Txt {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: win.action?.title ?? ""
                    font.pixelSize: 16
                    font.bold: true
                }

                Txt {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.25
                    text: `Se non fai nulla, ${win.action?.what ?? ""} automaticamente tra ${Session.remaining} ${Session.remaining === 1 ? "secondo" : "secondi"}.`
                    font.pixelSize: 12
                    color: Theme.alpha(Theme.fg, 0.65)
                }

                Item {
                    width: 1
                    height: 2
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Repeater {
                        model: [
                            { primary: false, label: "Annulla" },
                            { primary: true, label: win.action?.label ?? "" }
                        ]

                        Rectangle {
                            id: btn

                            required property var modelData

                            width: (content.width - 10) / 2
                            height: 36
                            color: modelData.primary ? (hover.hovered ? Theme.mix(Theme.accent, Theme.fg, 0.2) : Theme.accent)
                                : (hover.hovered ? Theme.alpha(Theme.fg, 0.18) : Theme.raised)
                            scale: press.pressed ? 0.97 : 1

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                            Behavior on scale {
                                NumberAnimation { duration: 90 }
                            }

                            Txt {
                                anchors.centerIn: parent
                                text: btn.modelData.label
                                font.bold: btn.modelData.primary
                                color: btn.modelData.primary ? Theme.bg : Theme.fg
                            }

                            HoverHandler {
                                id: hover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                id: press
                                onTapped: btn.modelData.primary ? Session.confirm() : Session.cancel()
                            }
                        }
                    }
                }
            }
        }
    }
}
