#!/bin/bash

APP_NAME="smart-home-v2"
JAR_PATH="/home/mradle/smart-home/smart-home-v2.jar"
LOG_DIR="/home/mradle/smart-home/logs"
LOG_FILE="$LOG_DIR/$APP_NAME.log"
PID_FILE="/home/mradle/smart-home/$APP_NAME.pid"

JAVA_OPTS="-Xms256m -Xmx512m"

mkdir -p "$LOG_DIR"

if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "$APP_NAME läuft bereits (PID $(cat "$PID_FILE"))"
  exit 0
fi

echo "Starte $APP_NAME..."

nohup java $JAVA_OPTS -jar "$JAR_PATH" \
  > "$LOG_FILE" 2>&1 &

echo $! > "$PID_FILE"

echo "$APP_NAME gestartet."
echo "PID: $(cat "$PID_FILE")"
echo "Log: $LOG_FILE"