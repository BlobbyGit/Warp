#!/bin/bash

# System Security Check Script
# Displays status and saves to iCloud

# Configuration
LOG_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/🔴_SECURITY_BACKUP copy"
LOG_FILE="$LOG_DIR/SYSTEM_STATUS_$(date +%Y%m%d).txt"

# launchd runs this with a minimal PATH (/usr/bin:/bin:/usr/sbin:/sbin), so
# Homebrew tools were reported "NOT INSTALLED" on scheduled runs despite being
# present. Prepend the Homebrew prefixes explicitly.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Create log directory if needed
mkdir -p "$LOG_DIR"

# Initialize counters
PASSED=0
TOTAL=0

# Function to generate report
generate_report() {
echo "System Security Report - $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================================"
echo ""
echo "Overall Security Score: TBD"
echo ""
echo "SECURITY COMPONENTS:"
echo "=================="
echo ""

# NetBIOS. Best-effort disable only if passwordless sudo is already available -
# never prompt, since that hangs scheduled runs. The PASS/FAIL verdict comes
# from whether netbiosd is actually running, which needs no privileges at all.
# Previously the privileged `launchctl print` meant this reported SKIPPED
# forever under launchd, even though NetBIOS was genuinely disabled.
TOTAL=$((TOTAL + 1))

echo "Disabling NetBIOS..."
sudo -n launchctl bootout system/com.apple.netbiosd 2>/dev/null

if pgrep -x netbiosd > /dev/null 2>&1; then
    echo "NetBIOS: ❌ STILL RUNNING"
else
    echo "NetBIOS: ✅ DISABLED"
    PASSED=$((PASSED + 1))
fi

echo ""

# Check YubiKey (expecting at least 1)
TOTAL=$((TOTAL + 1))
YUBIKEY_COUNT=$(ioreg -p IOUSB -l -w 0 | grep -c "YubiKey OTP+FIDO+CCID@")
YUBIKEY_INFO=$(ioreg -p IOUSB -l -w 0 | grep -A 20 "YubiKey OTP+FIDO+CCID@" | grep -E "USB Product Name|kUSBSerialNumberString" | sed 's/.*= "//;s/"//' | paste -sd '|' - | sed 's/|/ (S\/N: /g' | sed 's/$/)/g')
if [ "$YUBIKEY_COUNT" -ge 1 ]; then
    echo "✅ YubiKey: $YUBIKEY_COUNT device(s) detected"
    echo "   $YUBIKEY_INFO"
    PASSED=$((PASSED + 1))
else
    echo "❌ YubiKey: No devices detected"
fi

# Check FileVault
TOTAL=$((TOTAL + 1))
FILEVAULT_STATUS=$(fdesetup status 2>/dev/null)
if echo "$FILEVAULT_STATUS" | grep -q "On"; then
    echo "FileVault: ✅ ENABLED"
    PASSED=$((PASSED + 1))
else
    echo "FileVault: ❌ DISABLED"
fi

# Check LuLu Running and Stealth Mode
TOTAL=$((TOTAL + 1))
LULU_RUNNING=$(pgrep -i "lulu" > /dev/null && echo "yes" || echo "no")

# Note: On recent LuLu versions, preferences are stored in the user defaults domain
# (com.objective-see.lulu), not a system-wide plist under /Library/Application Support.
LULU_STEALTH=$(defaults read com.objective-see.lulu stealthMode 2>/dev/null)

if [ "$LULU_RUNNING" = "yes" ] && [ "$LULU_STEALTH" = "1" ]; then
    echo "Firewall: ✅ ENABLED (LuLu - Stealth Mode)"
    PASSED=$((PASSED + 1))
elif [ "$LULU_RUNNING" = "yes" ]; then
    echo "Firewall: ⚠️  ENABLED (LuLu - Stealth Mode OFF)"
    PASSED=$((PASSED + 1))
else
    echo "Firewall: ❌ LuLu NOT RUNNING"
fi

# Check OverSight (mic/camera monitor)
TOTAL=$((TOTAL + 1))
if pgrep -i "oversight" > /dev/null 2>&1; then
    echo "OverSight: ✅ RUNNING (mic/camera monitor)"
    PASSED=$((PASSED + 1))
else
    echo "OverSight: ❌ NOT RUNNING"
fi

# Check RansomWhere? (ransomware monitor)
TOTAL=$((TOTAL + 1))
if launchctl list 2>/dev/null | grep -q "ransomwhere" || pgrep -i "ransomwhere" > /dev/null 2>&1; then
    echo "RansomWhere?: ✅ RUNNING (ransomware monitor)"
    PASSED=$((PASSED + 1))
else
    echo "RansomWhere?: ❌ NOT RUNNING"
fi

# Check BlockBlock (persistence monitor)
TOTAL=$((TOTAL + 1))
if launchctl list 2>/dev/null | grep -q "blockblock" || pgrep -i "blockblock" > /dev/null 2>&1; then
    echo "BlockBlock: ✅ RUNNING (persistence monitor)"
    PASSED=$((PASSED + 1))
else
    echo "BlockBlock: ❌ NOT RUNNING"
fi

# Check Gatekeeper
TOTAL=$((TOTAL + 1))
GATEKEEPER_STATUS=$(spctl --status 2>/dev/null)
if echo "$GATEKEEPER_STATUS" | grep -q "enabled"; then
    echo "Gatekeeper: ✅ ENABLED"
    PASSED=$((PASSED + 1))
else
    echo "Gatekeeper: ❌ DISABLED"
fi

# Check SIP
TOTAL=$((TOTAL + 1))
SIP_STATUS=$(csrutil status 2>/dev/null)
if echo "$SIP_STATUS" | grep -q "enabled"; then
    echo "SIP: ✅ ENABLED"
    PASSED=$((PASSED + 1))
else
    echo "SIP: ❌ DISABLED"
fi

# Check DNS Protection
TOTAL=$((TOTAL + 1))
DNS_SERVERS=$(networksetup -getdnsservers Wi-Fi 2>/dev/null)
if echo "$DNS_SERVERS" | grep -q "9.9.9.9\|149.112.112.112"; then
    echo "DNS: ✅ Quad9 (encrypted)"
    PASSED=$((PASSED + 1))
elif echo "$DNS_SERVERS" | grep -q "1.1.1.1\|1.0.0.1"; then
    echo "DNS: ✅ Cloudflare (encrypted)"
    PASSED=$((PASSED + 1))
elif echo "$DNS_SERVERS" | grep -q "There aren't any"; then
    echo "DNS: ✅ iCloud Private Relay (system-managed encrypted DNS)"
    PASSED=$((PASSED + 1))
else
    echo "DNS: ⚠️  Unprotected DNS: $DNS_SERVERS"
fi

# Check iPhone connectivity
TOTAL=$((TOTAL + 1))
if system_profiler SPBluetoothDataType 2>/dev/null | grep -i "iPhone" > /dev/null; then
    echo "iPhone: ✅ CONNECTED"
    echo "   WiFi Sync: Available"
    PASSED=$((PASSED + 1))
else
    echo "iPhone: ❌ NOT CONNECTED"
fi

# Check Time Machine
TOTAL=$((TOTAL + 1))
if tmutil destinationinfo >/dev/null 2>&1; then
    LAST_BACKUP=$(tmutil latestbackup 2>/dev/null | xargs basename)
    if [ -n "$LAST_BACKUP" ]; then
        echo "Time Machine: ENABLED ✓"
        echo "Last Backup: $LAST_BACKUP"
        PASSED=$((PASSED + 1))
    else
        echo "Time Machine: ⚠️  ENABLED (No backups yet)"
    fi
else
    echo "Time Machine: ❌ NOT CONFIGURED"
fi

# Check HomePod availability.
# Matching the literal string "HomePod" never worked: AirPlay advertises the
# user-assigned name (here "Bedroom"), not the product name. Identify by the
# model TXT record instead - HomePods report model=AudioAccessory*.
TOTAL=$((TOTAL + 1))
HOMEPOD_TMP=$(mktemp)
dns-sd -B _airplay._tcp local. > "$HOMEPOD_TMP" 2>&1 &
DNS_SD_PID=$!
sleep 5
kill "$DNS_SD_PID" 2>/dev/null
wait "$DNS_SD_PID" 2>/dev/null

# Instance name is field 7 onward on "Add" lines.
AIRPLAY_NAMES=$(awk '/[[:space:]]Add[[:space:]]/ {n=""; for (i=7; i<=NF; i++) n = n (i>7 ? " " : "") $i; print n}' \
    "$HOMEPOD_TMP" | sort -u)
rm -f "$HOMEPOD_TMP"

HOMEPOD_NAME=""
while IFS= read -r airplay_name; do
    [ -z "$airplay_name" ] && continue
    RESOLVE_TMP=$(mktemp)
    dns-sd -L "$airplay_name" _airplay._tcp local. > "$RESOLVE_TMP" 2>&1 &
    RESOLVE_PID=$!
    sleep 2
    kill "$RESOLVE_PID" 2>/dev/null
    wait "$RESOLVE_PID" 2>/dev/null
    if grep -q "model=AudioAccessory" "$RESOLVE_TMP"; then
        HOMEPOD_NAME="$airplay_name"
        rm -f "$RESOLVE_TMP"
        break
    fi
    rm -f "$RESOLVE_TMP"
done <<< "$AIRPLAY_NAMES"

if [ -n "$HOMEPOD_NAME" ]; then
    echo "HomePod: ✅ AVAILABLE ($HOMEPOD_NAME)"
    PASSED=$((PASSED + 1))
else
    echo "HomePod: ❌ NOT AVAILABLE"
fi

# Homebrew Security Tools
echo ""
echo "BREW SECURITY TOOLS:"
echo "===================="
echo ""

# GPG (gnupg)
TOTAL=$((TOTAL + 1))
if command -v gpg > /dev/null 2>&1; then
    GPG_VERSION=$(gpg --version | head -1 | awk '{print $3}')
    echo "GPG: ✅ INSTALLED (v$GPG_VERSION)"
    PASSED=$((PASSED + 1))
else
    echo "GPG: ❌ NOT INSTALLED"
fi

# pinentry-mac
TOTAL=$((TOTAL + 1))
if [ -f "/opt/homebrew/bin/pinentry-mac" ] && grep -q "pinentry-mac" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo "pinentry-mac: ✅ INSTALLED & CONFIGURED"
    PASSED=$((PASSED + 1))
elif [ -f "/opt/homebrew/bin/pinentry-mac" ]; then
    echo "pinentry-mac: ⚠️  INSTALLED (not configured in gpg-agent.conf)"
else
    echo "pinentry-mac: ❌ NOT INSTALLED"
fi

# nmap
TOTAL=$((TOTAL + 1))
if command -v nmap > /dev/null 2>&1; then
    NMAP_VERSION=$(nmap --version | head -1 | awk '{print $3}')
    echo "nmap: ✅ INSTALLED (v$NMAP_VERSION)"
    PASSED=$((PASSED + 1))
else
    echo "nmap: ❌ NOT INSTALLED"
fi

# Network Security
echo ""
echo "NETWORK SECURITY:"
echo "================="
echo ""

# Local network device scan
TOTAL=$((TOTAL + 1))
LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null)
if ! command -v nmap > /dev/null 2>&1; then
    # This used to still count as a pass, reporting "0 device(s)" when nmap was
    # simply missing from PATH - a scan that never ran looked like a clean one.
    echo "Network Scan: ❌ nmap not available"
elif [ -n "$LOCAL_IP" ]; then
    SUBNET=$(echo "$LOCAL_IP" | awk -F. '{print $1"."$2"."$3".0/24"}')
    DEVICE_COUNT=$(nmap -sn --host-timeout 3s "$SUBNET" 2>/dev/null | grep -c "Nmap scan report")
    echo "Network Scan: ✅ $DEVICE_COUNT device(s) on $SUBNET"
    PASSED=$((PASSED + 1))
else
    echo "Network Scan: ⚠️  Wi-Fi (en0) not active"
fi

# System Info
echo ""
echo "SYSTEM INFO:"
echo "============"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Hostname: $(hostname)"
if [ -d "/Volumes/SD" ]; then
    echo "Report generated from: SD card available"
else
    echo "Report generated from: Local Mac (not SD card)"
fi
echo ""
}

# Call the function and capture output
generate_report > "$LOG_FILE"

# Update the security score in the file
SCORE="$PASSED/$TOTAL"
sed -i.bak "s|Overall Security Score: TBD|Overall Security Score: $SCORE|" "$LOG_FILE" && rm -f "$LOG_FILE.bak"

# Display the report
cat "$LOG_FILE"

# Display summary
echo ""
if [ "$PASSED" -eq "$TOTAL" ]; then
    echo "✅ All checks passed! ($SCORE)"
else
    FAILED=$((TOTAL - PASSED))
    echo "⚠️  $FAILED check(s) failed. Score: $SCORE"
fi
echo ""
echo "Report saved to: $LOG_FILE"
