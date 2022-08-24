#!/usr/bin/bash

VOLUME_ICONS=("" "")
MUTED_ICON=""
MUTED_COLOR="%{F#6b6b6b}"
VOLUME=2

# Run `pw-play --list-targets` for a list of sink names.
ignored_sinks=(
    "PulseEffects Sink"
)

switch-sink() {
    direction="$1"

    sinks="$(pw-play --list-targets | sed '1d')"
    for sink in ${ignored_sinks[*]}; do
        sinks="$(echo "$sinks" | sed "/$sink/d")"
    done

    if [ "$(echo "$sinks" | wc -l)" -le '1' ]; then
        # there is no sink to switch to.
        return
    fi

    id="$(echo "$sinks" | sed 's/*//' | awk '{print $1}' | tr -d ':')"
    current_sink=$(echo "$sinks" | awk '/*/ {print $2}' | tr -d ':')
    first_sink=$(echo "$id" | sed -n '1p')
    last_sink=$(echo "$id" | sed -n '$p')

    if [ "$direction" = "next" ]; then

        if [ "$current_sink" = "$last_sink" ]; then
            pactl set-default-sink "$first_sink"
        else
            sink=$(echo "$sinks"| grep -A1 '*' | tail -1 | awk '{print $1}' | tr -d ':')
            if echo "$sink" | grep -qE '[0-9]+'; then
                pactl set-default-sink "$sink"
            else
                pactl set-default-sink "$last_sink"
            fi
        fi

    elif [ "$direction" = "previous" ]; then

        if [ "$current_sink" = "$first_sink" ]; then
            pactl set-default-sink "$last_sink"
        else
            sink=$(echo "$sinks"| grep -B1 '*' | head -1 | awk '{print $1}' | tr -d ':')
            if echo "$sink" | grep -qE '[0-9]+'; then
                pactl set-default-sink "$sink"
            else
                pactl set-default-sink "$first_sink"
            fi
        fi

    fi
}

output() {
    DEFAULT_SINK_ID=$(pw-play --list-targets | sed -n 's/^*[[:space:]]*\([[:digit:]]\+\):.*$/\1/p')
    VOLUME=$(pactl list sinks | sed -n "/Sink #${DEFAULT_SINK_ID}/,/Volume/ s!^[[:space:]]\+Volume:.* \([[:digit:]]\+\)%.*!\1!p" | head -n1)
    DEFAULT_SINK=$(pw-play --list-targets | sed -ne '1d' -e '/*/p' | grep -o '".*"' | tr -d '"')
    IS_MUTED=$(pactl list sinks | sed -n "/Sink #${DEFAULT_SINK_ID}/,/Mute/ s/Mute: \(yes\)/\1/p")

    if [ "${IS_MUTED}" != "" ]; then
        echo "${MUTED_COLOR}${MUTED_ICON} ${DEFAULT_SINK}"
    else
        if [ "${VOLUME}" -le '40' ]; then
            printf '%s ' "${VOLUME_ICONS[0]}"
        elif [ "${VOLUME}" -gt '40' ]; then
            printf '%s ' "${VOLUME_ICONS[1]}"
        fi

        echo "${VOLUME}% ${DEFAULT_SINK}"
    fi

}
action=$1
if [ "${action}" == "volume-up" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +$VOLUME%
    canberra-gtk-play -i audio-volume-change -d "changeVolume"
elif [ "${action}" == "volume-down" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ -$VOLUME%
    canberra-gtk-play -i audio-volume-change -d "changeVolume"
elif [ "${action}" == "toggle-mute" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
elif [ "${action}" == "next-sink" ]; then
    switch-sink 'next'
elif [ "${action}" == "previous-sink" ]; then
    switch-sink "previous"
fi

if [ -n "$action" ]; then exit 0; fi

pactl subscribe 2>/dev/null | {
    while :; do
        {
            output
        }
done
}

