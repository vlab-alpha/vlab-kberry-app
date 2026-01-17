#!/bin/bash

APP_NAME="smart-home-v2"
PID_FILE="/home/mradle/smart-home/$APP_NAME.pid"

if [ ! -f "$PID_FILE" ]; then
  echo "$APP_NAME läuft nicht."
  exit 0
fi

PID=$(cat "$PID_FILE")

echo "Stoppe $APP_NAME (PID $PID)..."
kill "$PID"

rm -f "$PID_FILE"
echo "Gestoppt."