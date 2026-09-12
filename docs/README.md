# Warp Scripts Documentation

## Overview
This folder contains all Warp-created automation scripts and documentation.

## Folder Structure
- `scripts/` - All executable shell scripts for daily automation
- `launchagents/` - LaunchAgent plist files (backup copies, originals in ~/Library/LaunchAgents/)
- `docs/` - Documentation and reference guides

## Active Scripts

### Daily Automated Scripts (LaunchAgents)
1. **battery_monitor.sh** - Continuous battery health monitoring (KeepAlive, runs on load)
2. **system_check_backup.sh** - Daily system security audit (9:00 AM)
3. **clamav_daily_scan.sh** - ClamAV antivirus scan (12:30 PM)

### Manual/Utility Scripts
- **bitwarden_backup.sh** - Encrypted vault backup to SD card
- **bitwarden-audit.sh** - Security audit (weak passwords, reused passwords, missing 2FA)
- **clamav-manager.sh** - ClamAV scan manager and controls
- **breach-monitor.sh** - Checks if email appears in known data breaches (Have I Been Pwned)
- **tm_retention.sh** - Time Machine backup retention manager (keeps N most recent backups)
- **quick_security_audit.sh** - Focused companion security check (sudo/YubiKey/LuLu/OverSight/KnockKnock)

## LaunchAgent Status

Check which agents are loaded:
```bash
launchctl list | grep com.user
```

All active agents point to `~/Warp/scripts/` for script execution.

## Documentation
See `Mac_Command_Reference.html` for comprehensive command reference.

## Update Paths
All scripts have been consolidated. If you need to run a script manually:
```bash
~/Warp/scripts/script_name.sh
```

No need to maintain multiple copies anymore!
