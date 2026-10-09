import QtQuick
import Quickshell

Island {
    id: root

    property bool alt: false

    cursor: Qt.PointingHandCursor

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        visible: !root.alt

        Txt {
            text: Qt.formatTime(clock.date, "HH")
            font.bold: true
        }
        Txt {
            text: ":"
            font.bold: true
            color: Theme.accent
            opacity: clock.seconds % 2 === 0 ? 1 : 0.25

            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
        }
        Txt {
            text: Qt.formatTime(clock.date, "mm")
            font.bold: true
        }
    }

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.alt
        text: Qt.formatDate(clock.date, "yyyy-MM-dd")
        font.bold: true
    }

    overlay: [
        TapHandler {
            onTapped: root.alt = !root.alt
        },
        WheelHandler {
            onWheel: event => cal.offset += event.angleDelta.y > 0 ? -1 : 1
        }
    ]

    Tip {
        id: tip
        target: root
        show: root.hovered
        openDelay: 150
        onWantChanged: if (!want) cal.offset = 0

        Calendar {
            id: cal
        }
    }
}
