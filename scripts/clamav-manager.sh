#!/bin/zsh
# ClamAV Manager - Quick access to scanning and monitoring
#
# The scheduled scan is run by the LaunchAgent com.user.clamav-daily (12:30),
# which executes ~/.local/bin/clamav_daily_scan.sh and writes its report to
# ~/Library/Logs/system_diagnostics/clamav_YYYY-MM-DD.log
#
# Signature updates use ~/.config/clamav/freshclam.conf rather than the
# Homebrew config, which is reset (and re-broken) by every clamav upgrade.

LOG_DIR="$HOME/Library/Logs/system_diagnostics"
FRESHCLAM_CONF="$HOME/.config/clamav/freshclam.conf"
SCAN_SCRIPT="$HOME/.local/bin/clamav_daily_scan.sh"
AGENT="com.user.clamav-daily"

case "$1" in
    scan-now)
        echo "🔍 Starting quick scan of critical directories..."
        clamscan --recursive --infected \
            --exclude-dir=Library/Caches \
            --exclude-dir=.Trash \
            --max-filesize=100M \
            ~/Downloads ~/Documents ~/Desktop
        ;;

    scan-full)
        # Delegates to the scheduled script so manual and automatic scans use
        # identical targets, excludes and logging. Overwrites today's report.
        echo "🔍 Running the full daily scan now (this may take a while)..."
        "$SCAN_SCRIPT"
        ;;

    update)
        echo "📥 Updating virus definitions..."
        freshclam --config-file="$FRESHCLAM_CONF"
        ;;

    logs)
        echo "📋 Most recent ClamAV scan report:"
        latest=$(ls -t "$LOG_DIR"/clamav_*.log 2>/dev/null | head -1)
        if [ -n "$latest" ]; then
            echo "($latest)\n"
            cat "$latest"
        else
            echo "No scan reports yet - the agent runs daily at 12:30"
        fi
        ;;

    status)
        echo "🛡️  ClamAV Status:"
        echo "\nScheduled agent:"
        launchctl list | grep "$AGENT" || echo "  $AGENT NOT LOADED"
        echo "\nVirus definitions:"
        clamscan --version
        echo "\nScan reports:"
        ls -lh "$LOG_DIR"/clamav_*.log 2>/dev/null || echo "  none yet"
        ;;

    *)
        echo "ClamAV Manager"
        echo "Usage: $0 {scan-now|scan-full|update|logs|status}"
        echo ""
        echo "Commands:"
        echo "  scan-now   - Quick scan of Downloads, Documents, Desktop"
        echo "  scan-full  - Run the full daily scan immediately"
        echo "  update     - Update virus definitions manually"
        echo "  logs       - Show the most recent scan report"
        echo "  status     - Check agent, definitions and report history"
        echo ""
        echo "Scheduled scan: $AGENT (daily 12:30)"
        ;;
esac
