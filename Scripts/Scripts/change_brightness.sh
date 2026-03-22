#!/bin/bash

brightness=$(brightnessctl -d intel_backlight get | awk '{print $1}')
brightness=$((brightness / 960))

dunstify -t 800 --hints=int:value:"${brightness}%" -h string:x-dunst-stack-tag:brightness -h string:category:temperary "Brightness" "${brightness}%"


