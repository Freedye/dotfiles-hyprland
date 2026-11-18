//@ pragma Env QT_QUICK_CONTROLS_STYLE=Fusion
// lain-greeter — Serial Experiments Lain login screen for greetd, built with Quickshell.
// QML layout and components derived from Keyitdev's astronaut theme
// (Copyright (C) 2022-2025 Keyitdev, GPLv3+, see LICENSE).
//
// Modes:
//   - under greetd ($GREETD_SOCK set): real login through Quickshell.Services.Greetd
//   - otherwise: preview mode, password "lain" succeeds, anything else fails, Esc quits

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Greetd

ShellRoot {
    id: shell

    readonly property bool live: Greetd.available
    // Monitor that gets the login form (others show background + clock only).
    readonly property string primaryScreen: Quickshell.env("LAIN_PRIMARY") ?? ""

    // ---- Theme config (lain palette and layout) ----------------------------
    QtObject {
        id: config
        property string screenPadding: ""
        property string font: "arcadeclassic"
        property string fontSize: "11"
        property string roundCorners: "20"
        property string locale: ""
        property string hourFormat: "HH:mm"
        property string dateFormat: "dddd d"
        property string headerText: ""
        property string background: Qt.resolvedUrl("Backgrounds/lain.jpg")
        property string dimBackground: "0.0"
        property string cropBackground: "true"
        property string backgroundHorizontalAlignment: "center"
        property string backgroundVerticalAlignment: "center"
        property color headerTextColor: "#c1b492"
        property color dateTextColor: "#c1b492"
        property color timeTextColor: "#c1b492"
        property color formBackgroundColor: "#1f1516"
        property color backgroundColor: "#1f1516"
        property color dimBackgroundColor: "#1f1516"
        property color loginFieldBackgroundColor: "#2a1d1f"
        property color passwordFieldBackgroundColor: "#2a1d1f"
        property color loginFieldTextColor: "#c1b492"
        property color passwordFieldTextColor: "#c1b492"
        property color userIconColor: "#c1b492"
        property color passwordIconColor: "#c1b492"
        property color placeholderTextColor: "#7d6f66"
        property color warningColor: "#d27389"
        property color sessionButtonTextColor: "#c1b492"
        property color dropdownTextColor: "#c1b492"
        property color dropdownSelectedBackgroundColor: "#d27389"
        property color dropdownBackgroundColor: "#2a1d1f"
        property color highlightTextColor: "#1f1516"
        property color highlightBackgroundColor: "#d27389"
        property color highlightBorderColor: "transparent"
        property color hoverUserIconColor: "#d27389"
        property color hoverPasswordIconColor: "#d27389"
        property color hoverSystemButtonsIconsColor: "#d27389"
        property color hoverSessionButtonTextColor: "#d27389"
        property string haveFormBackground: "false"
        property string formPosition: "left"
        property string forceLastUser: "true"
        property string passwordFocus: "true"
        property string hideCompletePassword: "true"
        property string allowEmptyPassword: "false"
        property string allowUppercaseLettersInUsernames: "false"
        property string rightToLeftLayout: "false"
        property string translatePlaceholderUsername: ""
        property string translatePlaceholderPassword: ""
        property string translateLoginFailedWarning: ""
        property string translateSessionSelection: ""
    }

    QtObject {
        id: textConstants
        property string loginFailed: "Login failed"
        property string userName: "Username"
        property string password: "Password"
    }

    // ---- Remembered user/session --------------------------------------------
    FileView {
        id: lastState
        path: Quickshell.statePath("last.json")
        printErrors: false
        JsonAdapter {
            id: last
            property string user: ""
            property string session: ""
        }
    }

    // ---- Users (from /etc/passwd) ---------------------------------------------
    ListModel {
        id: userModel
        property int lastIndex: 0
        function refreshLast() {
            for (let i = 0; i < count; i++)
                if (get(i).name === last.user) { lastIndex = i; return; }
            lastIndex = 0;
        }
    }

    FileView {
        path: "/etc/passwd"
        onLoaded: {
            userModel.clear();
            const badShells = ["/usr/bin/nologin", "/sbin/nologin", "/usr/sbin/nologin", "/bin/false", "/usr/bin/false"];
            for (const line of text().split("\n")) {
                const f = line.split(":");
                if (f.length < 7) continue;
                const uid = parseInt(f[2]);
                if (uid < 1000 || uid >= 60000 || badShells.includes(f[6])) continue;
                userModel.append({ name: f[0] });
            }
            userModel.refreshLast();
        }
    }

    // ---- Sessions (from /usr/share/wayland-sessions) ------------------------
    ListModel {
        id: sessionModel
        property int lastIndex: 0
        function refreshLast() {
            let fallback = 0;
            for (let i = 0; i < count; i++) {
                if (get(i).name === last.session) { lastIndex = i; return; }
                if (get(i).name.indexOf("uwsm") !== -1) fallback = i;
            }
            lastIndex = fallback;
        }
    }

    Process {
        running: true
        command: ["sh", "-c",
            "for f in /usr/share/wayland-sessions/*.desktop; do " +
            "  grep -qiE '^(Hidden|NoDisplay)=true' \"$f\" && continue; " +
            "  printf '%s\\t%s\\t%s\\n' \"$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-)\" " +
            "    \"$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2-)\" " +
            "    \"$(grep -m1 '^DesktopNames=' \"$f\" | cut -d= -f2-)\"; " +
            "done"]
        stdout: StdioCollector {
            onStreamFinished: {
                sessionModel.clear();
                for (const line of text.split("\n")) {
                    const f = line.split("\t");
                    if (f.length < 2 || f[1] === "") continue;
                    sessionModel.append({ name: f[0], exec: f[1], desktop: (f[2] || f[0].split(" ")[0]).replace(/;$/, "").replace(/;/g, ":") });
                }
                sessionModel.refreshLast();
            }
        }
    }

    Connections {
        target: last
        function onUserChanged() { userModel.refreshLast(); }
        function onSessionChanged() { sessionModel.refreshLast(); }
    }

    // ---- Auth backend (greetd, or a mock in preview mode) ------------------
    QtObject {
        id: auth

        signal loginSucceeded()
        signal loginFailed(string message)

        property bool busy: false
        property string pendingPassword: ""
        property int pendingSession: -1
        property bool answered: false

        function login(user, password, sessionIndex) {
            if (busy || user === "") return;
            if (config.allowEmptyPassword !== "true" && password === "") return;
            busy = true;
            pendingPassword = password;
            pendingSession = sessionIndex;
            answered = false;
            last.user = user;

            if (!shell.live) {
                mockTimer.ok = password === "lain";
                mockTimer.start();
                return;
            }
            Greetd.createSession(user);
        }

        function fail(message) {
            pendingPassword = "";
            busy = false;
            if (Greetd.available && Greetd.state !== GreetdState.Inactive)
                Greetd.cancelSession();
            loginFailed(message);
        }

        function sessionCommand() {
            const s = sessionModel.get(pendingSession >= 0 ? pendingSession : sessionModel.lastIndex);
            // Strip desktop-entry field codes (%f, %U, ...) and split on whitespace.
            const argv = s.exec.replace(/%[a-zA-Z]/g, "").trim().split(/\s+/);
            return { name: s.name, argv: argv, desktop: s.desktop };
        }
    }

    Timer {
        id: mockTimer
        property bool ok: false
        interval: 400
        onTriggered: {
            if (!ok) { auth.fail(""); return; }
            const s = auth.sessionCommand();
            console.log("[preview] login ok, would launch:", JSON.stringify(s.argv), "desktop:", s.desktop);
            auth.busy = false;
            auth.loginSucceeded();
            Qt.quit();
        }
    }

    Connections {
        target: shell.live ? Greetd : null

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (!responseRequired) return;            // info/error text from PAM, nothing to answer
            if (auth.answered) {                       // second prompt (2FA, expired password...): unsupported
                auth.fail(message);
                return;
            }
            auth.answered = true;
            Greetd.respond(auth.pendingPassword);
            auth.pendingPassword = "";
        }

        function onAuthFailure(message) { auth.fail(""); }
        function onError(error) { auth.fail(error); }

        function onReadyToLaunch() {
            const s = auth.sessionCommand();
            last.session = s.name;
            lastState.writeAdapter();
            // systemd-cat: session output goes to the journal (tag "hyprland-session"), not on the VT.
            Greetd.launch(["systemd-cat", "-t", "hyprland-session"].concat(s.argv), [
                "XDG_SESSION_TYPE=wayland",
                "XDG_CURRENT_DESKTOP=" + s.desktop,
                "XDG_SESSION_DESKTOP=" + s.desktop.split(":")[0]
            ], true);
            auth.loginSucceeded();
        }
    }

    // ---- Windows ------------------------------------------------------------
    Variants {
        // Only the primary monitor (LAIN_PRIMARY, else the first one).
        model: {
            const s = Quickshell.screens.filter(x => x.name === shell.primaryScreen);
            return s.length > 0 ? s : [Quickshell.screens[0]];
        }

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            readonly property bool primary: true  // only one window now (see model)

            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            color: config.backgroundColor
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "lain-greeter"
            WlrLayershell.keyboardFocus: !primary ? WlrKeyboardFocus.None
                : shell.live ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

            Greeter {
                anchors.fill: parent
                showForm: win.primary
                Keys.onEscapePressed: if (!shell.live) Qt.quit()
            }
        }
    }
}
