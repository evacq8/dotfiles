#!/bin/bash

while [[ $# -gt 0 ]]; do
    case "$1" in
        --time)
            echo "{\"text\": \"$(date +'%H:%M:%S') \"}"
            ;;
        --date)
            echo "{\"text\": \"$(date +'%a, %B %d')\"}"
            ;;
        *)
            echo "Invalid flag. Usage: $0 [--time|--date]"
            exit 1
            ;;
    esac
    shift
done
