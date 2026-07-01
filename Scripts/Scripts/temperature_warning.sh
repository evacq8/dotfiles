#!/bin/bash

toast() {
	echo "temperature_warning.sh: $1 $2"
	notify-send "temperature_warning.sh: $1" "$2"
}
toastc() {
	echo "temperature_warning.sh: $1 $2"
	notify-send -u critical "temperature_warning.sh: $1" "$2"
}


TEMP_FILE=""
MAX_TEMP_FILE=""

find_cpu_hwmon_temp_files() {
	for folder in /sys/class/hwmon/hwmon*; do
		# skip if hwmon folder doesn't have a name file
		if [ ! -f "$folder/name" ]; then
			continue
		fi
		NAME=$(cat "$folder/name")
		if [ "$NAME" == "coretemp" ] || [ "$NAME" == "k10temp" ]; then
			TEMP_FILE="$folder/temp1_input"
			MAX_TEMP_FILE="$folder/temp1_max"
			return
		fi
	done
	toast "Couldn't find any hwmon folders for CPU." "CPU notification warnings disabled."
	exit 1
}
find_cpu_hwmon_temp_files

# Get the max and critical thresholds
MAX_TEMP=$(cat "$MAX_TEMP_FILE")
MAX_WARNING_SENT=false

# Wait a certain amount of cycles before sending the notification again 
# to avoid spamming when the temperature fluctuates around the threshold
CYCLES=0

while true; do
	TEMP=$(cat "$TEMP_FILE")
	echo "$TEMP"
	# my laptop crashes at like 15*C below the the actual max.. it might vary for yours though. 
	# So I'm setting it to remind 20*C in advance
	if [[ $TEMP -ge $((MAX_TEMP-20000)) && $MAX_WARNING_SENT == false ]]; then
		toastc "CPU is at $(((MAX_TEMP-20000)/1000))°C" "A forced shutdown will occur at around $(($MAX_TEMP/1000))°C. Make sure the vents aren't obstructed and stop heavy processes."
		MAX_WARNING_SENT=true
		CYCLES=15
	fi
	if [ "$CYCLES" -le 0 ]; then
		MAX_WARNING_SENT=false
	fi
	if [ "$MAX_WARNING_SENT" == true ]; then
		CYCLES=$((CYCLES-1))
	fi
	sleep 10
done
