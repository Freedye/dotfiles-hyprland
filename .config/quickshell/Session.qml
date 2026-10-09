pragma Singleton

import QtQuick
import Quickshell

// Power actions. Shutdown / restart / logout ask for confirmation first, like macOS.
Singleton {
    id: root

    readonly property int timeout: 60
    property string pending: ""
    property int remaining: timeout
    readonly property string user: Quickshell.env("USER")

    readonly property var actions: ({
        poweroff: {
            label: "Spegni",
            title: "Vuoi spegnere il computer adesso?",
            what: "il computer si spegnerà",
            glyph: Theme.ico.power,
            cmd: ["systemctl", "poweroff"]
        },
        reboot: {
            label: "Riavvia",
            title: "Vuoi riavviare il computer adesso?",
            what: "il computer si riavvierà",
            glyph: Theme.ico.restart,
            cmd: ["systemctl", "reboot"]
        },
        logout: {
            label: "Esci",
            title: `Vuoi uscire dall'utente “${user}” adesso?`,
            what: "la sessione verrà chiusa",
            glyph: Theme.ico.logout,
            cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"]
        },
        suspend: {
            cmd: ["systemctl", "suspend"]
        },
        lock: {
            cmd: ["hyprlock"]
        }
    })

    readonly property var current: pending !== "" ? actions[pending] : null

    function run(id) {
        Quickshell.execDetached(actions[id].cmd);
    }

    function request(id) {
        if (actions[id].title) {
            remaining = timeout;
            pending = id;
        } else {
            run(id);
        }
    }

    function cancel() {
        pending = "";
    }

    function confirm() {
        const id = pending;
        pending = "";
        if (id !== "")
            run(id);
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.pending !== ""
        onTriggered: {
            root.remaining--;
            if (root.remaining <= 0)
                root.confirm();
        }
    }
}
