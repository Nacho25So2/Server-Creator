#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    exit 1
fi

case "$1" in
    max)
        echo 96000 > /sys/class/backlight/intel_backlight/brightness
        ;;
    min)
        echo 1 > /sys/class/backlight/intel_backlight/brightness
        ;;
    off)
        echo 0 > /sys/class/backlight/intel_backlight/brightness
        ;;
    *)
        exit 1
        ;;
esac
