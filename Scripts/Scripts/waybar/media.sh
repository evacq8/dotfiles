#!/bin/bash

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -songname)
            songname=true
            shift
            ;;
        -artistname)
            artistname=true
            shift
            ;;
        -icon)
            icon=true
            shift
            ;;
        *)
            # Unknown option
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
done

# Get the current mode from Sway
mode=$(swaymsg -t get_binding_state | jq -r '.name')

# Check if the mode is "resize"
if [ "$mode" == "resize" ]; then
    if [ "$songname" = true ]; then
        echo "{\"text\": \"<b>Resize Mode</b>\", \"tooltip\": \"Resize mode active\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\", \"icon\": \"\"}"
    elif [ "$artistname" = true ]; then
        echo "{\"text\": \"esc to cancel\", \"tooltip\": \"Resize mode active\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\", \"icon\": \"\"}"
    elif [ "$icon" = true ]; then
        echo "{\"text\": \"\", \"tooltip\": \"Resize mode active\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}"
    else
        echo "Please specify either -songname or -artistname or -icon flag."
        exit 1
    fi
    exit 0
fi

# Get the artist using playerctl
artist=$(playerctl -a metadata --format '{{artist}}' 2>/dev/null)
# Get the song title using playerctl
song=$(playerctl -a metadata --format '{{title}}' 2>/dev/null)
album=$(playerctl -a metadata --format '{{album}}' 2>/dev/null)

# Escape double quotes and ampersands
song_escaped=$(echo "$song" | sed 's/"/\\"/g' | sed 's/&/&amp;/g')
artist_escaped=$(echo "$artist" | sed 's/"/\\"/g' | sed 's/&/&amp;/g')
album_escaped=$(echo "$album" | sed 's/"/\\"/g' | sed 's/&/&amp;/g')

# Check if the artist is empty
if [ "$songname" = true ]; then
    if [ -z "$song" ]; then
        echo "{\"text\": \"null and void\", \"tooltip\": \"waiting for media\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\", \"icon\": \"\"}"
    else
        echo "{\"text\": \"$song_escaped\", \"tooltip\": \"<b>$song_escaped</b> \nby $artist_escaped\non $album_escaped\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\", \"icon\": \"\"}"
    fi
elif [ "$artistname" = true ]; then
    if [ -z "$artist" ]; then
        echo "{\"text\": \"by unknown\", \"tooltip\": \"{{playerName}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\", \"icon\": \"\"}"
    else
        echo "{\"text\": \"by $artist_escaped\", \"tooltip\": \"{playerN{ame}} : {{markup_escape(title)}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\", \"icon\": \"\"}"
    fi
   
elif [ "$icon" = true ]; then
	status=$(playerctl status 2>/dev/null)
	if [ "$status" == "Playing" ]; then
 		echo "{\"text\": \"\", \"tooltip\": \"Now playing\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}"
	else
 		echo "{\"text\": \"\", \"tooltip\": \"Now playing\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}"
	fi

else
    echo "Please specify either -songname or -artistname or -icon flag."
    exit 1
fi
