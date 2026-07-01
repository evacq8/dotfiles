#!/bin/bash

# Exit if no arguments passed
if [ -z "$1" ]; then
    echo "No theme specified."
    exit 1
fi

THEME=$1
THEME_DIR="$HOME/Scripts/theme-manager/$THEME"
CURRENT_THEME_FILE_PATH="$HOME/.current_theme"

WALLPAPER_SCRIPT="$HOME/Scripts/wallpaper.sh"

# Check if the theme directory exists in THEME_DIR
if [ ! -d "$THEME_DIR" ]; then
    echo "'$THEME' not found in $THEME_DIR"
    exit 1
fi

echo "Switching to theme: $THEME..."
# Update current theme file
echo "$THEME" > "$CURRENT_THEME_FILE_PATH"
# Update wallpaper
bash "$WALLPAPER_SCRIPT"

# KITTY
if [ -f "$THEME_DIR/kitty.conf" ]; then
    cp "$THEME_DIR/kitty.conf" "$HOME/.config/kitty/theme.conf"
	echo "Kitty done."
fi

# WAYBAR
# Copy the CSS and signal Waybar to reload
if [ -f "$THEME_DIR/waybar.css" ]; then
	cp "$THEME_DIR/waybar.css" "$HOME/.config/waybar/theme.css"
    pkill -SIGUSR2 waybar
	echo "Waybar done."
fi

# NEOVIM (Just copy the neovim theme name, the neovim config will handle it)
if [ -f "$THEME_DIR/neovim.txt" ]; then
    cp "$THEME_DIR/neovim.txt" "$HOME/.config/nvim/current_theme.txt"
	echo "Neovim done."
fi

# DUNST
if [ -f "$THEME_DIR/dunst.sh" ]; then
	source $THEME_DIR/dunst.sh
	sed -e "s|__BACKGROUND__|$DUNST_BG|g" \
		-e "s|__FOREGROUND__|$DUNST_FG|g" \
		-e "s|__BACKGROUNDDANGER__|$DUNST_DANGER_BG|g" \
		-e "s|__FOREGROUNDDANGER__|$DUNST_DANGER_FG|g" \
		$HOME/.config/dunst/dunstrc.template > $HOME/.config/dunst/dunstrc
	killall dunst && dunst &>/dev/null &
	echo "Dunst done."
fi

echo "Tada!"
