#!/usr/bin/env bash

SERVICE=ruby
#SERVICE=$(ps -A | grep ruby | head -1)

#[ -z "$SERVICE" ] &&  echo "No Ruby service running."

if P=$(pgrep $SERVICE)
then
  clear; echo "$SERVICE is running, PID is $P" && killall $SERVICE
else
  clear; echo "$SERVICE is not running"
fi
