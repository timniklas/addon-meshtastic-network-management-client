#!/bin/bash

CONFIG_PATH=/data/options.json
RESOLUTION=$(jq --raw-output '.display_resolution // empty' $CONFIG_PATH)

xfwm4 &

while true
do
    /usr/bin/Meshtastic\ Network\ Management\ Client
    sleep 1
done
