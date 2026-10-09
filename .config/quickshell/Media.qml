import QtQuick
import Quickshell.Services.Mpris

Island {
    id: root

    readonly property var player: {
        const ps = Mpris.players.values;
        return ps.find(p => p.isPlaying) ?? ps[0] ?? null;
    }
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""
    readonly property real progress: {
        if (!player || !player.positionSupported || !player.lengthSupported || player.length <= 0)
            return 0;
        return Math.max(0, Math.min(1, player.position / player.length));
    }

    present: player !== null && title !== ""
    cursor: Qt.PointingHandCursor

    Timer {
        interval: 1000
        repeat: true
        running: root.playing && root.present
        onTriggered: root.player.positionChanged()
    }

    Equalizer {
        anchors.verticalCenter: parent.verticalCenter
        active: root.playing
        level: Audio.peakOk ? Audio.level : 0.55
    }

    Txt {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 300)
        text: root.artist !== "" ? `${root.title}  ·  ${root.artist}` : root.title
        elide: Text.ElideRight
        color: root.playing ? Theme.fg : Theme.alpha(Theme.fg, 0.6)

        TapHandler {
            onTapped: root.player?.togglePlaying()
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: root.player?.next()
        }
        TapHandler {
            acceptedButtons: Qt.MiddleButton
            onTapped: root.player?.previous()
        }
    }

    // transport controls slide out on hover
    Item {
        id: controls
        anchors.verticalCenter: parent.verticalCenter
        width: root.hovered ? ctl.implicitWidth : 0
        height: parent.height
        clip: true
        opacity: root.hovered ? 1 : 0

        Behavior on width {
            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Row {
            id: ctl
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Repeater {
                model: [
                    { glyph: Theme.ico.prev, act: 0 },
                    { glyph: root.playing ? Theme.ico.pause : Theme.ico.play, act: 1 },
                    { glyph: Theme.ico.next, act: 2 }
                ]

                Icon {
                    required property var modelData

                    text: modelData.glyph
                    font.pixelSize: 13
                    width: 20
                    color: btn.hovered ? Theme.accent : Theme.fg

                    HoverHandler {
                        id: btn
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: {
                            if (modelData.act === 0)
                                root.player?.previous();
                            else if (modelData.act === 1)
                                root.player?.togglePlaying();
                            else
                                root.player?.next();
                        }
                    }
                }
            }
        }
    }

    overlay: Rectangle {
        y: root.height - 2
        width: root.width * root.progress
        height: 2
        color: Theme.alpha(Theme.accent, 0.85)

        Behavior on width {
            NumberAnimation { duration: 900 }
        }
    }
}
