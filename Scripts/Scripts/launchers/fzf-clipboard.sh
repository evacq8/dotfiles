#!/bin/bash
TERMINAL_PID=$(ps -o ppid= -p $$)
selected=$(cliphist list | fzf --prompt="clipboard: " --reverse --border)

if [ -n "$selected" ]; then
	( cliphist decode <<< "$selected" | setsid wl-copy > /dev/null 2>&1 ) &
	disown
fi

sleep 0.1
kill -9 ${TERMINAL_PID}
