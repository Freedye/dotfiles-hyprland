#!/bin/sh
# Index for Launcher.qml, one tab-separated record per line:
#   H <desktop id>     entry to hide (Hidden=true, or OnlyShowIn/NotShowIn excludes this desktop), like wofi
#   I <name> <path>    app icon from the GTK icon theme (the bar itself uses QS_ICON_THEME)

desk=":${XDG_CURRENT_DESKTOP:-Hyprland}:"
seen=":"

# Desktop entries, highest precedence first: an id is decided by the first file that defines it.
dirs="${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
IFS=:
for d in $dirs; do
    [ -d "$d/applications" ] || continue
    unset IFS
    for f in $(find "$d/applications" -name '*.desktop' 2>/dev/null); do
        id=${f#"$d/applications/"}
        id=$(printf '%s' "${id%.desktop}" | tr / -)
        case "$seen" in *":$id:"*) continue ;; esac
        seen="$seen$id:"
        awk -v desk="$desk" -v id="$id" '
            /^\[/ { sec = ($0 == "[Desktop Entry]"); next }
            !sec { next }
            /^Hidden=true/ { hide = 1 }
            /^OnlyShowIn=/ { only = substr($0, 12) }
            /^NotShowIn=/ { not = substr($0, 11) }
            function hit(list,   n, a, i) {
                n = split(list, a, ";")
                for (i = 1; i <= n; i++) if (a[i] != "" && index(desk, ":" a[i] ":")) return 1
                return 0
            }
            END {
                if (only != "" && !hit(only)) hide = 1
                if (not != "" && hit(not)) hide = 1
                if (hide) print "H\t" id
            }' "$f"
    done
    IFS=:
done
unset IFS

# Icons of the GTK theme: scalable first, then the biggest sizes.
theme=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
[ -n "$theme" ] || exit 0
for base in "${XDG_DATA_HOME:-$HOME/.local/share}/icons" "$HOME/.icons" /usr/share/icons; do
    t="$base/$theme"
    [ -d "$t" ] || continue
    for sub in scalable/apps 256x256/apps 128x128/apps 96x96/apps 64x64/apps 48x48/apps 32/apps 32x32/apps 24/apps 22/apps; do
        [ -d "$t/$sub" ] || continue
        for p in "$t/$sub"/*; do
            [ -s "$p" ] || continue  # skip empty or broken files (Tela has a few)
            n=${p##*/}
            printf 'I\t%s\t%s\n' "${n%.*}" "$p"
        done
    done
done
