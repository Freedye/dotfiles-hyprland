pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Mouse and keyboard battery, read from their USB receivers by scripts/battery.py (-1 = no answer)
Singleton {
    id: root

    // charge: 0 not charging, 1 charging, 2 full
    property int mouse: -1
    property int mouseCharge: -1
    property int keyboard: -1
    property int keyboardMv: -1
    property int keyboardCharge: -1

    function parse(line) {
        const f = line.split("\t");
        if (f.length < 5)
            return;
        mouse = parseInt(f[0]);
        mouseCharge = parseInt(f[1]);
        keyboard = parseInt(f[2]);
        keyboardMv = parseInt(f[3]);
        keyboardCharge = parseInt(f[4]);
    }

    Process {
        id: proc
        command: ["python3", "-I", Quickshell.shellPath("scripts/battery.py")]
        running: true
        stdout: SplitParser {
            onRead: line => root.parse(line)
        }
        onRunningChanged: if (!running) restart.start()
    }

    Timer {
        id: restart
        interval: 5000
        onTriggered: proc.running = true
    }
}
