#!/bin/bash

LOGFILE=~/temperature_log.txt

while true; do
    echo "$(date)" >> $LOGFILE
    sensors >> $LOGFILE
    echo "" >> $LOGFILE
    sleep 30   # Log every 5 minutes = 300
done

