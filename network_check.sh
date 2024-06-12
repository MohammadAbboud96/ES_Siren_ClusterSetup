#!/bin/bash

# Function to check the status of the network service
check_network_service() {
    if command -v systemctl &> /dev/null; then
        sudo systemctl is-active --quiet networking.service
    else
        sudo service networking status &> /dev/null
    fi
}

# Function to restart the network service
restart_network_service() {
    if command -v systemctl &> /dev/null; then
        sudo systemctl restart networking.service
    else
        sudo service networking restart
    fi
}
# Main loop to check network status every minute
while true; do
    if ! check_network_service; then
        restart_network_service
    fi
    sleep 100
done

## After writing this file change the mode using:
#### chmod +x network_check.sh