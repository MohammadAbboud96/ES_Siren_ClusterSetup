#!/bin/bash

# Define variables
SIREN_DIR="/opt/siren-investigate"
BACKUP_DIR="/home/siren/backup_dir"
#TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
DATE=$(date +"%Y-%m-%d")"/"$(date +"%H-%M-%S")
LOG_FILE="/home/siren/log-siren-backup/siren_backup.log"

# Function to log messages
log_message() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$LOG_FILE"
}

log_message "Starting Siren Investigate backup..."

log_message "Creating $DATE folder..."
mkdir -p "$BACKUP_DIR/$DATE"

# Step 1: Backup Config files
log_message "Backing up configuration file..."
cp -r $SIREN_DIR/config/ "$BACKUP_DIR/$DATE/config"

if [ $? -ne 0 ]; then
  log_message "Failed to backup config folder."
  exit 1
fi

# Step 2: Backup pki directory
log_message "Backing up certificates and keys..."
sudo cp -r "$SIREN_DIR/pki" "$BACKUP_DIR/$DATE/pki"

if [ $? -ne 0 ]; then
  log_message "Failed to backup pki directory."
  exit 1
fi

# Step 3: Backup saved objects and security index
log_message "Backing up indices..."
"$SIREN_DIR/bin/investigate" backup --backup-dir="$BACKUP_DIR/$DATE/indices"

if [ $? -ne 0 ]; then
  log_message "Failed to backup indices."
  exit 1
fi

log_message "Siren Investigate backup completed successfully."
log_message "-----------------------------------------------------------------------------------"
