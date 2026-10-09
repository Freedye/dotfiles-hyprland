pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int cpu: 0
    property int mem: 0
    property real memUsedGiB: 0
    property real memTotalGiB: 0
    property int temp: 0
    property string netType: "none"
    property string netName: ""
    property int netSignal: 0

    function parse(line) {
        const f = line.split("\t");
        if (f.length < 8)
            return;
        cpu = parseInt(f[0]);
        mem = parseInt(f[1]);
        memUsedGiB = parseInt(f[2]) / 1048576;
        memTotalGiB = parseInt(f[3]) / 1048576;
        temp = parseInt(f[4]);
        netType = f[5];
        netName = f[6];
        netSignal = parseInt(f[7]);
    }

    Process {
        id: proc
        command: ["bash", Quickshell.shellPath("scripts/stats.sh")]
        running: true
        stdout: SplitParser {
            onRead: line => root.parse(line)
        }
        onRunningChanged: if (!running) restart.start()
    }

    Timer {
        id: restart
        interval: 2000
        onTriggered: proc.running = true
    }
}
