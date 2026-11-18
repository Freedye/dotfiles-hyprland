import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// One notification. As a popup it hides itself after its timeout (paused on hover).
// Left click: default action. Right click or ×: dismiss.
Rectangle {
    id: root

    required property var notif
    property bool popup: false

    readonly property bool critical: notif && notif.urgency === NotificationUrgency.Critical
    readonly property var otherActions: notif ? notif.actions.filter(a => a.identifier !== "default") : []
    readonly property string iconSource: {
        if (!notif) return "";
        if (notif.image !== "") return notif.image;
        const i = notif.appIcon;
        if (i === "") return "";
        if (i.startsWith("/") || i.startsWith("file://")) return i;
        return Quickshell.iconPath(i, true);
    }

    width: 340
    height: body.implicitHeight + 20
    color: Theme.alpha(Theme.bg, 0.985)
    border.width: 1
    border.color: critical ? Theme.danger : Theme.alpha(Theme.dim, 0.55)

    function invokeDefault() {
        const def = notif.actions.find(a => a.identifier === "default");
        if (def) def.invoke();
        else notif.dismiss();
    }

    Timer {
        running: root.popup && !hover.hovered && Notifs.timeout(root.notif) > 0
        interval: Notifs.timeout(root.notif)
        onTriggered: Notifs.hide(root.notif)
    }

    // same hover as the menus: thin accent edge
    Rectangle {
        width: 3
        height: parent.height
        color: root.critical ? Theme.danger : Theme.accent
        opacity: hover.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.invokeDefault()
    }
    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: root.notif.dismiss()
    }

    Row {
        id: body
        x: 14
        y: 10
        width: parent.width - 28
        spacing: 12

        Image {
            id: icon
            visible: root.iconSource !== ""
            width: visible ? 40 : 0
            height: 40
            source: root.iconSource
            sourceSize: Qt.size(80, 80)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }

        Column {
            width: body.width - (icon.visible ? icon.width + body.spacing : 0)
            spacing: 3

            Item {
                width: parent.width
                height: app.implicitHeight

                Txt {
                    id: app
                    width: parent.width - 20
                    text: root.notif ? root.notif.appName : ""
                    font.pixelSize: 11
                    color: Theme.dim
                    elide: Text.ElideRight
                }
                Icon {
                    anchors.right: parent.right
                    anchors.verticalCenter: app.verticalCenter
                    text: Theme.ico.close
                    font.pixelSize: 13
                    color: closeHover.hovered ? Theme.danger : Theme.dim
                    opacity: hover.hovered ? 1 : 0
                    HoverHandler { id: closeHover }
                    TapHandler { onTapped: root.notif.dismiss() }
                }
            }

            Txt {
                width: parent.width
                text: root.notif ? root.notif.summary : ""
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Txt {
                width: parent.width
                visible: text !== ""
                text: root.notif ? root.notif.body : ""
                textFormat: Text.StyledText
                color: Theme.alpha(Theme.fg, 0.8)
                linkColor: Theme.accent
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Row {
                visible: root.otherActions.length > 0
                topPadding: 4
                spacing: 6

                Repeater {
                    model: root.otherActions

                    Rectangle {
                        id: btn
                        required property var modelData
                        width: label.implicitWidth + 20
                        height: 24
                        color: btnHover.hovered ? Theme.dim : Theme.raised
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Txt {
                            id: label
                            anchors.centerIn: parent
                            text: btn.modelData.text
                            font.pixelSize: 12
                        }
                        HoverHandler { id: btnHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: btn.modelData.invoke() }
                    }
                }
            }
        }
    }
}
