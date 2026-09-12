# Warp Folder - Master Index

**Created:** September 12, 2026  
**System:** macOS - jarrodstebbing  
**Status:** ✅ Clean & Consolidated

---

## 📂 Quick Navigation

### Start Here
1. **[QUICK_START.md](QUICK_START.md)** - Quick commands and daily automation schedule
2. **[README.md](README.md)** - Folder overview and script descriptions
3. **[CLEANUP_PROCESS_LOG.md](CLEANUP_PROCESS_LOG.md)** - Detailed cleanup documentation

### Complete Reference
- **[Mac_Command_Reference.html](Mac_Command_Reference.html)** - Comprehensive command reference

---

## 📁 Folder Structure

```
~/Warp/
├── scripts/                          # 9 consolidated automation scripts
│   ├── battery_monitor.sh
│   ├── system_check_backup.sh
│   ├── clamav_daily_scan.sh
│   ├── bitwarden_backup.sh
│   ├── bitwarden-audit.sh
│   ├── clamav-manager.sh
│   ├── breach-monitor.sh
│   ├── tm_retention.sh
│   └── quick_security_audit.sh
│
├── launchagents/                     # Backup copies of plist files
│   ├── com.user.batterymonitor.plist
│   ├── com.user.clamav-daily.plist
│   ├── com.user.lulu-postboot-check.plist
│   ├── com.user.lulu.plist
│   ├── com.user.oversight.plist
│   └── com.user.systemcheck.plist
│
└── docs/                             # Documentation & backups
    ├── INDEX.md (this file)
    ├── README.md
    ├── QUICK_START.md
    ├── CLEANUP_PROCESS_LOG.md
    ├── Mac_Command_Reference.html
    ├── system_backups/               # Timestamped backups
    │   └── 2026-09-12_18-40-58/
    │       ├── LaunchAgents/
    │       ├── Preferences/
    │       ├── SSH/
    │       ├── system_info.txt
    │       ├── installed_applications.txt
    │       ├── brew_packages.txt
    │       └── brew_taps.txt
    ├── Scripts_From_warp_backup.tar.gz
    ├── SystemBackup_archive.tar.gz
    └── iCloud_Scripts_archive.tar.gz
```

---

## 🚀 Getting Started

### First Time?
Read in this order:
1. [QUICK_START.md](QUICK_START.md) - Get oriented (5 min)
2. [README.md](README.md) - Understand the structure (5 min)
3. Run a script to test: `~/Warp/scripts/clamav-manager.sh status`

### Running Scripts
```bash
# Daily automation (automatic)
launchctl list | grep com.user

# Manual scripts
~/Warp/scripts/script_name.sh
```

### View Documentation
```bash
# Quick reference
open ~/Warp/docs/QUICK_START.md

# Full HTML reference
open ~/Warp/docs/Mac_Command_Reference.html

# Cleanup details
open ~/Warp/docs/CLEANUP_PROCESS_LOG.md
```

---

## 📋 What Was Done

### Phase 1: Script Consolidation
- ✓ Created ~/Warp folder with purple color
- ✓ Consolidated 9 scripts from scattered locations
- ✓ Updated 3 daily LaunchAgents to use new paths
- ✓ Removed all duplicates
- ✓ Archived old folders

### Phase 2: Little Snitch Verification
- ✓ Verified full Little Snitch is NOT installed
- ✓ Confirmed Little Snitch Mini is RUNNING
- ✓ Confirmed no residual files from full version

### Phase 3: Backup & Documentation
- ✓ Created comprehensive system configuration backup
- ✓ Documented entire cleanup process
- ✓ Created quick reference guides
- ✓ Organized all documentation

---

## 🔍 Key Files Explained

### Documentation
| File | Purpose | When to Use |
|------|---------|-------------|
| QUICK_START.md | Commands & automation schedule | Daily reference |
| README.md | Folder overview | First time setup |
| CLEANUP_PROCESS_LOG.md | Detailed cleanup record | Reference/audit |
| Mac_Command_Reference.html | Complete command reference | Comprehensive lookup |
| INDEX.md (this file) | Navigation & overview | Find things quickly |

### Scripts (~/Warp/scripts/)
| Script | Type | Purpose |
|--------|------|---------|
| battery_monitor.sh | Automated | Continuous battery monitoring |
| system_check_backup.sh | Automated | Daily security audit (9 AM) |
| clamav_daily_scan.sh | Automated | Daily antivirus scan (12:30 PM) |
| bitwarden_backup.sh | Manual | Encrypted vault backup |
| bitwarden-audit.sh | Manual | Security audit |
| clamav-manager.sh | Manual | ClamAV controls |
| breach-monitor.sh | Manual | Data breach checker |
| tm_retention.sh | Manual | Time Machine manager |
| quick_security_audit.sh | Manual | Focused security check |

### Backups (~/Warp/docs/)
| Item | Contents | Use Case |
|------|----------|----------|
| system_backups/2026-09-12_18-40-58/ | Full config snapshot | System restore/reference |
| Scripts_From_warp_backup.tar.gz | Old scripts folder | Archive/reference |
| SystemBackup_archive.tar.gz | Old backup folder | Archive/reference |
| iCloud_Scripts_archive.tar.gz | Old iCloud scripts | Archive/reference |

---

## ⚡ Common Tasks

### Check What's Running
```bash
launchctl list | grep com.user
```

### Run a Manual Scan
```bash
~/Warp/scripts/clamav-manager.sh status
~/Warp/scripts/breach-monitor.sh
~/Warp/scripts/quick_security_audit.sh
```

### View Recent Logs
```bash
tail -20 /tmp/battery_monitor.log
tail -20 /tmp/systemcheck.log
```

### Create New Backup
```bash
mkdir -p ~/Warp/docs/system_backups/$(date +%Y-%m-%d_%H-%M-%S)
```

### Add New Script
1. Create in `~/Warp/scripts/`
2. Make executable: `chmod +x ~/Warp/scripts/newscript.sh`
3. Test it
4. If automation needed: create plist in `~/Warp/launchagents/`
5. Copy plist to `~/Library/LaunchAgents/` and load it

---

## 🔐 System Security Status

**Automated Daily Checks:**
- ✅ Battery monitoring (continuous)
- ✅ Security audit (9:00 AM)
- ✅ Antivirus scan (12:30 PM)

**Security Tools Active:**
- ✅ Little Snitch Mini (network monitoring)
- ✅ ClamAV (antivirus)
- ✅ LuLu Firewall (connection blocking)
- ✅ Bitwarden (password manager)
- ✅ YubiKey (2FA/PIV)

---

## 📞 Quick Reference

**Warp Location:**  
`~/Warp/` → `/Users/jarrodstebbing/Warp`

**All Scripts:**  
`~/Warp/scripts/`

**System Logs:**  
`/tmp/`

**Active LaunchAgents:**  
`~/Library/LaunchAgents/com.user.*`

**System Preferences:**  
`~/Library/Preferences/`

---

## 📝 Documentation Status

| Document | Status | Last Updated |
|----------|--------|--------------|
| INDEX.md | ✅ Complete | 2026-09-12 |
| QUICK_START.md | ✅ Complete | 2026-09-12 |
| README.md | ✅ Complete | 2026-09-12 |
| CLEANUP_PROCESS_LOG.md | ✅ Complete | 2026-09-12 |
| Mac_Command_Reference.html | ✅ Current | 2026-09-12 |

---

## 🎯 Next Steps

1. ✅ **Review** - Read QUICK_START.md
2. ✅ **Test** - Run a script: `~/Warp/scripts/clamav-manager.sh status`
3. ✅ **Monitor** - Check logs: `tail -f /tmp/systemcheck.log`
4. ✅ **Maintain** - Backup periodically: Create new snapshot in system_backups/
5. ✅ **Extend** - Add new scripts as needed

---

**System Status:** ✨ CLEAN & READY  
**Last Reviewed:** September 12, 2026, 18:40 UTC  
**All Systems:** ✅ Operational
