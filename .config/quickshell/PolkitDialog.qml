import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Polkit password prompt: full-screen dim + centered card on the focused screen, like PowerDialog.
PanelWindow {
    id: win

    required property var modelData
    readonly property bool active: PolkitAuth.active
    readonly property bool hasCard: Hyprland.focusedMonitor?.name === modelData.name
    readonly property var flow: PolkitAuth.flow
    readonly property string who: flow?.selectedIdentity?.displayName ?? Quickshell.env("USER") ?? ""

    function submit() {
        if (!flow || !flow.isResponseRequired) return;
        flow.submit(field.text);
        field.text = "";
    }

    function cancel() {
        field.text = "";
        flow?.cancelAuthenticationRequest();
    }

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
    WlrLayershell.namespace: "qs-polkit"
    WlrLayershell.keyboardFocus: active && hasCard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onActiveChanged: {
        field.text = "";
        if (active && hasCard) field.forceActiveFocus();
    }

    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Theme.alpha(Theme.bg, 0.55)
        opacity: win.active ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 220 }
        }
    }

    FocusScope {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: win.cancel()

        Rectangle {
            id: card
            visible: win.hasCard
            anchors.centerIn: parent
            width: 400
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

            TapHandler { onTapped: field.forceActiveFocus() }

            Column {
                id: content
                anchors.horizontalCenter: parent.horizontalCenter
                y: 28
                width: parent.width - 56
                spacing: 14

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 56
                    height: 56
                    radius: 28
                    color: Theme.raised

                    Icon {
                        anchors.centerIn: parent
                        text: Theme.ico.shield
                        font.pixelSize: 26
                        color: win.flow?.failed ? Theme.danger : Theme.accent
                    }
                }

                Txt {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "Autenticazione richiesta"
                    font.pixelSize: 16
                    font.bold: true
                }

                Txt {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    lineHeight: 1.25
                    text: win.flow?.message ?? ""
                    font.pixelSize: 12
                    color: Theme.alpha(Theme.fg, 0.75)
                }

                Txt {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: `come ${win.who}`
                    font.pixelSize: 11
                    color: Theme.dim
                }

                // password field
                Rectangle {
                    width: parent.width
                    height: 36
                    color: Theme.raised
                    border.width: 1
                    border.color: win.flow?.failed ? Theme.danger
                        : field.activeFocus ? Theme.accent : "transparent"

                    Behavior on border.color {
                        ColorAnimation { duration: 120 }
                    }

                    TextInput {
                        id: field
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.fg
                        font.family: Theme.textFont
                        font.pixelSize: 13
                        echoMode: win.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                        passwordCharacter: "•"
                        enabled: win.flow?.isResponseRequired ?? false
                        selectionColor: Theme.accent
                        clip: true

                        Keys.onReturnPressed: win.submit()
                        Keys.onEnterPressed: win.submit()
                        Keys.onEscapePressed: win.cancel()

                        Txt {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: field.text === ""
                            text: (win.flow?.inputPrompt ?? "Password").replace(/:\s*$/, "")
                            color: Theme.dim
                        }
                    }
                }

                Txt {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    visible: text !== ""
                    text: win.flow?.failed ? "Password errata, riprova" : (win.flow?.supplementaryMessage ?? "")
                    font.pixelSize: 12
                    color: win.flow?.failed || win.flow?.supplementaryIsError ? Theme.danger : Theme.dim
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Repeater {
                        model: [
                            { primary: false, label: "Annulla" },
                            { primary: true, label: "Autentica" }
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
                                onTapped: btn.modelData.primary ? win.submit() : win.cancel()
                            }
                        }
                    }
                }
            }
        }
    }
}
