#!/bin/bash

#screenshot_file="$HOME/screenshots/screenshot_$(date +'%Y%m%d%H%M%S').png"
#grim -g "$(slurp)" "$screenshot_file"
#wl-copy < "$screenshot_file"

grim -g "$(slurp)" - | swappy -f -
