#!/bin/sh
termux-x11 :1 -xstartup "GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 dbus-launch --exit-with-session xfce4-session"
