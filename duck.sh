#!/usr/bin/env bash

# loop mpv
while true; do
    mpv ~/Downloads/*.webm --input-ipc-server=/tmp/socket
done &


is_firefox_playing() {
    wpctl status | awk '/Streams:/,0' | \
        awk '/Firefox/ {found=1} found && /\[active\]/ {print; exit}' | \
        grep -q '\[active\]'
    return $? # 0 if Firefox is playing, non-zero otherwise
}

is_mpv_playing() {
    wpctl status | awk '/Streams:/,0' | \
        awk '/mpv/ {found=1} found && /\[active\]/ {print; exit}' | \
        grep -q '\[active\]'
    return $? # 0 if mpv is playing, non-zero otherwise
}

while true; do
    if is_firefox_playing ; then
        if is_mpv_playing ; then
            echo "🔊 Firefox is playing — ducking MPV..."
            echo cycle pause | socat - "/tmp/socket"
        fi
    else
        if is_mpv_playing ; then
            continue
        else
            echo "🔊 Firefox is not playing — unpausing MPV..."
            echo cycle pause | socat - "/tmp/socket"
        fi
    fi
    sleep 1
done
