// Derived from Main.qml of Keyitdev's astronaut theme (Copyright (C) 2022-2025 Keyitdev, GPLv3+).

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "Components"

Pane {
    id: root

    property bool showForm: true

    padding: config.screenPadding === "" ? 0 : config.screenPadding

    palette.window: config.backgroundColor
    palette.highlight: config.highlightBackgroundColor
    palette.highlightedText: config.highlightTextColor
    palette.buttonText: config.hoverSystemButtonsIconsColor

    font.family: config.font
    font.pointSize: config.fontSize !== "" ? config.fontSize : parseInt(height / 80) || 13

    focus: true

    Item {
        id: sizeHelper
        anchors.fill: parent

        Rectangle {
            id: tintLayer
            anchors.fill: parent
            z: 1
            color: config.dimBackgroundColor
            opacity: config.dimBackground
        }

        LoginForm {
            id: form
            // Secondary monitors: clock only, laid out exactly as on the primary.
            clockOnly: !root.showForm
            height: parent.height
            width: parent.width / 2.5
            anchors.left: config.formPosition == "left" ? parent.left : undefined
            anchors.horizontalCenter: config.formPosition == "center" ? parent.horizontalCenter : undefined
            anchors.right: config.formPosition == "right" ? parent.right : undefined
            z: 1
        }

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: config.background
            horizontalAlignment: config.backgroundHorizontalAlignment == "left" ? Image.AlignLeft
                               : config.backgroundHorizontalAlignment == "right" ? Image.AlignRight : Image.AlignHCenter
            verticalAlignment: config.backgroundVerticalAlignment == "top" ? Image.AlignTop
                             : config.backgroundVerticalAlignment == "bottom" ? Image.AlignBottom : Image.AlignVCenter
            fillMode: config.cropBackground == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            asynchronous: true
            cache: true
            clip: true
            mipmap: true
        }

        MouseArea {
            anchors.fill: backgroundImage
            onClicked: parent.forceActiveFocus()
        }
    }
}
