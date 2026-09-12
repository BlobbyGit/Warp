#!/bin/zsh
# Breach Monitoring Script - Check if emails appear in known data breaches
# Uses Have I Been Pwned API (free, privacy-respecting)

EMAIL="${1:-jarrodstebbing@gmail.com}"

echo "🔍 Checking breach status for: $EMAIL"
echo "================================\n"

# Check Have I Been Pwned
echo "Querying Have I Been Pwned database..."
RESPONSE=$(curl -s -w "\n%{http_code}" "https://haveibeenpwned.com/api/v3/breachedaccount/${EMAIL}?truncateResponse=false" \
  -H "hibp-api-key: YOUR_API_KEY_HERE" \
  -H "User-Agent: Breach-Monitor-Script")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "\n⚠️  BREACHES FOUND:\n"
    echo "$BODY" | jq -r '.[] | "• \(.Name) (\(.BreachDate))\n  Compromised: \(.DataClasses | join(", "))\n"'
    
    BREACH_COUNT=$(echo "$BODY" | jq '. | length')
    echo "Total breaches: $BREACH_COUNT"
    
elif [ "$HTTP_CODE" = "404" ]; then
    echo "✓ No breaches found for this email"
    
elif [ "$HTTP_CODE" = "401" ]; then
    echo "❌ API key required. Get free key at: https://haveibeenpwned.com/API/Key"
    echo "\nFREE alternative (no API key needed):"
    echo "  Visit: https://haveibeenpwned.com/"
    echo "  Enter: $EMAIL"
    
else
    echo "Error checking breaches (HTTP $HTTP_CODE)"
fi

echo "\n================================"
echo "🎯 WHAT TO DO IF BREACHED:"
echo "================================"
echo "1. Change password on breached service immediately"
echo "2. Change password on ANY site using same password"
echo "3. Enable 2FA everywhere possible"
echo "4. Run: ~/bitwarden-audit.sh"
echo ""
echo "💡 The data is permanent - focus on damage control:"
echo "   • New unique passwords everywhere"
echo "   • 2FA on all accounts"
echo "   • Credit monitoring (Equifax AU, illion)"
