// Lain lockscreen view: same palette and layout as the greetd login screen.

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

Item {
    id: root

    property bool showForm: true

    readonly property color textColor: "#c1b492"
    readonly property color fieldColor: "#2a1d1f"
    readonly property color placeholderColor: "#7d6f66"
    readonly property color accent: "#d27389"
    readonly property string textFont: "arcadeclassic"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property real pt: 11

    focus: true

    // Typing works on every monitor: keys go to the shared password.
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            shell.submit();
        } else if (event.key === Qt.Key_Backspace) {
            if (event.modifiers & Qt.ControlModifier) shell.password = "";
            else shell.password = shell.password.slice(0, -1);
        } else if (event.key === Qt.Key_Escape) {
            shell.password = "";
        } else if (event.text.length > 0 && event.text.charCodeAt(0) >= 32 && !shell.busy) {
            shell.password += event.text;
        } else {
            return;
        }
        event.accepted = true;
    }

    Image {
        visible: root.showForm
        anchors.fill: parent
        source: Qt.resolvedUrl("lain.jpg")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        mipmap: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.forceActiveFocus()
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Left column, proportions of the login screen form.
    ColumnLayout {
        visible: root.showForm
        width: parent.width / 2.5
        height: parent.height
        spacing: 5

        Column {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.preferredHeight: root.height / 3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(clock.date, "HH:mm")
                color: root.textColor
                font.family: root.textFont
                font.pointSize: root.pt * 9
                font.bold: true
                renderType: Text.QtRendering
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                // Accents stripped ("lunedì" -> "lunedi"): ArcadeClassic has ASCII letters only.
                text: clock.date.toLocaleDateString(Qt.locale("it_IT"), "dddd d")
                    .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                color: root.textColor
                font.family: root.textFont
                font.pointSize: root.pt * 2
                font.bold: true
                renderType: Text.QtRendering
            }
        }

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: root.height / 10

            Item { // error line, with the profile picture floating above it
                width: parent.width / 2
                height: root.pt * 2
                anchors.horizontalCenter: parent.horizontalCenter

                // Profile picture in a circle, outside the layout so the rest stays where it is.
                Item {
                    id: avatar
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.top
                    anchors.bottomMargin: 24
                    width: 95
                    height: 95
                    visible: picture.status === Image.Ready

                    Image {
                        id: picture
                        anchors.fill: parent
                        // same picture as the login screen
                        source: "file:///var/lib/AccountsService/icons/" + shell.user
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(190, 190)
                        asynchronous: true
                        mipmap: true
                        visible: false
                    }
                    Rectangle {
                        id: circle
                        anchors.fill: parent
                        radius: width / 2
                        visible: false
                        layer.enabled: true
                    }
                    MultiEffect {
                        anchors.fill: parent
                        source: picture
                        maskEnabled: true
                        maskSource: circle
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }
                    Rectangle { // ring
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.width: 2
                        border.color: root.textColor
                    }
                }

                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: shell.errorText
                    opacity: shell.errorText !== "" ? 1 : 0
                    color: root.accent
                    font.family: root.textFont
                    font.pointSize: root.pt * 0.8
                    font.italic: true
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
            }

            Field { // user (read-only)
                glyph: ""
                text: shell.user.toLowerCase()
            }

            Field { // password
                glyph: shell.revealed ? "" : ""
                glyphColor: eye.containsMouse || shell.busy ? root.accent : root.textColor
                text: shell.password === "" ? "Password"
                    : shell.revealed ? shell.password : "•".repeat(shell.password.length)
                textColor: shell.password === "" ? root.placeholderColor : root.textColor
                caret: !shell.busy

                MouseArea {
                    id: eye
                    width: parent.height
                    height: parent.height
                    hoverEnabled: true
                    onClicked: shell.revealed = !shell.revealed
                }
            }
        }

        Item { Layout.preferredHeight: root.height / 5; Layout.maximumHeight: root.height / 5 }
        Item { Layout.preferredHeight: root.height / 54; Layout.maximumHeight: root.height / 54 }
        Item { Layout.preferredHeight: root.height / 27; Layout.maximumHeight: root.height / 27 }
    }

    component Field: Item {
        id: field

        property string glyph
        property color glyphColor: root.textColor
        property string text
        property color textColor: root.textColor
        property bool caret: false

        width: parent.width / 2
        height: root.pt * 4.5
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: root.pt * 3
            radius: 20
            color: root.fieldColor
            opacity: 0.2
        }

        Text {
            width: parent.height
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: field.glyph
            color: field.glyphColor
            font.family: root.iconFont
            font.pixelSize: parent.height * 0.25
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Row {
            anchors.centerIn: parent
            Text {
                id: label
                text: field.text
                color: field.textColor
                font.family: root.textFont
                font.pointSize: root.pt
                font.bold: true
                renderType: Text.QtRendering
            }
            Rectangle {
                visible: field.caret
                width: 1
                height: label.height
                color: root.textColor
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0; duration: 500 }
                    NumberAnimation { to: 1; duration: 500 }
                }
            }
        }
    }
}
