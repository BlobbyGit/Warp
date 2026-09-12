# Warp Repository - Quick Start Guide

**Last Updated:** September 12, 2026  
**Quick Links:** [Full README](README.md) | [Documentation Index](docs/INDEX.md) | [GitHub Repo](https://github.com/BlobbyGit/Warp)

---

## ⚡ 30-Second Overview

- **9 automation scripts** stored in `~/Warp/scripts/`
- **3 daily tasks** run automatically via LaunchAgents
- **Everything is version-controlled** with Git
- **All documentation** is in `~/Warp/docs/`

---

## 📅 Daily Automation Schedule

| Time | Task | Script |
|------|------|--------|
| **Continuous** | Battery health monitoring | `battery_monitor.sh` |
| **9:00 AM** | Daily security audit | `system_check_backup.sh` |
| **12:30 PM** | Antivirus scan | `clamav_daily_scan.sh` |

All tasks run automatically. No action needed.

---

## 🚀 Common Tasks

### Check if automation is running
```bash
launchctl list | grep com.user
```

### View today's logs
```bash
tail -20 /tmp/systemcheck.log        # Today's security audit
tail -20 /tmp/battery_monitor.log    # Battery health
tail -20 /tmp/com.user.clamav-daily.out.log  # Antivirus
```

### Run manual security check
```bash
~/Warp/scripts/quick_security_audit.sh
```

### Back up Bitwarden (before traveling)
```bash
~/Warp/scripts/bitwarden_backup.sh
```

### Check for data breaches
```bash
~/Warp/scripts/breach-monitor.sh
```

### Audit Bitwarden vault security
```bash
~/Warp/scripts/bitwarden-audit.sh
```

### Manage ClamAV antivirus
```bash
~/Warp/scripts/clamav-manager.sh status    # Check status
~/Warp/scripts/clamav-manager.sh scan-now  # Run manual scan
~/Warp/scripts/clamav-manager.sh logs      # View logs
```

### Check Time Machine backups
```bash
tmutil status
sudo ~/Warp/scripts/tm_retention.sh        # Preview old backups
sudo ~/Warp/scripts/tm_retention.sh --delete  # Delete old backups
```

---

## 🛠️ Repository Workflow

### Add a new script
```bash
# 1. Create script
nano ~/Warp/scripts/myscript.sh

# 2. Make executable
chmod +x ~/Warp/scripts/myscript.sh

# 3. Test it
~/Warp/scripts/myscript.sh

# 4. Commit to git
cd ~/Warp
git add scripts/myscript.sh
git commit -m "Add myscript.sh: description of what it does

- What it does
- Why it was added

Co-Authored-By: Warp <agent@warp.dev>"

# 5. Push to GitHub
git push
```

### Update an existing script
```bash
# 1. Edit script
nano ~/Warp/scripts/existing.sh

# 2. Test changes
~/Warp/scripts/existing.sh

# 3. Commit changes
cd ~/Warp
git add scripts/existing.sh
git commit -m "Update existing.sh: description of changes

- What changed
- Why it changed

Co-Authored-By: Warp <agent@warp.dev>"

# 4. Push to GitHub
git push
```

### View git history
```bash
git log --oneline           # Last 10 commits
git log --oneline -5        # Last 5 commits
git show 6e75966            # View specific commit
```

### Undo changes (before committing)
```bash
git checkout scripts/myfile.sh  # Restore original file
git status                      # Check what changed
git diff                        # See exact changes
```

---

## 📂 File Locations

| What | Location |
|------|----------|
| Scripts | `~/Warp/scripts/` |
| LaunchAgent backups | `~/Warp/launchagents/` |
| Documentation | `~/Warp/docs/` |
| System backups | `~/Warp/docs/system_backups/` |
| Git repository | `~/Warp/.git/` |
| Active LaunchAgents | `~/Library/LaunchAgents/com.user.*` |
| System logs | `/tmp/` |

---

## 🆘 Troubleshooting

### Script not running automatically?
```bash
# 1. Check if LaunchAgent is loaded
launchctl list | grep com.user

# 2. Check script permissions (should be 755)
ls -lh ~/Warp/scripts/myScript.sh

# 3. Check error logs
tail -20 /tmp/myScript.error.log

# 4. Run script manually to test
~/Warp/scripts/myScript.sh

# 5. If plist is wrong, reload it
launchctl unload ~/Library/LaunchAgents/com.user.myScript.plist
launchctl load ~/Library/LaunchAgents/com.user.myScript.plist
```

### LaunchAgent won't load?
```bash
# Check plist syntax
plutil -lint ~/Library/LaunchAgents/com.user.myScript.plist

# Try loading with verbose output
launchctl load -w ~/Library/LaunchAgents/com.user.myScript.plist 2>&1
```

### Git confusion?
```bash
# See current status
git status

# See what changed in a file
git diff scripts/myfile.sh

# Restore a file to last commit
git checkout scripts/myfile.sh

# View a file from a past commit
git show 6e75966:scripts/myfile.sh
```

---

## 📋 All 9 Scripts at a Glance

| Script | Type | Purpose |
|--------|------|---------|
| `battery_monitor.sh` | Automated | Continuous battery health monitoring |
| `system_check_backup.sh` | Automated | 9 AM daily security audit |
| `clamav_daily_scan.sh` | Automated | 12:30 PM daily antivirus scan |
| `bitwarden_backup.sh` | Manual | Encrypted vault backup to SD card |
| `bitwarden-audit.sh` | Manual | Check vault for weak/reused passwords |
| `clamav-manager.sh` | Manual | Manage antivirus daemon and scans |
| `breach-monitor.sh` | Manual | Check if email in data breaches |
| `tm_retention.sh` | Manual | Manage Time Machine backup retention |
| `quick_security_audit.sh` | Manual | Focused security check |

---

## ✅ Daily Checklist

### Weekly
- [ ] Check `/tmp/systemcheck.log` for security warnings
- [ ] Review `/tmp/battery_monitor.log` for battery health
- [ ] Look for malware alerts in `/tmp/com.user.clamav-daily.*`

### Monthly
- [ ] Run `~/Warp/scripts/bitwarden-audit.sh`
- [ ] Run `~/Warp/scripts/breach-monitor.sh`
- [ ] Check Time Machine: `tmutil status`

### Quarterly
- [ ] Create new system backup
- [ ] Review all scripts for updates
- [ ] Update documentation if needed

### Before Traveling
- [ ] Run `~/Warp/scripts/bitwarden_backup.sh`

---

## 🔗 More Information

- **Full README:** `~/Warp/README.md`
- **Documentation Index:** `~/Warp/docs/INDEX.md`
- **Command Reference:** `~/Warp/docs/Mac_Command_Reference.html`
- **Git Details:** `~/Warp/docs/GIT_COMMIT_SUMMARY.md`
- **Cleanup Log:** `~/Warp/docs/CLEANUP_PROCESS_LOG.md`

---

## 📞 Quick Commands

```bash
# List all scripts
ls -1 ~/Warp/scripts/

# Show automation status
launchctl list | grep com.user

# View git log
git log --oneline -10

# Check repo status
git status

# Push changes to GitHub
git push

# Pull latest from GitHub
git pull
```

---

**Repository:** https://github.com/BlobbyGit/Warp  
**Local Path:** `~/Warp/`  
**Status:** ✅ Active & Maintained
