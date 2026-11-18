pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Notification server (replaces mako): keeps the history, decides what pops up.
Singleton {
    id: root

    // Do not disturb: notifications go to the history without popping up (critical ones still do)
    property bool dnd: false
    // notifications currently shown as popups, newest first
    property var popups: []
    // everything not dismissed yet, newest first
    readonly property var history: [...server.trackedNotifications.values].reverse()
    readonly property int maxHistory: 50

    function hide(n) {
        popups = popups.filter(x => x !== n);
        if (n && n.transient) n.expire(); // transient ones don't stay in the history
    }

    function clear() {
        popups = [];
        for (const n of [...server.trackedNotifications.values])
            n.dismiss();
    }

    // Default timeouts like the old mako config: low 5s, normal 10s, critical never.
    function timeout(n) {
        if (n.urgency === NotificationUrgency.Critical) return 0;
        if (n.expireTimeout > 0) return n.expireTimeout * 1000;
        return n.urgency === NotificationUrgency.Low ? 5000 : 10000;
    }

    NotificationServer {
        id: server

        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            n.closed.connect(() => root.popups = root.popups.filter(x => x !== n));
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [n, ...root.popups].slice(0, 5);

            const all = server.trackedNotifications.values;
            if (all.length > root.maxHistory) all[0].dismiss();
        }
    }

    // qs ipc call notifications clear | toggleDnd
    IpcHandler {
        target: "notifications"

        function clear(): void { root.clear(); }
        function toggleDnd(): void { root.dnd = !root.dnd; }
        function count(): int { return root.history.length; }
    }
}
