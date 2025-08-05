#!/bin/bash

CONFIG_PATH=/data/options.json
RESOLUTION=$(jq --raw-output '.display_resolution // empty' $CONFIG_PATH)

echo 'Updating /etc/hosts file...'
HOSTNAME=$(hostname)
echo "127.0.1.1\t$HOSTNAME" >> /etc/hosts

echo "Starting VNC server at $RESOLUTION..."
vncserver -geometry $RESOLUTION -SecurityTypes None &

echo "Starting novnc..."
websockify --web=/usr/share/novnc/ 8099 localhost:5901
