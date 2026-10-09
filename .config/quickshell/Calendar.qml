import Quickshell
import QtQuick

Item {
    id: root

    // months away from the current one
    property int offset: 0
    readonly property date today: clock.date
    readonly property date viewDate: new Date(today.getFullYear(), today.getMonth() + offset, 1)
    readonly property int cellW: 32
    readonly property int cellH: 26
    readonly property int weekW: 26
    readonly property var days: {
        const first = viewDate;
        const lead = (first.getDay() + 6) % 7; // weeks start on Monday
        const out = [];
        for (let i = 0; i < 42; i++)
            out.push(new Date(first.getFullYear(), first.getMonth(), 1 - lead + i));
        return out;
    }

    function isoWeek(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
        const dow = t.getUTCDay() || 7;
        t.setUTCDate(t.getUTCDate() + 4 - dow);
        const y0 = new Date(Date.UTC(t.getUTCFullYear(), 0, 1));
        return Math.ceil(((t - y0) / 86400000 + 1) / 7);
    }

    function cap(s) {
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    implicitWidth: weekW + cellW * 7
    implicitHeight: header.height + 8 + cellH * 7

    Item {
        id: header
        width: parent.width
        height: 28

        Icon {
            id: prev
            anchors.verticalCenter: parent.verticalCenter
            text: Theme.ico.left
            font.pixelSize: 12
            width: 28
            color: prevHover.hovered ? Theme.accent : Theme.dim
            HoverHandler { id: prevHover; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: root.offset-- }
        }

        Txt {
            anchors.centerIn: parent
            text: `${root.cap(Qt.locale().standaloneMonthName(root.viewDate.getMonth(), Locale.LongFormat))} ${root.viewDate.getFullYear()}`
            font.bold: true
            color: root.offset === 0 ? Theme.fg : Theme.accent

            HoverHandler { cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: root.offset = 0 }
        }

        Icon {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Theme.ico.right
            font.pixelSize: 12
            width: 28
            color: nextHover.hovered ? Theme.accent : Theme.dim
            HoverHandler { id: nextHover; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: root.offset++ }
        }
    }

    // weekday names
    Row {
        y: header.height + 8
        x: root.weekW

        Repeater {
            model: [1, 2, 3, 4, 5, 6, 0]

            Txt {
                required property int modelData
                width: root.cellW
                height: root.cellH
                horizontalAlignment: Text.AlignHCenter
                text: root.cap(Qt.locale().dayName(modelData, Locale.ShortFormat)).slice(0, 3)
                font.pixelSize: 11
                color: modelData === 0 ? Theme.warm : Theme.accent
            }
        }
    }

    Repeater {
        model: 6

        Txt {
            required property int index
            x: 0
            y: header.height + 8 + root.cellH * (index + 1)
            width: root.weekW - 6
            height: root.cellH
            horizontalAlignment: Text.AlignRight
            text: root.isoWeek(root.days[index * 7 + 3])
            font.pixelSize: 10
            color: Theme.alpha(Theme.dim, 0.9)
        }
    }

    Repeater {
        model: root.days

        Item {
            required property var modelData
            required property int index
            readonly property bool inMonth: modelData.getMonth() === root.viewDate.getMonth()
            readonly property bool isToday: root.sameDay(modelData, root.today)
            readonly property bool weekend: modelData.getDay() === 0

            x: root.weekW + (index % 7) * root.cellW
            y: header.height + 8 + root.cellH * (Math.floor(index / 7) + 1)
            width: root.cellW
            height: root.cellH

            Rectangle {
                anchors.centerIn: parent
                width: 26
                height: 22
                color: Theme.accent
                opacity: parent.isToday ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            Txt {
                anchors.centerIn: parent
                text: parent.modelData.getDate()
                font.bold: parent.isToday
                color: parent.isToday ? Theme.bg
                    : !parent.inMonth ? Theme.alpha(Theme.dim, 0.55)
                    : parent.weekend ? Theme.warm : Theme.fg
            }
        }
    }

    WheelHandler {
        onWheel: event => root.offset += event.angleDelta.y > 0 ? -1 : 1
    }
}
