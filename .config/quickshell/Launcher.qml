import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// App launcher (replaces wofi): `qs ipc call launcher toggle`, bound to SUPER+SPACE.
// Type to search, Up/Down (or Tab) to move, Enter to launch, Esc or click outside to close.
Scope {
    id: root

    property bool open: false
    property string query: ""
    property int current: 0
    readonly property int rows: 8
    readonly property int rowHeight: 40

    // from scripts/launcher-index.sh: entries wofi would hide, and icons of the GTK icon theme
    property var hidden: ({})
    property var icons: ({})

    readonly property var apps: DesktopEntries.applications.values
        .filter(a => !a.noDisplay && !hidden[a.id])
        .sort((a, b) => a.name.localeCompare(b.name))

    function iconFor(app) {
        const i = app.icon;
        if (!i) return "";
        if (i.startsWith("/")) return "file://" + i;
        if (icons[i]) return "file://" + icons[i];
        return Quickshell.iconPath(i, true);
    }

    Process {
        id: index
        running: true
        command: [Quickshell.shellDir + "/scripts/launcher-index.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                const h = {}, ic = {};
                for (const line of text.split("\n")) {
                    const f = line.split("\t");
                    if (f[0] === "H") h[f[1]] = true;
                    else if (f[0] === "I" && !(f[1] in ic)) ic[f[1]] = f[2];
                }
                root.hidden = h;
                root.icons = ic;
            }
        }
    }

    // re-index when apps are installed or removed
    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { index.running = true; }
    }

    // name prefix > word prefix > name contains > other fields contain
    readonly property var results: {
        const q = query.trim().toLowerCase();
        if (q === "") return apps;
        const scored = [];
        for (const a of apps) {
            const name = a.name.toLowerCase();
            let score = -1;
            if (name.startsWith(q)) score = 0;
            else if (name.split(/\s+/).some(w => w.startsWith(q))) score = 1;
            else if (name.includes(q)) score = 2;
            else if ([a.genericName, a.comment, ...a.keywords].join(" ").toLowerCase().includes(q)) score = 3;
            if (score >= 0) scored.push({ a, score });
        }
        return scored.sort((x, y) => x.score - y.score || x.a.name.localeCompare(y.a.name)).map(x => x.a);
    }

    onQueryChanged: current = 0

    function toggle() {
        if (open) { open = false; return; }
        query = "";
        current = 0;
        const mon = Hyprland.focusedMonitor?.name;
        win.screen = Quickshell.screens.find(s => s.name === mon) ?? Quickshell.screens[0];
        open = true;
    }

    function launch(app) {
        if (!app) return;
        open = false;
        if (app.runInTerminal)
            Quickshell.execDetached(["kitty", "-e", ...app.command]);
        else
            app.execute();
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.toggle(); }
    }

    PanelWindow {
        id: win

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: root.open
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-launcher"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        // click outside the card closes
        TapHandler {
            onTapped: root.open = false
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: 500
            height: search.height + 8 + list.height + 20
            color: Theme.raised
            border.width: 1
            border.color: Theme.dim

            TapHandler {} // swallow clicks on the card

            // search field
            Rectangle {
                id: search
                x: 8
                y: 8
                width: parent.width - 16
                height: 44
                color: Theme.dim

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.fg
                }

                Icon {
                    id: glass
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: Theme.ico.search
                    font.pixelSize: 15
                }

                TextInput {
                    id: input
                    anchors.left: glass.right
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.fg
                    font.family: Theme.textFont
                    font.pixelSize: 14
                    selectionColor: Theme.accent
                    clip: true
                    focus: root.open
                    text: root.query
                    onTextChanged: root.query = text

                    Keys.onEscapePressed: root.open = false
                    Keys.onReturnPressed: root.launch(root.results[root.current])
                    Keys.onEnterPressed: root.launch(root.results[root.current])
                    Keys.onDownPressed: root.current = Math.min(root.current + 1, root.results.length - 1)
                    Keys.onUpPressed: root.current = Math.max(root.current - 1, 0)
                    Keys.onTabPressed: root.current = (root.current + 1) % Math.max(1, root.results.length)
                    Keys.onBacktabPressed: root.current = (root.current - 1 + root.results.length) % Math.max(1, root.results.length)

                    Txt {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: input.text === ""
                        text: "Ricerca"
                        font.pixelSize: 14
                        color: Theme.alpha(Theme.fg, 0.5)
                    }
                }
            }

            ListView {
                id: list
                anchors.top: search.bottom
                anchors.topMargin: 12
                x: 12
                width: parent.width - 24
                height: root.rows * root.rowHeight
                clip: true
                model: root.results
                currentIndex: root.current
                boundsBehavior: Flickable.StopAtBounds
                highlightMoveDuration: 0

                Txt {
                    anchors.centerIn: parent
                    visible: root.results.length === 0
                    text: "Nessun risultato"
                    color: Theme.dim
                }

                delegate: Rectangle {
                    id: row

                    required property var modelData
                    required property int index
                    readonly property bool selected: index === root.current

                    width: list.width
                    height: root.rowHeight
                    color: selected ? Theme.dim : "transparent"

                    // same selection as the bar menus: dim fill with a thin accent edge
                    Rectangle {
                        width: 3
                        height: parent.height
                        color: Theme.accent
                        visible: row.selected
                    }

                    Image {
                        id: appIcon
                        x: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24
                        source: root.iconFor(row.modelData)
                        sourceSize: Qt.size(48, 48)
                        asynchronous: true
                    }

                    Txt {
                        anchors.left: appIcon.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.name
                        font.pixelSize: 14
                        font.bold: row.selected
                        elide: Text.ElideRight
                    }

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                        onHoveredChanged: if (hovered) root.current = row.index
                    }
                    TapHandler {
                        onTapped: root.launch(row.modelData)
                    }
                }
            }
        }
    }
}
