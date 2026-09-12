# Warp Repository

**Version Control System:** Git  
**Repository Location:** `~/Warp/`  
**Status:** ✅ Active & Maintained  
**Last Updated:** September 12, 2026

---

## Quick Overview

This repository contains Warp-created automation scripts, system configuration backups, and comprehensive documentation. All daily security and monitoring tasks are version-controlled and centrally managed in this single location.

**Key Stats:**
- 9 automation scripts (consolidated from scattered locations)
- 3 active daily automation tasks
- 6 LaunchAgent configurations (backed up)
- Complete system configuration snapshot
- Comprehensive documentation suite

---

## 📁 Repository Structure

```
~/Warp/
├── scripts/              # 9 executable automation scripts
├── launchagents/         # 6 LaunchAgent plist backup files
├── docs/                 # Documentation, backups, and archives
├── .git/                 # Git repository (version control)
└── README.md             # This file
```

### Understanding Each Directory

#### `scripts/` Directory
Contains all executable shell scripts that power your system automation. Each script is independently runnable and used by LaunchAgents for scheduled execution.

**File Permissions:** All files have `755` permissions (executable by owner)

#### `launchagents/` Directory
Contains backup copies of your LaunchAgent plist configuration files. These define how and when your automation scripts run.

**File Permissions:** All files have `644` permissions (readable)

**Note:** Active LaunchAgents are loaded from `~/Library/LaunchAgents/`. These copies are backups for version control and reference.

#### `docs/` Directory
Contains documentation, system configuration backups, and archived old script folders.

**Subdirectories:**
- `system_backups/` - Timestamped snapshots of system configuration
- `.tar.gz` archives - Compressed backups of old script folders

---

## 🚀 Automation Scripts Guide

### Automated Scripts (Daily Tasks)

These scripts run automatically via LaunchAgents. You don't need to manually trigger them—they execute on schedule.

#### 1. **battery_monitor.sh**
- **Purpose:** Continuous battery health monitoring
- **Schedule:** Continuous (KeepAlive enabled)
- **LaunchAgent:** `com.user.batterymonitor.plist`
- **Logs:** `/tmp/battery_monitor.log`, `/tmp/battery_monitor.error.log`
- **What it does:**
  - Monitors battery health metrics
  - Logs health information continuously
  - Alerts if abnormal conditions detected
- **Manual Run:** `~/Warp/scripts/battery_monitor.sh`

#### 2. **system_check_backup.sh**
- **Purpose:** Daily system security audit
- **Schedule:** 9:00 AM daily
- **LaunchAgent:** `com.user.systemcheck.plist`
- **Logs:** `/tmp/systemcheck.log`, `/tmp/systemcheck.error.log`
- **What it does:**
  - Checks sudo/admin access
  - Verifies YubiKey configuration
  - Inspects LuLu firewall rules
  - Monitors OverSight and KnockKnock
  - Validates ClamAV freshness
  - Checks Time Machine status
- **Manual Run:** `~/Warp/scripts/system_check_backup.sh`

#### 3. **clamav_daily_scan.sh**
- **Purpose:** Daily antivirus scan
- **Schedule:** 12:30 PM daily
- **LaunchAgent:** `com.user.clamav-daily.plist`
- **Logs:** `/tmp/com.user.clamav-daily.out.log`, `/tmp/com.user.clamav-daily.err.log`
- **What it does:**
  - Updates ClamAV virus definitions
  - Scans system for malware
  - Logs all findings
  - Runs at low priority to avoid system impact
- **Manual Run:** `~/Warp/scripts/clamav_daily_scan.sh`

### Manual Scripts (Run as Needed)

These scripts are available for manual execution when you need specific actions.

#### 4. **bitwarden_backup.sh**
- **Purpose:** Encrypted Bitwarden vault backup
- **Frequency:** Manual (run as needed)
- **Output:** Encrypted backup to SD card (`/Volumes/SD/BitwardenBackups/`)
- **What it does:**
  - Exports vault from Bitwarden CLI
  - Encrypts export with GPG
  - Stores encrypted copy on SD card
  - Creates timestamped backups
- **Usage:** `~/Warp/scripts/bitwarden_backup.sh`
- **Restore:** `gpg --decrypt /Volumes/SD/BitwardenBackups/bw_backup_YYYY-MM-DD_HH-MM.json.gpg > restored.json`

#### 5. **bitwarden-audit.sh**
- **Purpose:** Security audit of Bitwarden vault
- **Frequency:** Manual (run as needed)
- **What it does:**
  - Checks for weak passwords
  - Identifies reused passwords
  - Detects missing 2FA
  - Generates security report
- **Usage:** `~/Warp/scripts/bitwarden-audit.sh`

#### 6. **clamav-manager.sh**
- **Purpose:** ClamAV antivirus management
- **Frequency:** Manual (run as needed)
- **What it does:**
  - Manages ClamAV daemon
  - Runs manual scans
  - Updates virus definitions
  - Views scan logs
- **Usage:**
  ```bash
  ~/Warp/scripts/clamav-manager.sh status      # Check status
  ~/Warp/scripts/clamav-manager.sh scan-now    # Run scan
  ~/Warp/scripts/clamav-manager.sh logs        # View logs
  ```

#### 7. **breach-monitor.sh**
- **Purpose:** Check if email appears in data breaches
- **Frequency:** Manual (run as needed)
- **Source:** Have I Been Pwned (HIBP) API
- **What it does:**
  - Queries breach database for email
  - Reports any found breaches
  - Shows breach details
- **Usage:**
  ```bash
  ~/Warp/scripts/breach-monitor.sh              # Uses default email
  ~/Warp/scripts/breach-monitor.sh user@email.com
  ```

#### 8. **tm_retention.sh**
- **Purpose:** Time Machine backup retention management
- **Frequency:** Manual (or scheduled via LaunchDaemon)
- **What it does:**
  - Keeps N most recent Time Machine backups
  - Deletes older backups to save space
  - Default: keeps 30 backups (1TB limit)
  - Can dry-run to preview before deleting
- **Usage:**
  ```bash
  ~/Warp/scripts/tm_retention.sh --help         # Show options
  sudo ~/Warp/scripts/tm_retention.sh           # Dry run
  sudo ~/Warp/scripts/tm_retention.sh --delete  # Actually delete
  sudo ~/Warp/scripts/tm_retention.sh --keep 40 # Keep 40 backups
  ```

#### 9. **quick_security_audit.sh**
- **Purpose:** Focused companion security check
- **Frequency:** Manual (run as needed)
- **What it does:**
  - Focused subset of system_check_backup.sh
  - Checks sudo/YubiKey/LuLu/OverSight/KnockKnock
  - Validates ClamAV and Time Machine
  - Quicker than full system check
- **Usage:** `~/Warp/scripts/quick_security_audit.sh`

---

## 📋 LaunchAgent Configuration

### Active LaunchAgents

Three scripts run automatically via LaunchAgents:

| Script | Agent | Schedule | AutoStart |
|--------|-------|----------|-----------|
| battery_monitor.sh | com.user.batterymonitor | Continuous | Yes (KeepAlive) |
| system_check_backup.sh | com.user.systemcheck | 9:00 AM daily | Yes |
| clamav_daily_scan.sh | com.user.clamav-daily | 12:30 PM daily | No (wait for schedule) |

### Managing LaunchAgents

Check status:
```bash
launchctl list | grep com.user
```

Unload a LaunchAgent:
```bash
launchctl unload ~/Library/LaunchAgents/com.user.batterymonitor.plist
```

Reload a LaunchAgent:
```bash
launchctl load ~/Library/LaunchAgents/com.user.batterymonitor.plist
```

View LaunchAgent output:
```bash
tail -f /tmp/systemcheck.log
tail -f /tmp/battery_monitor.log
```

---

## 🔧 Repository Maintenance

### Adding New Scripts

1. **Create the script**
   ```bash
   nano ~/Warp/scripts/myscript.sh
   ```

2. **Make it executable**
   ```bash
   chmod +x ~/Warp/scripts/myscript.sh
   ```

3. **Test it manually**
   ```bash
   ~/Warp/scripts/myscript.sh
   ```

4. **Stage and commit to git**
   ```bash
   cd ~/Warp
   git add scripts/myscript.sh
   git commit -m "Add myscript.sh for [purpose]

   - Brief description of what it does
   - Any requirements or dependencies
   
   Co-Authored-By: Warp <agent@warp.dev>"
   ```

5. **If automating with LaunchAgent**
   - Create `.plist` file in `~/Warp/launchagents/`
   - Copy to `~/Library/LaunchAgents/`
   - Load with `launchctl load`

### Updating Existing Scripts

1. **Edit the script**
   ```bash
   nano ~/Warp/scripts/existing_script.sh
   ```

2. **Test the changes**
   ```bash
   ~/Warp/scripts/existing_script.sh
   ```

3. **Commit changes**
   ```bash
   cd ~/Warp
   git add scripts/existing_script.sh
   git commit -m "Update existing_script.sh: [describe changes]

   - What changed
   - Why it changed
   
   Co-Authored-By: Warp <agent@warp.dev>"
   ```

4. **If automated, reload LaunchAgent**
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.user.scriptname.plist
   launchctl load ~/Library/LaunchAgents/com.user.scriptname.plist
   ```

### Creating System Backups

Create a new system configuration snapshot:
```bash
mkdir -p ~/Warp/docs/system_backups/$(date +%Y-%m-%d_%H-%M-%S)
cp -r ~/Library/LaunchAgents/*.plist ~/Warp/docs/system_backups/$(date +%Y-%m-%d_%H-%M-%S)/
```

Then commit to git:
```bash
cd ~/Warp
git add docs/system_backups/
git commit -m "Add system backup snapshot: [date]

Includes current LaunchAgent configurations and system state."
```

### Git Workflow

#### View repository status
```bash
git status
```

#### See what changed
```bash
git diff
```

#### View commit history
```bash
git log --oneline
```

#### View a specific commit
```bash
git show 6e75966
```

#### Stage changes
```bash
git add <file>
```

#### Commit changes
```bash
git commit -m "Meaningful commit message"
```

#### Undo uncommitted changes
```bash
git checkout <file>
```

#### View file in specific commit
```bash
git show 6e75966:scripts/battery_monitor.sh
```

---

## 📚 Documentation Guide

### Primary Documentation Files

**In `~/Warp/docs/`:**

1. **INDEX.md** - Master navigation guide (start here)
2. **QUICK_START.md** - Quick commands and daily schedule
3. **README.md** - General folder overview
4. **CLEANUP_PROCESS_LOG.md** - Detailed documentation of cleanup process
5. **Mac_Command_Reference.html** - Comprehensive system command reference
6. **GIT_COMMIT_SUMMARY.md** - Git repository details and verification

### Reading Documentation

```bash
# View quick start guide
open ~/Warp/docs/QUICK_START.md

# View master index
open ~/Warp/docs/INDEX.md

# View complete command reference
open ~/Warp/docs/Mac_Command_Reference.html

# View git commit details
cat ~/Warp/docs/GIT_COMMIT_SUMMARY.md
```

---

## 🔍 Troubleshooting

### Script Not Running

1. **Check if LaunchAgent is loaded**
   ```bash
   launchctl list | grep com.user.scriptname
   ```

2. **Check script permissions**
   ```bash
   ls -lh ~/Warp/scripts/scriptname.sh
   # Should show -rwxr-xr-x (755)
   ```

3. **View script errors**
   ```bash
   tail -20 /tmp/scriptname.error.log
   ```

4. **Run script manually to test**
   ```bash
   ~/Warp/scripts/scriptname.sh
   ```

### LaunchAgent Issues

**If LaunchAgent won't load:**
```bash
# Check plist syntax
plutil -lint ~/Library/LaunchAgents/com.user.scriptname.plist

# View detailed error
launchctl load -w ~/Library/LaunchAgents/com.user.scriptname.plist 2>&1
```

**If script path is wrong:**
```bash
# Edit the plist
nano ~/Library/LaunchAgents/com.user.scriptname.plist

# Verify it points to ~/Warp/scripts/
# Then reload
launchctl unload ~/Library/LaunchAgents/com.user.scriptname.plist
launchctl load ~/Library/LaunchAgents/com.user.scriptname.plist
```

### Git Issues

**If you accidentally modified a file:**
```bash
git checkout scripts/scriptname.sh  # Restore original
```

**If you committed by mistake:**
```bash
git revert HEAD                     # Undo last commit (creates new commit)
```

**If you want to see what's in a commit:**
```bash
git show <commit-hash>
```

---

## ✅ Daily Maintenance Checklist

**Weekly:**
- [ ] Review `/tmp/systemcheck.log` for security issues
- [ ] Check `/tmp/battery_monitor.log` for battery health
- [ ] Monitor `/tmp/com.user.clamav-daily.*` for malware alerts

**Monthly:**
- [ ] Run `~/Warp/scripts/bitwarden-audit.sh` to check vault security
- [ ] Run `~/Warp/scripts/breach-monitor.sh` to check for breaches
- [ ] Review Time Machine backup status with `tmutil status`

**Quarterly:**
- [ ] Create new system configuration backup
- [ ] Update `~/Warp/docs/CLEANUP_PROCESS_LOG.md` if changes made
- [ ] Review all scripts for updates or improvements

**As Needed:**
- [ ] Run `~/Warp/scripts/bitwarden_backup.sh` before traveling
- [ ] Execute `~/Warp/scripts/tm_retention.sh --delete` if storage low
- [ ] Use `~/Warp/scripts/clamav-manager.sh scan-now` for manual scans

---

## 🔒 Security Notes

- **YubiKey:** Required for sudo authentication (configured)
- **SSH Keys:** Backed up in system_backups snapshot
- **Bitwarden:** Encrypted backups on SD card only (not in git)
- **GPG:** Used for encrypting sensitive backups
- **LuLu Firewall:** Actively blocking unauthorized connections
- **ClamAV:** Daily scans for malware detection

All automation scripts respect security configuration and use stored credentials when needed.

---

## 📞 Quick Reference

### File Locations
- **Scripts:** `~/Warp/scripts/`
- **Configuration Backups:** `~/Warp/launchagents/`
- **Documentation:** `~/Warp/docs/`
- **System Backups:** `~/Warp/docs/system_backups/`
- **Git Repository:** `~/Warp/.git/`
- **Active LaunchAgents:** `~/Library/LaunchAgents/com.user.*`
- **System Logs:** `/tmp/`

### Common Commands
```bash
# List all scripts
ls -1 ~/Warp/scripts/

# Check automation status
launchctl list | grep com.user

# View recent logs
tail -20 /tmp/systemcheck.log
tail -20 /tmp/battery_monitor.log

# Run quick security check
~/Warp/scripts/quick_security_audit.sh

# Commit changes
cd ~/Warp && git add . && git commit -m "message"

# View git history
git log --oneline -10
```

### Git Commit Template
```bash
git commit -m "Short description of change

- Detailed explanation of what changed
- Why it was changed
- Any dependencies or requirements

Co-Authored-By: Warp <agent@warp.dev>"
```

---

## 📈 System Status

**Repository:** ✅ Active & Version Controlled  
**Automation:** ✅ All 3 daily tasks running  
**Documentation:** ✅ Complete & comprehensive  
**Backups:** ✅ Regular system snapshots  
**Security:** ✅ Verified & configured  

**Next Review:** When adding new scripts or updating documentation

---

**Repository Initialized:** September 12, 2026  
**Commit Hash:** `6e759665fe9d43cac703a5d30f93f5cc6ea6c3ea`  
**Branch:** `main`  
**Status:** ✨ Ready for ongoing development
