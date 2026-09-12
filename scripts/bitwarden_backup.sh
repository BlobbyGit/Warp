#!/bin/bash

# 🔐 Bitwarden Encrypted Backup Script
# Created: 2025-12-12
# Purpose: Export and encrypt Bitwarden vault to external storage

# Configuration
BACKUP_DIR="/Volumes/SD/BitwardenBackups"
GPG_KEY_ID="FED23511C3B0FCB2AC65869A7FE959C625FFBE69"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
TEMP_FILE="bw_backup_${TIMESTAMP}.json"
ENCRYPTED_FILE="bw_backup_${TIMESTAMP}.json.gpg"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔐 Bitwarden Backup Script"
echo "=========================="
echo ""

# Check if Bitwarden CLI is installed
if ! command -v bw &> /dev/null; then
    echo -e "${RED}❌ Error: Bitwarden CLI (bw) is not installed${NC}"
    echo "Install with: brew install bitwarden-cli"
    exit 1
fi

# Check if GPG is installed
if ! command -v gpg &> /dev/null; then
    echo -e "${RED}❌ Error: GPG is not installed${NC}"
    echo "Install with: brew install gnupg"
    exit 1
fi

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ Error: Backup directory does not exist: $BACKUP_DIR${NC}"
    echo "Please ensure your SD card is mounted at /Volumes/SD/"
    exit 1
fi

# Check Bitwarden login status
BW_STATUS=$(bw status | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if [ "$BW_STATUS" == "unauthenticated" ]; then
    echo -e "${RED}❌ Error: Not logged in to Bitwarden${NC}"
    echo "Please login first with: bw login"
    exit 1
fi

if [ "$BW_STATUS" == "locked" ]; then
    echo -e "${RED}❌ Error: Vault is locked${NC}"
    echo "Please unlock your vault with: bw unlock"
    echo "Then set the session key: export BW_SESSION=\"your_session_key\""
    exit 1
fi

if [ "$BW_STATUS" != "unlocked" ]; then
    echo -e "${RED}❌ Error: Unknown Bitwarden status: $BW_STATUS${NC}"
    exit 1
fi

# Export vault
echo -e "${YELLOW}📤 Exporting Bitwarden vault...${NC}"
cd "$BACKUP_DIR" || exit 1

if bw export --format json --output "$TEMP_FILE" --raw; then
    echo -e "${GREEN}✓ Export successful${NC}"
else
    echo -e "${RED}❌ Error: Export failed${NC}"
    exit 1
fi

# Encrypt the backup
echo -e "${YELLOW}🔒 Encrypting backup with BrainPool-512...${NC}"
if gpg --encrypt --recipient "$GPG_KEY_ID" --cipher-algo AES256 --compress-algo 2 --trust-model always --output "$ENCRYPTED_FILE" "$TEMP_FILE"; then
    echo -e "${GREEN}✓ Encryption successful (BrainPool-512)${NC}"
    
    # Remove unencrypted file
    echo -e "${YELLOW}🧹 Cleaning up unencrypted file...${NC}"
    rm -f "$TEMP_FILE"
    echo -e "${GREEN}✓ Cleanup complete${NC}"
else
    echo -e "${RED}❌ Error: Encryption failed${NC}"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Display results
echo ""
echo -e "${GREEN}✅ Backup completed successfully!${NC}"
echo ""
echo "📁 Backup saved to:"
echo "   $BACKUP_DIR/$ENCRYPTED_FILE"
echo ""
echo "📊 Recent backups:"
ls -lht "$BACKUP_DIR"/*.gpg 2>/dev/null | head -5

# Display backup count and cleanup old backups
MAX_BACKUPS=10
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.gpg 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "📈 Total backups: $BACKUP_COUNT"

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    EXCESS=$((BACKUP_COUNT - MAX_BACKUPS))
    echo -e "${YELLOW}🧹 Removing $EXCESS old backup(s) to maintain max of $MAX_BACKUPS...${NC}"
    ls -1t "$BACKUP_DIR"/*.gpg 2>/dev/null | tail -n "$EXCESS" | while read -r old_backup; do
        echo "   Deleting: $(basename "$old_backup")"
        rm -f "$old_backup"
    done
    BACKUP_COUNT=$MAX_BACKUPS
    echo -e "${GREEN}✓ Cleanup complete. $BACKUP_COUNT backups remaining.${NC}"
fi

echo ""
echo "🔓 To restore, use:"
echo "   gpg --decrypt $BACKUP_DIR/$ENCRYPTED_FILE > restored_backup.json"
