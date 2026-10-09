import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

Island {
    id: root

    readonly property var toplevel: Hyprland.activeToplevel
    readonly property var ipc: toplevel?.lastIpcObject
    readonly property string wanted: toplevel ? (ipc?.initialTitle || toplevel.title || "") : ""
    readonly property string wantedClass: ipc?.class ?? ""
    property string title: ""
    property string klass: ""

    readonly property var entry: klass !== "" ? DesktopEntries.heuristicLookup(klass) : null
    readonly property string iconSource: {
        if (klass === "")
            return "";
        return Quickshell.iconPath(entry?.icon ?? klass.toLowerCase(), true);
    }

    present: wanted !== ""
    onWantedChanged: swap.restart()
    Component.onCompleted: {
        title = wanted;
        klass = wantedClass;
    }

    SequentialAnimation {
        id: swap
        NumberAnimation { target: body; property: "opacity"; to: 0; duration: 90 }
        ScriptAction {
            script: {
                root.title = root.wanted;
                root.klass = root.wantedClass;
            }
        }
        NumberAnimation { target: body; property: "opacity"; to: 1; duration: 180 }
    }

    Row {
        id: body
        spacing: 8
        height: parent.height

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 16
            source: root.iconSource
            visible: root.iconSource !== ""
        }

        Txt {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 380)
            text: root.title
            elide: Text.ElideRight
        }
    }
}
