#!/bin/bash

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')

# Check if the -t (toggle) flag is provided
if [[ "$1" == "-t" ]]; then
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
        # Volume is muted
        dunstify -t 800 --hints=int:value:"${volume}%" -h string:x-dunst-stack-tag:volume -h string:category:temporary "Volume" "Muted"
    else
        dunstify -t 800 --hints=int:value:"${volume}%" -h string:x-dunst-stack-tag:volume -h string:category:temporary "Volume" "Unmuted"
    fi
else
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
        # Volume is muted
        dunstify -t 800 --hints=int:value:"${volume}%" -h string:x-dunst-stack-tag:volume -h string:category:temporary "Volume" "${volume}% (Muted)"
    else
        dunstify -t 800 --hints=int:value:"${volume}%" -h string:x-dunst-stack-tag:volume -h string:category:temporary "Volume" "${volume}%"
    fi
fi

