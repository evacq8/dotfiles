#!/bin/bash

# Define directories
DIRS="/usr/share/applications $HOME/.local/share/applications /var/lib/flatpak/exports/share/applications"

# Generate a list of "Display Name | Filename"
# Use awk to extract the name and append the filename at the end so we can launch it later
list=$(find $DIRS -name "*.desktop" -exec grep -m 1 "^Name=" {} + | 
       sed 's/.*Name=//' | 
       sort -u)

# Pipe to fuzzy find
selected_name=$(echo "$list" | fzf --reverse --border --prompt="run: ")

if [ -n "$selected_name" ]; then
    # find the filename that matches that display Name to launch it
    # We look for the file where Name=selected_name
    file_to_launch=$(grep -l "^Name=$selected_name$" -r $DIRS | head -n 1)
    filename=$(basename "$file_to_launch")

    # Launch detached
    (setsid gtk-launch "$filename" >/dev/null 2>&1 &)
    
    sleep 0.1
fi

# Kill the parent terminal
kill -9 $PPID
