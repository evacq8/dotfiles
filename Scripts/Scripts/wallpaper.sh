#!/bin/bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/wallpapers"

# Temporary file to store the index of the current wallpaper
INDEX_FILE="$HOME/.local/bin/wallpaper_index"

# Get the list of wallpapers in the directory
WALLPAPERS=("$WALLPAPER_DIR"/*)

# Check if the file exists; if not, initialize it with index 0
if [ ! -f "$INDEX_FILE" ]; then 
    echo 0 > "$INDEX_FILE"
fi

# Read the current index from the file
CURRENT_INDEX=$(cat "$INDEX_FILE")

# Check for the --refresh argument
if [ "$1" == "--refresh" ]; then
    # Reapply the current wallpaper without modifying the index
    swaymsg output "*" bg "${WALLPAPERS[$CURRENT_INDEX]}" fill
    exit 0
fi

# Increment the index, cycling back to 0 if it exceeds the number of wallpapers
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))

# Set the next wallpaper
swaymsg output "*" bg "${WALLPAPERS[$NEXT_INDEX]}" fill
dunstify -h string:x-dunst-stack-tag:wallpaper "Wallpaper Changed" "$(basename "${WALLPAPERS[$NEXT_INDEX]}")"

# Save the new index to the file
echo "$NEXT_INDEX" > "$INDEX_FILE"

