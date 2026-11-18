pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

// Polkit authentication agent (replaces hyprpolkitagent). The dialog is PolkitDialog.qml.
Singleton {
    id: root

    readonly property bool active: agent.isActive && agent.flow !== null
    readonly property var flow: agent.flow
    readonly property bool registered: agent.isRegistered

    PolkitAgent {
        id: agent
    }
}
