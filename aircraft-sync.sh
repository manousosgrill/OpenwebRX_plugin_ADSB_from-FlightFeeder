#!/bin/bash

URL="http://192.168.10.170/skyaware/data/aircraft.json"
OUT="/tmp/dump1090/aircraft.json"

mkdir -p /tmp/dump1090

while true; do
    curl -fsS --connect-timeout 2 --max-time 5 \
        "$URL" -o "$OUT.tmp" && \
        mv "$OUT.tmp" "$OUT"

    sleep 1
done
