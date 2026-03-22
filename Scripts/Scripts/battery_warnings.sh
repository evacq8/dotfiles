#!/bin/bash

# Initialize a flag to track notification status
notification_sent=false
charging_notif_sent=true

battery_low_sent=false
battery_critical_sent=false

while true; do
    is_discharging=$(acpi -b | grep -o 'Discharging')
    time_left=$(acpi -V | grep -o '[0-9]\+:[0-9]\+:[0-9]\+')
    battery_level=$(acpi -b | grep -oP '[0-9]+(?=%)')

    if [ "$is_discharging" = "Discharging" ] && ! $notification_sent; then
        dunstify -h int:value:"${battery_level}%" "Battery Discharging" "Exhausting $battery_level% battery"
        notification_sent=true  # Mark the notification as sent
        charging_notif_sent=false
        # paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
    elif [ "$is_discharging" != "Discharging" ] && ! $charging_notif_sent; then
        notification_sent=false  # Reset the flag when charging
        charging_notif_sent=true
        dunstify -h int:value:"${battery_level}%" -h string:x-dunst-stack-tag:battery "Battery Charging" "Charging $battery_level% battery"
    fi

    

    # Check if the battery level is less than or equal to 25%
    if [ "$battery_level" -le 5 ] && [ "$is_discharging" = "Discharging" ] && ! $battery_critical_sent; then
        dunstify -u 2 "Critical Battery" "5% Charge, $time_left remaining until depletion"
        battery_critical_sent=true
    elif [ "$battery_level" -le 25 ] && [ "$is_discharging" = "Discharging" ] && ! $battery_low_sent; then
        notify-send "Low Battery" "25% Charge, $time_left remaining until depletion"
        battery_low_sent=true
    elif [ "$is_discharging" = "" ]; then
        battery_critical_sent=false
        battery_low_sent=false
    fi
    # Sleep before checking again
    sleep 1
done
