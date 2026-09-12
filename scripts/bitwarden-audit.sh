#!/bin/zsh
# Bitwarden Security Audit Script
# Analyzes vault for weak passwords, reused passwords, and missing 2FA

echo "🔐 Bitwarden Security Audit"
echo "==========================\n"

# Check if logged in
if ! bw status | jq -e '.status == "unlocked"' > /dev/null 2>&1; then
    echo "❌ Bitwarden is locked. Please unlock first with: bw unlock"
    exit 1
fi

# Get session
BW_SESSION=$(bw unlock --raw 2>/dev/null)
export BW_SESSION

# Total items
TOTAL=$(bw list items --session "$BW_SESSION" | jq 'length')
echo "📊 Total vault items: $TOTAL\n"

# Count login items
LOGINS=$(bw list items --session "$BW_SESSION" | jq '[.[] | select(.type == 1)] | length')
echo "🔑 Login items: $LOGINS\n"

# Check for weak passwords (< 12 characters)
echo "⚠️  Weak passwords (< 12 characters):"
bw list items --session "$BW_SESSION" | jq -r '
    [.[] | select(.type == 1 and .login.password != null) | 
    select((.login.password | length) < 12) | 
    {name: .name, username: .login.username, length: (.login.password | length)}] | 
    sort_by(.length) | 
    .[] | "  • \(.name) (\(.username)) - \(.length) chars"
' | head -20

WEAK_COUNT=$(bw list items --session "$BW_SESSION" | jq '[.[] | select(.type == 1 and .login.password != null) | select((.login.password | length) < 12)] | length')
echo "  Total: $WEAK_COUNT\n"

# Check for duplicate passwords
echo "🔄 Duplicate/Reused passwords:"
bw list items --session "$BW_SESSION" | jq -r '
    [.[] | select(.type == 1 and .login.password != null) | 
    {name: .name, password: .login.password}] | 
    group_by(.password) | 
    map(select(length > 1)) | 
    .[] | 
    "  • Password reused across: \(map(.name) | join(", "))"
' | head -20

REUSED_COUNT=$(bw list items --session "$BW_SESSION" | jq '[.[] | select(.type == 1 and .login.password != null) | .login.password] | group_by(.) | map(select(length > 1)) | length')
echo "  Total reused passwords: $REUSED_COUNT\n"

# Check for missing 2FA
echo "🔐 Accounts without 2FA (where available):"
bw list items --session "$BW_SESSION" | jq -r '
    [.[] | select(.type == 1 and .login.totp == null) | 
    {name: .name, username: .login.username}] | 
    sort_by(.name) | 
    .[] | "  • \(.name) (\(.username))"
' | head -30

NO_2FA_COUNT=$(bw list items --session "$BW_SESSION" | jq '[.[] | select(.type == 1 and .login.totp == null)] | length')
echo "  Total without 2FA configured: $NO_2FA_COUNT\n"

# Summary
echo "═══════════════════════════════════"
echo "📋 SECURITY SUMMARY"
echo "═══════════════════════════════════"
echo "✓ Strong passwords: $((LOGINS - WEAK_COUNT))"
echo "⚠️  Weak passwords: $WEAK_COUNT"
echo "🔄 Reused passwords: $REUSED_COUNT"
echo "❌ Missing 2FA: $NO_2FA_COUNT"
echo ""

# Recommendations
if [ "$WEAK_COUNT" -gt 0 ] || [ "$REUSED_COUNT" -gt 0 ]; then
    echo "🎯 RECOMMENDATIONS:"
    [ "$WEAK_COUNT" -gt 0 ] && echo "  1. Update weak passwords to 16+ characters"
    [ "$REUSED_COUNT" -gt 0 ] && echo "  2. Generate unique passwords for reused credentials"
    [ "$NO_2FA_COUNT" -gt 10 ] && echo "  3. Enable 2FA on critical accounts (email, banking, social)"
    echo ""
    echo "Use Bitwarden's password generator:"
    echo "  bw generate --length 20 --uppercase --lowercase --number --special"
fi
