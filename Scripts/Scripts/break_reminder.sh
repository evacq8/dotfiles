#!/bin/bash

# Array of break messages
messages=(
  "It's been 20 minutes. Look away for 30 seconds and come back."
  "It's been 20 minutes. Look at something 6 meters away"
  "It's been 20 minutes; how about we go take a quick water break!"
  "Checkpoint! 20 minutes have passed. Give your eyes some rest."
  "20 minutes up! You have 30 seconds to look at something outside, GO!"
  "It's been 20 minutes. Look away and don't look back until this message is gone."
)

# send notif every 20 minutes
while true
do
  sleep 1200

  # Pick message
  message="${messages[RANDOM % ${#messages[@]}]}"
  
  # 40 sec timeout
  dunstify -t 40000 "Break Reminder" "$message"
done

