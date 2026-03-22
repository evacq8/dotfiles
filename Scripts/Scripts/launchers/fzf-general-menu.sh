#!/bin/bash

NETWORK_INTERFACE="wlan0"

# Function to check for pacman lock file
check_pacman_lock() {
    if [ -f /var/lib/pacman/db.lck ]; then
        notify-send -u critical "Pacman is currently updating" 'Pacman lock file found. refusing to shutdown.'
        return 1
    fi
    return 0
}

# Function to toggle Gammastep
toggle_gammastep() {
    if pgrep -x "gammastep" > /dev/null; then
        pkill gammastep &
        notify-send "Disabled gammastep"
    else
		nohup gammastep -c ~/.config/gammastep/config.ini >/dev/null 2>&1 &
		disown %1
        notify-send "Enabled gammastep"
    fi
}

# Display menu and store user choice
options=" lock\n shutdown\n restart\n logout\n reload-sway\n toggle-gammastep\n switch-wallpaper\n randomize-mac-address"
choice=$(echo -e "$options" | fzf --reverse --border  --prompt="power: " | awk '{print $2}')

if [ -z "$choice" ]; then
	kill -9 $PPID
	exit 0
fi

# Confirm the selected operation
case $choice in
    lock)
        	nohup sh -c "sleep 0.5 && hyprlock" >/dev/null 2>&1 &
			disown %1
        ;;
    shutdown)
        if check_pacman_lock; then
			confirm=$(echo -e " no\n yes" | fzf --prompt="Confirm Shutdown? ")
			[[ "$confirm" == *"yes"* ]] && shutdown now
        fi
        ;;
    restart)
        if check_pacman_lock; then
			confirm=$(echo -e " no\n yes" | fzf --prompt="Confirm Reboot? ")
            [[ "$confirm" == *"yes"* ]] && reboot
        fi
        ;;
    logout)
		confirm=$(echo -e " no\n yes" | fzf --prompt="Confirm Logout? ")
        [[ "$confirm" == *"yes"* ]] && swaymsg exit
        ;;
    reload-sway)
        if check_pacman_lock; then
            swaymsg reload
            notify-send 'reloaded sway'
        fi
        ;;
    toggle-gammastep)
        toggle_gammastep
        ;;
	switch-wallpaper)
		bash ~/Scripts/wallpaper.sh
        ;;
	randomize-mac-address)
			MAC_SPOOF_OUTPUT=$(pkexec bash -c "
			ip link set dev $NETWORK_INTERFACE down;
			macchanger -r $NETWORK_INTERFACE;
			ip link set dev $NETWORK_INTERFACE up;
			" 2>&1)

			notify-send "Randomizing $NETWORK_INTERFACE MAC Address:" "$MAC_SPOOF_OUTPUT"
		;;
esac

sleep 0.1
kill -9 $PPID
