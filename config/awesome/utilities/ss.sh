#!/bin/bash

# Create the directory if it doesn't exist
mkdir -p ~/Pictures/

# Function to display a notification
function show_notification() {
    notify-send "Screenshot Captured" "Saved as $1"
}

# Function to capture a fullscreen screenshot
function capture_fullscreen() {
    timestamp=$(date +%Y%m%d_%H%M%S)
    filename=~/Pictures/screenshot_${timestamp}.png

    scrot "$filename"
    show_notification "$filename"
}

# Function to capture a selected area screenshot
function capture_selected_area() {
    timestamp=$(date +%Y%m%d_%H%M%S)
    filename=~/Pictures/screenshot_${timestamp}.png

    scrot -s "$filename"
    show_notification "$filename"
}

# Function to capture a screenshot after a specified time delay
function capture_with_timer() {
    delay=$1
    timestamp=$(date +%Y%m%d_%H%M%S)
    filename=~/Pictures/screenshot_${timestamp}.png

    sleep $delay && scrot "$filename"
    show_notification "$filename"
}

# Parse command line arguments
case $1 in
    -f|--fullscreen)
        capture_fullscreen
        ;;
    -s|--selected-area)
        capture_selected_area
        ;;
    -t|--timer)
        delay=$2
        capture_with_timer "$delay"
        ;;
    *)
        echo "Usage: screenshoot.sh [-f|--fullscreen] [-s|--selected-area] [-t|--timer <seconds>]"
        ;;
esac
