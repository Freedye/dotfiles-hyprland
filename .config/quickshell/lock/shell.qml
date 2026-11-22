//@ pragma Env QT_QUICK_CONTROLS_STYLE=Fusion
// Lain lockscreen. Separate Quickshell config, started on demand:
//   qs -n -p ~/.config/quickshell/lock/shell.qml
// It exits after unlocking. LAIN_LOCK_PREVIEW=1 opens it as a normal overlay
// with a mock password ("lain"), Esc quits: nothing is actually locked.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

ShellRoot {
    id: shell

    readonly property bool preview: Quickshell.env("LAIN_LOCK_PREVIEW") === "1"
    // Monitor that shows the clock and password field (the others show the background only).
    readonly property string primaryScreen: Quickshell.env("LAIN_PRIMARY") || "DP-1"
    readonly property string user: Quickshell.env("USER") ?? ""

    // Typed password, shared by all surfaces so keys work whatever monitor has focus.
    // The error stays on screen until the user starts typing again.
    property string password: ""
    onPasswordChanged: if (password !== "") errorText = ""
    property bool busy: false
    property string errorText: ""
    property bool answered: false
    // Last info/error text PAM sent without asking for an answer (e.g. faillock's
    // "account locked"): more useful than a generic "wrong password".
    property string notice: ""
    property bool revealed: false

    function isPrimary(screen) {
        if (!screen) return false;
        const named = Quickshell.screens.some(s => s.name === primaryScreen);
        return named ? screen.name === primaryScreen : screen === Quickshell.screens[0];
    }

    function submit() {
        if (busy || password === "") return;
        busy = true;
        errorText = "";
        if (preview) {
            mockTimer.start();
            return;
        }
        answered = false;
        notice = "";
        pam.active = true;
    }

    function fail(message) {
        busy = false;
        password = "";
        errorText = message;
    }

    function unlock() {
        busy = false;
        password = "";
        if (preview) { Qt.quit(); return; }
        lock.locked = false;
        quitTimer.start();
    }

    // Same PAM stack as hyprlock (/etc/pam.d/login, auth only): faillock rules apply.
    PamContext {
        id: pam
        config: "login"

        function handle() {
            if (!responseRequired) {                  // info/error text from PAM, nothing to answer
                if (message !== "") shell.notice = message;
                return;
            }
            if (shell.answered) {                     // second prompt (2FA, expired password...): unsupported
                active = false;
                shell.fail(message || "Accesso non riuscito");
                return;
            }
            shell.answered = true;
            respond(shell.password);
            shell.password = "";
        }

        onResponseRequiredChanged: Qt.callLater(handle)
        onMessageChanged: Qt.callLater(handle)

        onCompleted: result => {
            if (result === PamResult.Success) shell.unlock();
            else if (result === PamResult.MaxTries) shell.fail(shell.notice || "Troppi tentativi");
            else if (result === PamResult.Failed) shell.fail(shell.notice || "Password errata");
            else shell.fail(shell.notice || "Accesso non riuscito");
        }
        onError: error => shell.fail(
            error === PamError.StartFailed ? "Impossibile avviare PAM"
            : error === PamError.TryAuthFailed ? "Errore di autenticazione PAM"
            : "Errore interno di PAM")
    }

    Timer { id: mockTimer; interval: 400; onTriggered: shell.password === "lain" ? shell.unlock() : shell.fail("Password errata") }
    // Give the compositor a moment to process the unlock before exiting.
    Timer { id: quitTimer; interval: 200; onTriggered: Qt.quit() }

    // ---- Real lock: one surface per monitor -----------------------------------
    WlSessionLock {
        id: lock
        locked: !shell.preview

        WlSessionLockSurface {
            id: surface
            // The protocol needs a surface on every monitor: the non-primary ones stay black.
            color: shell.isPrimary(surface.screen) ? "#1f1516" : "black"
            LockView {
                anchors.fill: parent
                showForm: shell.isPrimary(surface.screen)
            }
        }
    }

    // ---- Preview: overlay on the primary monitor only -------------------------
    Variants {
        model: shell.preview ? Quickshell.screens.filter(s => shell.isPrimary(s)) : []

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: "#1f1516"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "lain-lock-preview"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            LockView {
                anchors.fill: parent
                showForm: true
                Keys.onEscapePressed: Qt.quit()
            }
        }
    }
}
