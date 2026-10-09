#!/usr/bin/env bash
# Ask a StatusNotifierItem without a dbusmenu (e.g. Wine apps) to show its own context menu.
#   tray-contextmenu.sh <item id> <x> <y>
# Quickshell can't send the ContextMenu call itself, so find the item's bus name by its Id and call it.

id=$1; x=${2:-0}; y=${3:-0}

watcher=(org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.kde.StatusNotifierWatcher)

while read -r item; do
    dest=${item%%/*}
    path=/${item#*/}
    got=$(busctl --user get-property "$dest" "$path" org.kde.StatusNotifierItem Id 2>/dev/null) || continue
    [ "$got" = "s \"$id\"" ] || continue
    exec busctl --user call "$dest" "$path" org.kde.StatusNotifierItem ContextMenu ii "$x" "$y"
done < <(busctl --user get-property "${watcher[@]}" RegisteredStatusNotifierItems | grep -o '"[^"]*"' | tr -d '"')

exit 1
