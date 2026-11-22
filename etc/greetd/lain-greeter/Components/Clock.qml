// Config created by Keyitdev https://github.com/Keyitdev/sddm-astronaut-theme
// Copyright (C) 2022-2025 Keyitdev
// Based on https://github.com/MarianArlt/sddm-sugar-dark
// Distributed under the GPLv3+ License https://www.gnu.org/licenses/gpl-3.0.html

import QtQuick
import QtQuick.Controls

Column {
    id: clock

    width: parent.width / 2
    spacing: 0

    Label {
        id:headerTextLabel

        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: root.font.pointSize * 3
        color: config.headerTextColor
        renderType: Text.QtRendering
        text: config.headerText
    }

    Label {
        id: timeLabel

        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: root.font.pointSize * 9
        font.bold: true
        color: config.timeTextColor
        renderType: Text.QtRendering

        function updateTime() {
            text = new Date().toLocaleTimeString(Qt.locale(config.locale), config.hourFormat == "long" ? Locale.LongFormat : config.hourFormat !== "" ? config.hourFormat : Locale.ShortFormat)
        }
    }

    Label {
        id: dateLabel

        anchors.horizontalCenter: parent.horizontalCenter
        
        color: config.dateTextColor
        font.pointSize: root.font.pointSize * 2
        font.bold: true
        renderType: Text.QtRendering

        function updateTime() {
            // Accents stripped ("lunedì" -> "lunedi"): ArcadeClassic has ASCII letters only.
            text = new Date().toLocaleDateString(Qt.locale(config.locale), config.dateFormat == "short" ? Locale.ShortFormat : config.dateFormat !== "" ? config.dateFormat : Locale.LongFormat)
                .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            dateLabel.updateTime()
            timeLabel.updateTime()
        }
    }

    Component.onCompleted: {
        dateLabel.updateTime()
        timeLabel.updateTime()
    }
}
