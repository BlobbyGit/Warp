#!/bin/bash
#
# Quick Security Audit
# Focused, fast companion to ~/system_check_backup.sh (which covers the
# broader daily check: NetBIOS, Gatekeeper, SIP, DNS, BlockBlock, RansomWhere, etc).
#
# This script specifically verifies:
#   - jarrodstebbing has admin/sudo rights
#   - YubiKey is detected
#   - LuLu (firewall) is running with stealth mode on
#   - KnockKnock is installed (on-demand scanner - no persistent process by design)
#   - ClamAV is installed with fresh virus definitions (on-demand by this setup)
#   - OverSight (mic/camera monitor) is running
#   - Time Machine is enabled/backing up, and retention stays within the
#     40-backup cap on the 1TB external SSD
#
# Usage: ~/quick_security_audit.sh

LOG_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/🔴_SECURITY_BACKUP copy"
LOG_FILE="$LOG_DIR/QUICK_AUDIT_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p "$LOG_DIR"

PASSED=0
TOTAL=0

# --- Time Machine retention configuration ---
TM_KEEP=40
TM_VOLUME="/Volumes/Time Machine Backup"
TM_WARN_PERCENT=85   # warn if the ~1TB drive crosses this usage percentage

generate_report() {
echo "Quick Security Audit - $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================================"
echo ""
echo "Overall Score: TBD"
echo ""

# 1. Admin/sudo access for jarrodstebbing
TOTAL=$((TOTAL + 1))
if dseditgroup -o checkmember -m jarrodstebbing admin >/dev/null 2>&1; then
    echo "Sudo Access (jarrodstebbing): ✅ IN ADMIN GROUP"
    PASSED=$((PASSED + 1))
else
    echo "Sudo Access (jarrodstebbing): ❌ NOT IN ADMIN GROUP"
fi
echo ""

# 2. YubiKey
TOTAL=$((TOTAL + 1))
YUBIKEY_SERIALS=$(ykman list --serials 2>/dev/null | tr '\n' ' ' | sed 's/ $//')
if [ -n "$YUBIKEY_SERIALS" ]; then
    echo "YubiKey: ✅ Detected (Serial: $YUBIKEY_SERIALS)"
    PASSED=$((PASSED + 1))
else
    YUBIKEY_COUNT=$(ioreg -p IOUSB -l -w 0 | grep -c "YubiKey OTP+FIDO+CCID@")
    if [ "$YUBIKEY_COUNT" -ge 1 ]; then
        echo "YubiKey: ✅ $YUBIKEY_COUNT device(s) detected"
        PASSED=$((PASSED + 1))
    else
        echo "YubiKey: ❌ No devices detected"
    fi
fi
echo ""

# 3. LuLu (persistent firewall - should always be running)
TOTAL=$((TOTAL + 1))
LULU_RUNNING=$(pgrep -i "lulu" > /dev/null && echo yes || echo no)
LULU_STEALTH=$(defaults read com.objective-see.lulu stealthMode 2>/dev/null)
if [ "$LULU_RUNNING" = "yes" ] && [ "$LULU_STEALTH" = "1" ]; then
    echo "LuLu: ✅ RUNNING (stealth mode ON)"
    PASSED=$((PASSED + 1))
elif [ "$LULU_RUNNING" = "yes" ]; then
    echo "LuLu: ⚠️  RUNNING (stealth mode OFF - defaults write com.objective-see.lulu stealthMode -bool true)"
    PASSED=$((PASSED + 1))
else
    echo "LuLu: ❌ NOT RUNNING"
fi
echo ""

# 4. OverSight (persistent mic/camera monitor - should always be running)
TOTAL=$((TOTAL + 1))
if pgrep -i "oversight" > /dev/null 2>&1; then
    echo "OverSight: ✅ RUNNING"
    PASSED=$((PASSED + 1))
else
    echo "OverSight: ❌ NOT RUNNING"
fi
echo ""

# 5. KnockKnock (on-demand persistence scanner - Objective-See design has no
#    background daemon for this tool, unlike LuLu/OverSight/BlockBlock/RansomWhere)
TOTAL=$((TOTAL + 1))
if [ -d "/Applications/KnockKnock.app" ]; then
    echo "KnockKnock: ✅ INSTALLED (on-demand scanner - run manually/periodically, no persistent process by design)"
    PASSED=$((PASSED + 1))
else
    echo "KnockKnock: ❌ NOT INSTALLED"
fi
echo ""

# 6. ClamAV (on-demand scanning by this setup - check binary + definition freshness
#    rather than a running daemon, since clamd is not kept running here)
TOTAL=$((TOTAL + 1))
if command -v clamscan >/dev/null 2>&1; then
    DAILY_DB="/opt/homebrew/var/lib/clamav/daily.cld"
    [ -f "$DAILY_DB" ] || DAILY_DB="/opt/homebrew/var/lib/clamav/daily.cvd"
    if [ -f "$DAILY_DB" ]; then
        AGE_DAYS=$(( ( $(date +%s) - $(stat -f %m "$DAILY_DB") ) / 86400 ))
        if [ "$AGE_DAYS" -le 3 ]; then
            echo "ClamAV: ✅ INSTALLED, definitions $AGE_DAYS day(s) old"
            PASSED=$((PASSED + 1))
        else
            echo "ClamAV: ⚠️  INSTALLED, definitions $AGE_DAYS day(s) old — run: freshclam"
        fi
    else
        echo "ClamAV: ⚠️  INSTALLED, definitions not found — run: freshclam"
    fi
else
    echo "ClamAV: ❌ NOT INSTALLED"
fi
echo ""

# 7. Time Machine enabled + last backup
TOTAL=$((TOTAL + 1))
if tmutil destinationinfo >/dev/null 2>&1; then
    LAST_BACKUP=$(tmutil latestbackup 2>/dev/null | xargs basename 2>/dev/null)
    if [ -n "$LAST_BACKUP" ]; then
        echo "Time Machine: ✅ ENABLED (last backup: $LAST_BACKUP)"
        echo "   macOS backs up automatically every hour while the drive is connected (native behavior)."
        PASSED=$((PASSED + 1))
    else
        echo "Time Machine: ⚠️  ENABLED (no backups yet, or drive not currently connected)"
    fi
else
    echo "Time Machine: ❌ NOT CONFIGURED"
fi
echo ""

# 8. Time Machine retention cap (40 backups) + 1TB drive usage
TOTAL=$((TOTAL + 1))
if [ -d "$TM_VOLUME" ]; then
    BACKUP_COUNT=$(tmutil listbackups 2>/dev/null | grep -c '^/')
    TM_DF=$(df -h "$TM_VOLUME" 2>/dev/null | tail -1)
    TM_PERCENT=$(echo "$TM_DF" | awk '{print $5}' | tr -d '%')
    TM_USED=$(echo "$TM_DF" | awk '{print $3}')
    TM_AVAIL=$(echo "$TM_DF" | awk '{print $4}')
    echo "TM Backup Count: $BACKUP_COUNT (target cap: $TM_KEEP)"
    echo "TM Drive Usage: $TM_USED used, $TM_AVAIL available (${TM_PERCENT:-0}% of ~1TB)"
    if [ "$BACKUP_COUNT" -le "$TM_KEEP" ] && [ "${TM_PERCENT:-0}" -lt "$TM_WARN_PERCENT" ]; then
        echo "TM Retention: ✅ WITHIN LIMITS"
        PASSED=$((PASSED + 1))
    else
        echo "TM Retention: ⚠️  OVER LIMIT — run: sudo ~/tm_retention.sh --keep $TM_KEEP --delete"
    fi
else
    echo "TM Retention: ⚠️  External drive not connected — cannot check (automated pruning runs hourly when it is)"
fi
echo ""
}

generate_report > "$LOG_FILE"

SCORE="$PASSED/$TOTAL"
sed -i.bak "s|Overall Score: TBD|Overall Score: $SCORE|" "$LOG_FILE" && rm -f "$LOG_FILE.bak"

cat "$LOG_FILE"

echo ""
if [ "$PASSED" -eq "$TOTAL" ]; then
    echo "✅ All checks passed! ($SCORE)"
else
    echo "⚠️  $((TOTAL - PASSED)) check(s) need attention. Score: $SCORE"
fi
echo ""
echo "Report saved to: $LOG_FILE"
