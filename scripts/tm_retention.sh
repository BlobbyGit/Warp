#!/bin/bash
# =============================================================================
# Time Machine Backup Retention Manager
# Keeps the N most recent backups and deletes older ones.
# Usage:
#   sudo ~/tm_retention.sh              # Dry run (preview only)
#   sudo ~/tm_retention.sh --delete     # Actually delete old backups
#   sudo ~/tm_retention.sh --keep 40    # Keep 40 backups (dry run)
#   sudo ~/tm_retention.sh --keep 40 --delete  # Keep 40, delete the rest
# =============================================================================

set -o pipefail

# --- Defaults ---
KEEP=30
DRY_RUN=true
LOG_FILE="/tmp/tm_retention.log"

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --keep)
            KEEP="$2"
            shift 2
            ;;
        --delete)
            DRY_RUN=false
            shift
            ;;
        --help|-h)
            echo "Usage: sudo $0 [--keep N] [--delete]"
            echo "  --keep N     Number of recent backups to keep (default: 30)"
            echo "  --delete     Actually delete old backups (default: dry run)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run with --help for usage."
            exit 1
            ;;
    esac
done

# --- Require root ---
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run with sudo."
    exit 1
fi

# --- Logging ---
log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

log "========================================="
log "Time Machine Retention Manager"
log "Keep: $KEEP most recent backups"
if $DRY_RUN; then
    log "Mode: DRY RUN (no deletions)"
else
    log "Mode: DELETE"
fi
log "========================================="

# --- Get all backups (oldest first) ---
BACKUPS=$(tmutil listbackups 2>/dev/null)
if [[ -z "$BACKUPS" ]]; then
    log "Error: No backups found or unable to list backups."
    log "Make sure Time Machine drive is connected."
    exit 1
fi

TOTAL=$(echo "$BACKUPS" | wc -l | tr -d ' ')
log "Total backups found: $TOTAL"

if [[ "$TOTAL" -le "$KEEP" ]]; then
    log "Nothing to do — $TOTAL backups is within the retention limit of $KEEP."
    exit 0
fi

TO_DELETE=$((TOTAL - KEEP))
log "Backups to remove: $TO_DELETE"
log "-----------------------------------------"

# --- List what will be kept ---
log "KEEPING ($KEEP most recent):"
echo "$BACKUPS" | tail -n "$KEEP" | while read -r backup; do
    # Extract just the date portion from the path
    BDATE=$(basename "$backup" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    log "  ✓ $BDATE  ($backup)"
done

log "-----------------------------------------"

# --- Process deletions ---
DELETED=0
FAILED=0

echo "$BACKUPS" | head -n "$TO_DELETE" | while read -r backup; do
    BDATE=$(basename "$backup" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')

    if $DRY_RUN; then
        log "  [DRY RUN] Would delete: $BDATE  ($backup)"
    else
        log "  Deleting: $BDATE ..."
        if tmutil delete "$backup" 2>>"$LOG_FILE"; then
            log "  ✓ Deleted: $BDATE"
            DELETED=$((DELETED + 1))
        else
            log "  ✗ Failed to delete: $BDATE"
            FAILED=$((FAILED + 1))
        fi
    fi
done

log "-----------------------------------------"
if $DRY_RUN; then
    log "DRY RUN complete. Run with --delete to actually remove backups."
else
    log "Done. Deleted: $DELETED, Failed: $FAILED"
fi

# --- Show disk space ---
DF_OUTPUT=$(df -h /Volumes/Time\ Machine\ Backup 2>/dev/null | tail -1)
if [[ -n "$DF_OUTPUT" ]]; then
    AVAIL=$(echo "$DF_OUTPUT" | awk '{print $4}')
    USED=$(echo "$DF_OUTPUT" | awk '{print $5}')
    log "Drive space — Used: $USED, Available: $AVAIL"
fi

log "Log saved to: $LOG_FILE"
