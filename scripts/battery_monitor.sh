#!/bin/bash

# Battery monitor - alerts when battery reaches 24%
THRESHOLD=24
CHECK_INTERVAL=60  # Check every 60 seconds

while true; do
    # Get current battery percentage
    BATTERY_LEVEL=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
    
    # Check if on battery power (not charging)
    POWER_SOURCE=$(pmset -g batt | grep -o "AC Power\|Battery Power")
    
    if [ "$POWER_SOURCE" = "Battery Power" ] && [ "$BATTERY_LEVEL" -le "$THRESHOLD" ]; then
        # Trigger notification
        osascript -e "display notification \"Battery at ${BATTERY_LEVEL}% - Time to charge!\" with title \"Battery Alert\" sound name \"Submarine\""
        
        # Optional: Also trigger a voice alert
        say "Battery at ${BATTERY_LEVEL} percent"
        
        # Exit after alert (remove this line if you want continuous monitoring)
        exit 0
    fi
    
    sleep $CHECK_INTERVAL
done
