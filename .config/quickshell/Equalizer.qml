import QtQuick

// Little bars that dance with the real output level of the default sink.
Item {
    id: root

    property bool active: false
    property real level: 0
    property int bars: 4
    property real t: 0
    property real amp: active ? 1 : 0

    implicitWidth: bars * 3 + (bars - 1) * 2
    implicitHeight: 14

    Behavior on amp {
        NumberAnimation { duration: 400 }
    }

    FrameAnimation {
        running: root.active || root.amp > 0.01
        onTriggered: root.t += frameTime
    }

    Row {
        anchors.bottom: parent.bottom
        spacing: 2

        Repeater {
            model: root.bars

            Rectangle {
                required property int index
                readonly property real wobble: 0.5 + 0.5 * Math.sin(root.t * (5 + index * 1.7) + index * 1.9)

                width: 3
                color: Theme.accent
                height: 3 + (root.height - 3) * root.amp * Math.min(1, (0.18 + 0.82 * root.level) * (0.3 + 0.7 * wobble))

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
            }
        }
    }
}
