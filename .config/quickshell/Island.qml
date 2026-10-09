import QtQuick

// A flat bar segment. Children go into a Row; `overlay` items are stacked on top and fill the segment.
Rectangle {
    id: root

    property int appearDelay: 0
    property int padding: 8
    property int spacing: 10
    property bool animateWidth: true
    property bool present: true
    property bool shown: false
    property alias hovered: hover.hovered
    property alias cursor: hover.cursorShape
    default property alias content: row.data
    property alias overlay: overlayHost.data

    implicitHeight: Theme.barHeight
    implicitWidth: present ? row.implicitWidth + padding * 2 : 0
    color: "transparent"

    opacity: shown && present ? 1 : 0
    visible: opacity > 0.01

    Behavior on opacity {
        NumberAnimation { duration: 320 }
    }
    Behavior on implicitWidth {
        enabled: root.animateWidth
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }

    Timer {
        interval: root.appearDelay + 30
        running: true
        onTriggered: root.shown = true
    }

    Row {
        id: row
        x: root.padding
        height: parent.height
        spacing: root.spacing
    }

    Item {
        id: overlayHost
        anchors.fill: parent
        z: 10
    }

    HoverHandler {
        id: hover
    }
}
