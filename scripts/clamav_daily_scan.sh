#!/bin/bash

# Daily ClamAV Signature Update + Malware Scan
# Scheduled by: ~/Library/LaunchAgents/com.user.clamav-daily.plist
#
# Behaviour: silent when clean, macOS notification when something is found.
# Detected files are REPORTED ONLY - nothing is moved, quarantined or deleted.
#
# Exit codes:  0 = clean   1 = detections found   2 = error

# Note: no `set -e`. clamscan exits 1 on detection and 2 on error, both of
# which are outcomes we want to handle, not abort on.
set -uo pipefail

# ---------------------------------------------------------------- configuration

CLAMSCAN="/opt/homebrew/bin/clamscan"
FRESHCLAM="/opt/homebrew/bin/freshclam"
FRESHCLAM_CONF="$HOME/.config/clamav/freshclam.conf"
DB_DIR="/opt/homebrew/var/lib/clamav"

LOG_DIR="$HOME/Library/Logs/system_diagnostics"
SCAN_LOG="$LOG_DIR/clamav_$(date +%Y-%m-%d).log"
LOCK_DIR="/tmp/com.user.clamav-daily.lock"

RETENTION_DAYS=30
STALE_DB_DAYS=3          # warn if signatures are older than this

# What to scan. Add or remove paths here.
SCAN_TARGETS=(
    "$HOME"
    "/Applications"
)

# Optional colon-separated override for ad-hoc or test runs, e.g.
#   CLAMAV_SCAN_TARGETS="$HOME/Downloads:/tmp/foo" ~/.local/bin/clamav_daily_scan.sh
# The LaunchAgent never sets this, so scheduled runs always use the list above.
if [ -n "${CLAMAV_SCAN_TARGETS:-}" ]; then
    IFS=':' read -r -a SCAN_TARGETS <<< "$CLAMAV_SCAN_TARGETS"
fi

# Directories skipped, as regexes matched against the full path.
# Rationale for each is deliberate - do not prune blindly.
EXCLUDE_DIRS=(
    "^$HOME/Library/Caches/"                    # churn, regenerated constantly
    "^$HOME/Library/Logs/"                      # our own logs, no executables
    "^$HOME/Library/Mobile Documents/"          # iCloud: scanning forces downloads
    "^$HOME/Library/CloudStorage/"              # ditto for 3rd-party cloud providers
    "^$HOME/Library/Application Support/CloudDocs/"
    "^$HOME/Library/Developer/CoreSimulator/"   # huge, disposable simulator runtimes
    "^/Volumes/"                                # never wander onto Time Machine/externals
)

# Size ceilings. Files above these are skipped by clamscan (defaults are a much
# lower 25M/100M). Raising them costs scan time but catches large droppers.
MAX_FILESIZE="100M"
MAX_SCANSIZE="400M"

# ---------------------------------------------------------------- helpers

mkdir -p "$LOG_DIR"

log() {
    printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$1" >> "$SCAN_LOG"
}

section() {
    {
        echo ""
        echo "$1"
        echo "${1//?/=}"
    } >> "$SCAN_LOG"
}

notify() {
    local title="$1" subtitle="$2" message="$3"
    /usr/bin/osascript -e "display notification \"$message\" with title \"$title\" subtitle \"$subtitle\"" 2>/dev/null
}

finish() {
    local code="$1"
    {
        echo ""
        echo "Scan finished: $(date)"
        echo "Log file: $SCAN_LOG"
        echo "Exit code: $code"
    } >> "$SCAN_LOG"

    # Prune old scan logs.
    find "$LOG_DIR" -name 'clamav_*.log' -mtime +"$RETENTION_DAYS" -delete 2>/dev/null
    exit "$code"
}

# ---------------------------------------------------------------- preflight

# Single-instance guard: a full scan can outlive its 24h window on a slow day.
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    log "SKIPPED: another clamav_daily_scan is already running (lock: $LOCK_DIR)"
    exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

{
    echo "=========================================="
    echo "DAILY CLAMAV SCAN"
    echo "=========================================="
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "macOS: $(sw_vers -productVersion)"
    echo ""
} > "$SCAN_LOG"

if [ ! -x "$CLAMSCAN" ]; then
    log "ERROR: clamscan not found at $CLAMSCAN - is clamav installed? (brew install clamav)"
    notify "⚠️ ClamAV Scan" "Cannot run" "clamscan binary missing"
    finish 2
fi

# ---------------------------------------------------------------- 1. signatures

section "🔄 SIGNATURE UPDATE"

if [ -x "$FRESHCLAM" ] && [ -f "$FRESHCLAM_CONF" ]; then
    if "$FRESHCLAM" --config-file="$FRESHCLAM_CONF" --quiet >> "$SCAN_LOG" 2>&1; then
        echo "✅ Signatures updated" >> "$SCAN_LOG"
    else
        # Non-fatal: scan with whatever database we already have.
        echo "⚠️ freshclam update failed - scanning with existing database" >> "$SCAN_LOG"
    fi
else
    echo "⚠️ freshclam or its config missing - skipping update" >> "$SCAN_LOG"
fi

# Report actual database age regardless of update outcome.
DB_VERSION=$("$CLAMSCAN" --version 2>/dev/null)
echo "Engine/DB: $DB_VERSION" >> "$SCAN_LOG"

DB_STALE=0
NEWEST_DB=$(find "$DB_DIR" \( -name 'daily.cld' -o -name 'daily.cvd' \) -print 2>/dev/null | head -1)
if [ -n "$NEWEST_DB" ]; then
    DB_AGE_DAYS=$(( ( $(date +%s) - $(stat -f %m "$NEWEST_DB") ) / 86400 ))
    if [ "$DB_AGE_DAYS" -gt "$STALE_DB_DAYS" ]; then
        echo "⚠️ Signature database is $DB_AGE_DAYS days old" >> "$SCAN_LOG"
        DB_STALE=1
    else
        echo "✅ Signature database age: $DB_AGE_DAYS day(s)" >> "$SCAN_LOG"
    fi
fi

# ---------------------------------------------------------------- 2. scan

section "🔍 SCAN"

scan_args=(
    --recursive
    --infected                 # only list detections, not every clean file
    --stdout
    --cross-fs=no              # do not follow onto mounted volumes
    --max-filesize="$MAX_FILESIZE"
    --max-scansize="$MAX_SCANSIZE"
    --max-recursion=16
    --follow-dir-symlinks=0
    --follow-file-symlinks=0
)
for d in "${EXCLUDE_DIRS[@]}"; do
    scan_args+=( "--exclude-dir=$d" )
done

{
    echo "Targets: ${SCAN_TARGETS[*]}"
    echo "Started: $(date)"
    echo ""
} >> "$SCAN_LOG"

SECONDS=0
/usr/bin/nice -n 19 "$CLAMSCAN" "${scan_args[@]}" "${SCAN_TARGETS[@]}" >> "$SCAN_LOG" 2>&1
SCAN_RC=$?
ELAPSED=$SECONDS

# ---------------------------------------------------------------- 3. summary

section "📊 SUMMARY"

# Capture detections up front. Note: never pipe the log into itself while also
# appending to it - grep -c already prints 0 on no match, so no `|| echo 0`
# fallback (that would emit two values and break the arithmetic below).
DETECTIONS=$(grep ' FOUND$' "$SCAN_LOG" 2>/dev/null)
INFECTED_COUNT=$(grep -c ' FOUND$' "$SCAN_LOG" 2>/dev/null)
# Files clamscan could not read - usually TCC protection rather than real errors.
DENIED_COUNT=$(grep -c -E "Can't open file|Access denied|lstat\(\) failed|Permission denied" "$SCAN_LOG" 2>/dev/null)

{
    echo "Duration: $((ELAPSED / 60))m $((ELAPSED % 60))s"
    echo "Detections: $INFECTED_COUNT"
    echo "Unreadable files: $DENIED_COUNT"
} >> "$SCAN_LOG"

if [ "$DENIED_COUNT" -gt 0 ]; then
    echo "Note: unreadable files are usually TCC-protected paths. Grant Full Disk" >> "$SCAN_LOG"
    echo "      Access to /bin/bash to scan Mail, Messages and Safari data." >> "$SCAN_LOG"
fi

case "$SCAN_RC" in
    0)
        echo "Status: CLEAN" >> "$SCAN_LOG"
        # Still surface a stale database - a clean result means little without
        # current signatures.
        if [ "$DB_STALE" -eq 1 ]; then
            notify "⚠️ ClamAV Scan" "Signatures out of date" "Scan clean, but database is $DB_AGE_DAYS days old"
        fi
        finish 0
        ;;
    1)
        # Status token deliberately does NOT end in "FOUND": consumers grep the
        # log for ' FOUND$' to list detections, and a status line ending in
        # FOUND would be miscounted as a detection itself.
        {
            echo "Status: INFECTED"
            echo ""
            echo "DETECTED:"
            printf '%s\n' "$DETECTIONS" | sed 's/^/- /'
        } >> "$SCAN_LOG"
        notify "🚨 ClamAV Scan" "$INFECTED_COUNT detection(s)" "Review $SCAN_LOG - nothing was deleted"
        finish 1
        ;;
    *)
        echo "Status: ERROR (clamscan exit $SCAN_RC)" >> "$SCAN_LOG"
        notify "⚠️ ClamAV Scan" "Scan error" "clamscan exited $SCAN_RC - see $SCAN_LOG"
        finish 2
        ;;
esac
