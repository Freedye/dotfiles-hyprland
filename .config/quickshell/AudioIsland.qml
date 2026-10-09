import QtQuick
import Quickshell

Island {
    id: root

    readonly property real vol: Audio.volume
    readonly property bool muted: Audio.muted
    readonly property string glyph: {
        if (muted)
            return Theme.ico.volMute;
        if (Audio.formFactor === "headphone")
            return Theme.ico.headphones;
        if (Audio.formFactor === "headset")
            return Theme.ico.headset;
        if (vol < 0.01)
            return Theme.ico.volOff;
        return vol < 0.34 ? Theme.ico.volLow : vol < 0.67 ? Theme.ico.volMed : Theme.ico.volHigh;
    }
    property bool dragging: false

    readonly property int trackX: 4
    readonly property int trackW: 76

    // 0..1, drives the slider unfolding; the island follows it directly instead of animating twice
    property real reveal: hovered || dragging ? 1 : 0

    function seek(x) {
        Audio.setVolume((x - trackX) / trackW);
    }

    cursor: Qt.PointingHandCursor
    spacing: 0
    animateWidth: false

    Behavior on reveal {
        NumberAnimation { duration: 340; easing.type: Easing.OutCubic }
    }

    // slider that unfolds to the left on hover
    Item {
        id: sliderHost
        anchors.verticalCenter: parent.verticalCenter
        width: (root.trackX + root.trackW + 14) * root.reveal
        height: 20
        clip: true
        opacity: root.reveal

        Rectangle {
            id: track
            x: root.trackX
            width: root.trackW
            height: 4
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.alpha(Theme.dim, 0.4)

            Rectangle {
                width: parent.width * root.vol
                height: parent.height
                color: root.muted ? Theme.dim : Theme.accent

                Behavior on width {
                    NumberAnimation { duration: 80 }
                }
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }

            Rectangle {
                x: parent.width * root.vol - width / 2
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 12
                color: Theme.fg
                scale: slide.pressed ? 1.25 : 1

                Behavior on scale {
                    NumberAnimation { duration: 120 }
                }
            }
        }
    }

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        rightPadding: 10
        horizontalAlignment: Text.AlignRight
        text: `${Math.round(root.vol * 100)}%`
        color: root.muted ? Theme.alpha(Theme.fg, 0.45) : Theme.fg
        font.strikeout: root.muted
    }

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        width: 12
        horizontalAlignment: Text.AlignLeft
        text: root.glyph
        color: root.muted ? Theme.alpha(Theme.fg, 0.45) : Theme.accent
    }

    overlay: [
        // Windows-style slider: press anywhere on the track to jump there, then drag; hovering alone never changes it.
        // It lives in the overlay because the overlay sits above the row and would otherwise swallow the pointer.
        MouseArea {
            id: slide
            x: root.padding
            width: sliderHost.width
            height: root.height
            enabled: root.reveal > 0.6
            hoverEnabled: true
            preventStealing: true
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => {
                root.dragging = true;
                root.seek(mouse.x);
            }
            onPositionChanged: mouse => {
                if (pressed)
                    root.seek(mouse.x);
            }
            onReleased: root.dragging = false
            onCanceled: root.dragging = false
        },
        WheelHandler {
            onWheel: event => Audio.nudge(event.angleDelta.y > 0 ? 0.02 : -0.02)
        },
        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: {
                if (!slide.containsMouse && !slide.pressed)
                    Quickshell.execDetached(["pavucontrol"]);
            }
        },
        TapHandler {
            acceptedButtons: Qt.MiddleButton
            onTapped: Audio.toggleMute()
        },
        // live output level as a thin line along the bottom edge
        Rectangle {
            y: root.height - 2
            visible: Audio.peakOk
            width: root.width * Audio.level
            height: 2
            color: Theme.alpha(Theme.accent, 0.8)

            Behavior on width {
                NumberAnimation { duration: 70 }
            }
        }
    ]
}
