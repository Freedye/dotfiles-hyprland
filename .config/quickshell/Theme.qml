pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // The bar is drawn only on this output (first screen if it doesn't exist)
    readonly property string barOutput: "DP-1"
    readonly property string textFont: "Maple Mono"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property int barHeight: 30

    // Live pywal palette: run `wal` and the bar re-colors itself
    readonly property color bg: adapter.special.background
    readonly property color fg: adapter.special.foreground
    readonly property color warm: adapter.colors.color5
    readonly property color accent: adapter.colors.color6
    readonly property color dim: adapter.colors.color8
    readonly property color danger: "#eb4d4b"

    readonly property color raised: mix(bg, fg, 0.09)

    function alpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function mix(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    readonly property var ico: {
        const codes = {
            power: 0xF0425, drawer: 0xF0AAB,
            volHigh: 0xF057E, volMed: 0xF0580, volLow: 0xF057F, volOff: 0xF0581, volMute: 0xF075F,
            headphones: 0xF02CB, headset: 0xF02CE,
            cpu: 0xF2DB, mem: 0xF035B, temp: 0xF2C9,
            wifi: 0xF1EB, ethernet: 0xF0200, warn: 0xF071,
            prev: 0xF048, next: 0xF051, play: 0xF04B, pause: 0xF04C,
            left: 0xF053, right: 0xF054, check: 0xF00C,
            suspend: 0xF04B2, restart: 0xF0709, lock: 0xF033E, logout: 0xF0343
        };
        const out = {};
        for (const k in codes)
            out[k] = String.fromCodePoint(codes[k]);
        return out;
    }

    FileView {
        path: Quickshell.env("HOME") + "/.cache/wal/colors.json"
        watchChanges: true
        onFileChanged: reload()

        adapter: JsonAdapter {
            id: adapter

            property JsonObject special: JsonObject {
                property string background: "#102524"
                property string foreground: "#c3c8c8"
            }
            property JsonObject colors: JsonObject {
                property string color5: "#DC9C92"
                property string color6: "#CFB0B6"
                property string color8: "#5f7473"
            }
        }
    }
}
