// Derived from LoginForm.qml of Keyitdev's astronaut theme (Copyright (C) 2022-2025 Keyitdev, GPLv3+).
// System buttons and virtual-keyboard button are not used:
// kept as empty spacers so the layout keeps its proportions.

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: formContainer

    property bool clockOnly: false
    property int p: config.screenPadding == "" ? 0 : config.screenPadding
    property string a: config.formPosition

    Clock {
        id: clock
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        Layout.preferredHeight: root.height / 3
        Layout.leftMargin: p != "0" ? a == "left" ? -p : a == "right" ? p : 0 : 0
    }

    Input {
        id: input
        opacity: clockOnly ? 0 : 1
        enabled: !clockOnly
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredHeight: root.height / 10
        Layout.leftMargin: p != "0" ? a == "left" ? -p : a == "right" ? p : 0 : 0
        Layout.topMargin: 0
    }

    Item { // SystemButtons placeholder
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        Layout.preferredHeight: root.height / 5
        Layout.maximumHeight: root.height / 5
    }

    SessionButton {
        id: sessionSelect
        opacity: clockOnly ? 0 : 1
        enabled: !clockOnly
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        Layout.preferredHeight: root.height / 54
        Layout.maximumHeight: root.height / 54
        Layout.leftMargin: p != "0" ? a == "left" ? -p : a == "right" ? p : 0 : 0
    }

    Item { // VirtualKeyboardButton placeholder
        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        Layout.preferredHeight: root.height / 27
        Layout.maximumHeight: root.height / 27
    }
}
