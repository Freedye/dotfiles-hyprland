pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property string formFactor: sink?.properties?.["device.form-factor"] ?? ""
    // The peak monitor captures a stereo stream, so it only works on sinks that have FL/FR
    readonly property bool peakOk: {
        const ch = sink?.audio?.channels;
        if (!ch)
            return false;
        let l = false, r = false;
        for (let i = 0; i < ch.length; i++) {
            l = l || ch[i] === PwAudioChannel.FrontLeft;
            r = r || ch[i] === PwAudioChannel.FrontRight;
        }
        return l && r;
    }
    // 0..1, perceptually stretched output peak
    readonly property real level: peakOk ? Math.min(1, Math.sqrt(Math.max(0, monitor.peak))) : 0

    function setVolume(v) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, v));
    }

    function nudge(delta) {
        if (sink?.audio) {
            sink.audio.muted = false;
            setVolume(volume + delta);
        }
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    PwObjectTracker {
        objects: [root.sink]
    }

    PwNodePeakMonitor {
        id: monitor
        node: root.sink
        enabled: root.peakOk
    }
}
