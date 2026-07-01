#!/bin/bash

# echo message for terminal and send notification
toast() {
	echo "wallpaper.sh: $1 $2"
	notify-send "wallpaper.sh: $1" "$2"
}

# directory containing wallpapers
WALLPAPER_DIR="$HOME/wallpapers"

# file to keep track of wallpaper index
INDEX_FILE="$WALLPAPER_DIR/.wallpaper_index"
# file to read to get current theme
THEME_FILE="$HOME/.current_theme"
# check if theme file exists
if [ ! -f "$THEME_FILE" ]; then
	toast "Can't find current theme." "$THEME_FILE doesn't exist."
	exit 1
fi
THEME=$(cat "$THEME_FILE")

# check if theme-specific directory ($WALLPAPER_DIR/$THEME) exists
if [ ! -d "$WALLPAPER_DIR/$THEME" ]; then
	toast "Can't find $THEME wallpaper directory." "Please create $WALLPAPER_DIR/$THEME and put your wallpapers in there."
	exit 1
fi

# get the list of wallpapers for this theme
WALLPAPERS=("$WALLPAPER_DIR/$THEME"/*)
# make sure it isn't empty
if [ ! -e "${WALLPAPERS[0]}" ]; then
    toast "$THEME wallpaper folder empty." "Please add wallpaper images inside $WALLPAPER_DIR/$THEME"
    exit 1
fi

# check if INDEX_FILE exists. if not, create one
if [ ! -f "$INDEX_FILE" ]; then 
    echo 0 > "$INDEX_FILE"
fi
INDEX=$(cat "$INDEX_FILE")

# --refresh argument means set the background without incrementing or notification
if [ "$1" == "--refresh" ]; then
    swaymsg output "*" bg "${WALLPAPERS[$INDEX]}" fill
    exit 0
fi

# increment the index and cycle back if it reaches the end
NEXT_INDEX=$(( (INDEX + 1) % ${#WALLPAPERS[@]} ))

# set the next wallpaper 
swaymsg output "*" bg "${WALLPAPERS[$NEXT_INDEX]}" fill
toast "Wallpaper updated." "$(basename "${WALLPAPERS[$NEXT_INDEX]}")"

# save the new index to the file
echo "$NEXT_INDEX" > "$INDEX_FILE"

