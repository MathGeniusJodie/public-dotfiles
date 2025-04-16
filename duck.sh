#!/usr/bin/env bash

# loop mpv
while true; do
    mpv ~/Downloads/*.webm --input-ipc-server=/tmp/socket
done &


is_firefox_playing() {
    wpctl status | awk '/Streams:/,0' | awk '/Firefox/,0' | head -n 3 | grep -q '\[active\]'
    return $?
}
is_mpv_playing() {
    wpctl status | awk '/Streams:/,0' | awk '/mpv/,0' | head -n 3 | grep -q '\[active\]'
    return $?
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
