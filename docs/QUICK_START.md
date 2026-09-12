# Warp Folder Quick Start Guide

## 📁 Folder Structure
```
~/Warp/ (Purple folder)
├── scripts/              # 9 executable automation scripts
├── launchagents/         # Backup copies of LaunchAgent plist files
└── docs/                 # Documentation & system backups
    ├── Mac_Command_Reference.html
    ├── README.md
    ├── CLEANUP_PROCESS_LOG.md (this session's detailed log)
    ├── QUICK_START.md (you are here)
    ├── system_backups/   # Timestamped system configuration backups
    └── *.tar.gz          # Archived old script folders
```

---

## ⚡ Quick Commands

### View All Scripts
```bash
ls -1 ~/Warp/scripts/
```

### Run a Script Manually
```bash
~/Warp/scripts/battery_monitor.sh
~/Warp/scripts/system_check_backup.sh
~/Warp/scripts/clamav-manager.sh status
```

### Check Automation Status
```bash
launchctl list | grep com.user
```

### View Logs
```bash
# Battery monitor
tail -f /tmp/battery_monitor.log

# System check
tail -f /tmp/systemcheck.log

# ClamAV scan
tail -f /tmp/com.user.clamav-daily.out.log
```

---

## 📅 Daily Automation Schedule

| Time | Task | Script | Status |
|------|------|--------|--------|
| **Continuous** | Battery Monitoring | `battery_monitor.sh` | ✓ Running |
| **9:00 AM** | System Security Audit | `system_check_backup.sh` | ✓ Scheduled |
| **12:30 PM** | ClamAV Scan | `clamav_daily_scan.sh` | ✓ Scheduled |

---

## 🔧 Manual Scripts

### Bitwarden
```bash
~/Warp/scripts/bitwarden_backup.sh           # Encrypted backup
~/Warp/scripts/bitwarden-audit.sh            # Security audit
```

### ClamAV
```bash
~/Warp/scripts/clamav-manager.sh status      # Check status
~/Warp/scripts/clamav-manager.sh scan-now    # Run scan
~/Warp/scripts/clamav-manager.sh logs        # View logs
```

### Security
```bash
~/Warp/scripts/breach-monitor.sh             # Check breaches
~/Warp/scripts/quick_security_audit.sh       # Full audit
~/Warp/scripts/tm_retention.sh --help        # Time Machine manager
```

---

## 🔐 System Security Status

✅ **Little Snitch Mini** - Running (network monitoring)  
✅ **ClamAV** - Running (antivirus)  
✅ **Bitwarden** - Configured (password manager)  
✅ **YubiKey** - Configured (2FA/PIV)  
✅ **LuLu Firewall** - Running  

---

## 💾 System Backup Info

**Latest Backup:** `~/Warp/docs/system_backups/2026-09-12_18-40-58/`

Contains:
- LaunchAgent configurations (6 files)
- System preferences (454 files)
- SSH public key
- System information snapshot
- Installed applications inventory
- Homebrew packages list

### Create New Backup
```bash
# Manual backup creation:
mkdir -p ~/Warp/docs/system_backups/$(date +%Y-%m-%d_%H-%M-%S)
cp -r ~/Library/LaunchAgents/*.plist ~/Warp/docs/system_backups/$(date +%Y-%m-%d_%H-%M-%S)/
```

---

## 📝 Documentation Files

| File | Purpose |
|------|---------|
| `Mac_Command_Reference.html` | Complete command reference |
| `README.md` | Folder overview & script descriptions |
| `CLEANUP_PROCESS_LOG.md` | Detailed cleanup documentation |
| `QUICK_START.md` | This file - quick commands |

---

## ✨ Recent Cleanup Summary

**Completed Actions:**
- ✓ Consolidated 9 scripts into `~/Warp/scripts/`
- ✓ Updated all 3 daily LaunchAgents to use new paths
- ✓ Removed duplicates from ~/ and ~/.local/bin/
- ✓ Archived old "Scripts From warp" folder
- ✓ Verified Little Snitch Mini only (full version removed)
- ✓ Created comprehensive system backup

**System Status:** CLEAN ✨

---

## 🚀 Adding New Scripts

1. Create script in `~/Warp/scripts/`
2. Make executable: `chmod +x ~/Warp/scripts/myscript.sh`
3. Test manually: `~/Warp/scripts/myscript.sh`
4. If daily automation needed:
   - Create `.plist` in `~/Warp/launchagents/`
   - Copy to `~/Library/LaunchAgents/`
   - Load: `launchctl load ~/Library/LaunchAgents/com.user.myscript.plist`
5. Update documentation

---

## 🔍 Troubleshooting

### Script Not Running
```bash
# Check if LaunchAgent is loaded
launchctl list | grep com.user.scriptname

# Check for errors
launchctl log show --level debug --predicate 'process == "com.user.scriptname"'

# View logs
tail -f /tmp/scriptname.log
tail -f /tmp/scriptname.error.log
```

### Unload/Reload LaunchAgent
```bash
# Unload
launchctl unload ~/Library/LaunchAgents/com.user.scriptname.plist

# Reload
launchctl load ~/Library/LaunchAgents/com.user.scriptname.plist
```

### Check File Permissions
```bash
# Scripts should be executable (755)
ls -lh ~/Warp/scripts/

# LaunchAgents should be readable (644)
ls -lh ~/Library/LaunchAgents/com.user.*
```

---

## 📞 Quick References

**~/ Warp** = `/Users/jarrodstebbing/Warp`

**All Scripts** = `~/Warp/scripts/`

**System Logs** = `/tmp/`

**LaunchAgents** = `~/Library/LaunchAgents/`

**Preferences** = `~/Library/Preferences/`

---

**Last Updated:** September 12, 2026  
**System Status:** ✅ Clean & Consolidated
