#!/bin/sh
rm -rf .config/pulse
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
virgl_test_server_android &
proot-distro login ubuntu --shared-tmp
