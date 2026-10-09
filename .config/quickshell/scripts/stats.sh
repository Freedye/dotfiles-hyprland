#!/usr/bin/env bash
# One TSV line per second:
#   cpu%  mem%  memUsedKiB  memTotalKiB  tempC  netType  netName  netSignal

temp_file=""
for d in /sys/class/hwmon/hwmon*; do
    case "$(cat "$d/name" 2>/dev/null)" in
        k10temp|coretemp|zenpower) temp_file="$d/temp1_input"; break ;;
    esac
done
[ -z "$temp_file" ] && temp_file=/sys/class/thermal/thermal_zone0/temp

read_cpu() {
    read -r _ u n s i w q sq st _ < /proc/stat
    total=$((u + n + s + i + w + q + sq + st))
    idle=$((i + w))
}

get_net() {
    net_type=none; net_name=""; net_sig=0
    local t s c
    while IFS=: read -r t s c; do
        [ "$s" = connected ] || continue
        case $t in
            ethernet) net_type=ethernet; net_name=$c; break ;;
            wifi) net_type=wifi; net_name=$c ;;
        esac
    done < <(nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null)
    if [ "$net_type" = wifi ]; then
        net_sig=$(nmcli -t -f ACTIVE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}')
        net_sig=${net_sig:-0}
    fi
}

read_cpu; prev_total=$total; prev_idle=$idle
tick=0
get_net

while true; do
    sleep 1
    read_cpu
    dt=$((total - prev_total)); di=$((idle - prev_idle))
    prev_total=$total; prev_idle=$idle
    cpu=$(( dt > 0 ? 100 * (dt - di) / dt : 0 ))

    mem_total=0; mem_avail=0
    while read -r k v _; do
        case $k in
            MemTotal:) mem_total=$v ;;
            MemAvailable:) mem_avail=$v; break ;;
        esac
    done < /proc/meminfo
    mem_used=$((mem_total - mem_avail))
    mem_pct=$(( mem_total > 0 ? 100 * mem_used / mem_total : 0 ))

    t=$(<"$temp_file"); temp=$((t / 1000))

    tick=$((tick + 1))
    [ $((tick % 5)) -eq 0 ] && get_net

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$cpu" "$mem_pct" "$mem_used" "$mem_total" "$temp" "$net_type" "$net_name" "$net_sig"
done
