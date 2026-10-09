import QtQuick
import Quickshell

// A card that fades in under `target` while `show` is true (and stays while the pointer is on the card).
PopupWindow {
    id: root

    required property Item target
    property bool show: false
    property int openDelay: 280
    property int gap: 8
    property bool want: false
    default property alias data: col.data

    readonly property bool inside: cardHover.hovered

    function evaluate() {
        if (show || inside) {
            closeTimer.stop();
            if (!want)
                openTimer.restart();
        } else {
            openTimer.stop();
            closeTimer.restart();
        }
    }

    onShowChanged: evaluate()
    onInsideChanged: evaluate()

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.Slide
    color: "transparent"
    visible: want || card.opacity > 0.01
    implicitWidth: card.width
    implicitHeight: card.height + gap

    Timer {
        id: openTimer
        interval: root.openDelay
        onTriggered: root.want = true
    }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: root.want = false
    }

    Rectangle {
        id: card
        y: root.gap + (root.want ? 0 : -6)
        width: col.implicitWidth + 28
        height: col.implicitHeight + 20
        color: Theme.alpha(Theme.bg, 0.985)
        border.width: 1
        border.color: Theme.alpha(Theme.dim, 0.55)
        opacity: root.want ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 160 }
        }
        Behavior on y {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Column {
            id: col
            x: 14
            y: 10
            spacing: 4
        }

        HoverHandler {
            id: cardHover
        }
    }
}
