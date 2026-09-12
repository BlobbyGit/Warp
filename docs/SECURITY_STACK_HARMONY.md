# Security Stack Harmony Guide

**Objective:** Configure Little Snitch Mini, AdGuard, LuLu, OverSight, KnockKnock, ClamAV, and Time Machine to work in perfect sync without conflicts.

**Status:** September 12, 2026  
**Your Setup:** Complete security stack with 7 security tools + Time Machine

---

## 📊 Security Stack Overview

| Tool | Purpose | Type | Status |
|------|---------|------|--------|
| **Little Snitch Mini** | Network connection control | Network Monitor | ✅ Installed (v1.9) |
| **AdGuard** | Ad/tracker blocking + malware protection | DNS/Network | ✅ Installed (v2.19) |
| **LuLu** | Outbound firewall (unauthorized access) | Firewall | ✅ Running (PID 845) |
| **OverSight** | Microphone/camera access monitor | Process Monitor | ✅ Running (PID 820) |
| **KnockKnock** | Persistent malware scanner | On-Demand Scanner | ✅ Installed |
| **ClamAV** | Daily antivirus scanning | Scheduled Antivirus | ✅ Running (v1.5.4) |
| **Time Machine** | Backup & recovery | Backup | ✅ Enabled |

**System Extensions Active:**
- ✅ Little Snitch Mini Network Extension (active)
- ✅ AdGuard VPN Network Extension (active)
- ✅ AdGuard Network Extension (active)
- ✅ LuLu System Extension (active)

---

## 🔧 Configuration Strategy

### Principle 1: Layered Defense (No Redundant Scanning)
Each tool operates at a different OSI layer to avoid conflicts:

```
Layer 7 (Application)
├─ AdGuard: DNS filtering (prevents malicious domains)
├─ ClamAV: Antivirus file scanning
└─ KnockKnock: Persistent malware detection

Layer 4-6 (Transport)
├─ Little Snitch Mini: Network connection control
└─ LuLu: Outbound connection blocking

Layer 2-3 (Network/Data Link)
└─ AdGuard VPN: Network-level protection

Layer 1 (Physical)
└─ OverSight: Camera/Microphone access logging
└─ Time Machine: Data recovery
```

### Principle 2: Role Separation
- **AdGuard:** Block known malicious domains (prevention)
- **Little Snitch Mini:** Control what applications can connect to (visibility)
- **LuLu:** Block suspicious outbound connections (outbound firewall)
- **OverSight:** Log camera/mic access attempts (privacy monitor)
- **KnockKnock:** Scan for persistent threats (detection)
- **ClamAV:** Daily full-system virus scanning (cure)
- **Time Machine:** Recover from attacks (recovery)

---

## ⚙️ Step-by-Step Configuration

### STEP 1: AdGuard Configuration

**Objective:** DNS-level blocking without interfering with network tools.

**1A. Network Extension Settings:**
```
AdGuard → Preferences → Network
└─ Network Extension: ENABLED
├─ Filter DNS requests: ENABLED
├─ Block malicious domains: ENABLED
├─ Block tracking domains: ENABLED
└─ Block phishing domains: ENABLED
```

**1B. Exclude Warp Scripts:**
```
AdGuard → Preferences → General
├─ Exclude Applications:
│  └─ ~/Warp/scripts/system_check_backup.sh (add to whitelist if needed)
│  └─ ~/Warp/scripts/clamav_daily_scan.sh
│  └─ ~/Warp/scripts/battery_monitor.sh
└─ This prevents AdGuard blocking your automation tools
```

**1C. VPN Settings (AdGuard VPN):**
```
AdGuard → Preferences → VPN
├─ VPN Mode: ENABLED
├─ Exclude Local Networks: YES
│  └─ This allows LuLu and Little Snitch to monitor local traffic
├─ Allow other VPNs: YES
│  └─ Allows ProtonVPN to coexist
└─ Split Tunneling: Configure to exclude security tools
   └─ Never route through VPN:
      - /Applications/LuLu.app
      - /Applications/Little\ Snitch\ Mini.app
      - /Applications/OverSight.app
```

**1D. Firewall Rules (AdGuard):**
```
AdGuard → Preferences → Firewall (if available)
├─ Don't block traffic from:
│  └─ Little Snitch Mini
│  └─ LuLu
│  └─ System services
└─ Block known malicious IPs: ENABLED
```

---

### STEP 2: Little Snitch Mini Configuration

**Objective:** Monitor and control network connections without blocking AdGuard.

**2A. Basic Setup:**
```
Little Snitch Mini → Preferences → Network Monitor
├─ Monitoring Mode: ACTIVE
├─ Show unknown connections: ENABLED
└─ Alert for suspicious patterns: ENABLED
```

**2B. Trusted Applications (Whitelist):**
```
Little Snitch Mini → Connection Rules
├─ Add to Whitelist (allow without alerts):
│  ├─ AdGuard (all network connections)
│  ├─ System Updates (Apple services)
│  ├─ Time Machine (local network)
│  ├─ Warp Scripts (~/Warp/scripts/*)
│  └─ ProtonVPN (if using)
└─ These apps won't trigger alerts
```

**2C. Suspicious Applications (Monitor):**
```
Little Snitch Mini → Connection Rules
├─ Add to Monitor (log but allow):
│  ├─ Unknown applications
│  ├─ Applications making unexpected connections
│  └─ Applications connecting to suspicious IPs
└─ Review these weekly in logs
```

**2D. Stealthy Mode:**
```
Little Snitch Mini → Preferences → Stealth Mode
├─ Stealth Mode: ENABLED
├─ Prevent DNS leaks: ENABLED
├─ Block ICMP: ENABLED (prevents ping)
└─ Log suspicious packets: ENABLED
```

**2E. Disable Redundant Blocking:**
```
Little Snitch Mini → Preferences → Advanced
├─ Conflict with LuLu:
│  ├─ Little Snitch: OUTBOUND MONITORING (log, don't block)
│  └─ LuLu: OUTBOUND BLOCKING (actually blocks)
├─ Conflict with AdGuard:
│  ├─ Little Snitch: CONNECTION MONITORING
│  └─ AdGuard: DNS FILTERING (no conflict)
└─ Result: No blocked connections, better logging
```

---

### STEP 3: LuLu Firewall Configuration

**Objective:** Block unauthorized outbound connections, don't interfere with AdGuard.

**3A. Core Settings:**
```
LuLu → Preferences → General
├─ Firewall Mode: BLOCK MODE
├─ Default Policy: DENY (deny by default, allow explicitly)
├─ Monitor Mode: ENABLED
└─ Scan System on Launch: ENABLED
```

**3B. Trusted Applications (Whitelist):**
```
LuLu → Rules → Whitelist
├─ System Applications:
│  ├─ launchd (system launcher)
│  ├─ kernel_task
│  ├─ systemd processes
│  └─ Apple services
├─ Network Tools:
│  ├─ AdGuard
│  ├─ Little Snitch Mini
│  ├─ ProtonVPN
│  └─ Safari/Firefox/Chrome
├─ Your Applications:
│  ├─ Mail, Messages, FaceTime
│  ├─ Slack, Discord, Telegram
│  └─ Work applications
└─ Warp Scripts:
   ├─ system_check_backup.sh
   ├─ battery_monitor.sh
   └─ clamav_daily_scan.sh
```

**3C. Suspicious Applications (Block):**
```
LuLu → Rules → Blocklist
├─ Unknown applications trying to:
│  ├─ Connect to non-standard ports
│  ├─ Connect to suspicious IPs
│  └─ Make unexpected connections
└─ These will be blocked automatically
```

**3D. Logging:**
```
LuLu → Preferences → Logging
├─ Log Connections: ALL
├─ Log Blocked Connections: ENABLED
├─ Log Duration: 30 days
└─ Export logs: Weekly backup
```

---

### STEP 4: OverSight Configuration

**Objective:** Monitor camera and microphone access without interfering with other tools.

**4A. Access Monitoring:**
```
OverSight → Preferences → General
├─ Microphone Monitoring: ENABLED
│  ├─ Alert on access: YES
│  ├─ Block access: NO (just log)
│  └─ Log all access: YES
├─ Camera Monitoring: ENABLED
│  ├─ Alert on access: YES
│  ├─ Block access: NO (just log)
│  └─ Log all access: YES
└─ Audio Input Monitoring: ENABLED
```

**4B. Whitelist Trusted Apps:**
```
OverSight → Whitelist
├─ Video Conferencing:
│  ├─ Zoom
│  ├─ Teams
│  ├─ Google Meet
│  └─ Facetime
├─ Development:
│  ├─ OBS Virtual Camera
│  └─ Screen recording tools
└─ System:
   ├─ System audio
   └─ CoreAudio processes
```

**4C. Alerts:**
```
OverSight → Preferences → Alerts
├─ Pop-up alerts: ENABLED
├─ Sound alert: ENABLED
├─ Log to file: ENABLED
└─ Review logs: Daily (check ~/Library/Logs/OverSight/)
```

---

### STEP 5: KnockKnock Configuration

**Objective:** Run scheduled malware scans without interfering with ClamAV.

**5A. Scan Settings:**
```
KnockKnock → Preferences → Scanning
├─ Scan Frequency: WEEKLY (not daily - ClamAV does daily)
├─ Scan Type: FULL SYSTEM
├─ Auto-quarantine: ENABLED
├─ Locations to Scan:
│  ├─ /Applications
│  ├─ /Library/LaunchDaemons
│  ├─ /Library/LaunchAgents
│  ├─ ~/Library/LaunchAgents
│  ├─ /usr/local/bin
│  └─ ~/Warp/ (your scripts)
```

**5B. Exclusions:**
```
KnockKnock → Preferences → Exclusions
├─ Exclude from scanning:
│  ├─ /Library/Caches
│  ├─ /Library/Logs
│  └─ Avoid duplicating ClamAV work
└─ ClamAV already scans everything daily
```

**5C. Results Handling:**
```
KnockKnock → Preferences → Results
├─ Suspicious findings: ALERT & LOG
├─ Known malware: QUARANTINE
├─ Save scan reports: ENABLED (~/KnockKnock_Reports/)
└─ Review reports: After each scan
```

---

### STEP 6: ClamAV Configuration

**Objective:** Daily antivirus scanning that doesn't interfere with other tools.

**6A. Current Setup (Already Configured):**
```
Schedule: Daily at 12:30 PM via LaunchAgent
Script: ~/Warp/scripts/clamav_daily_scan.sh
Database: Updated automatically
Logging: /tmp/com.user.clamav-daily.out.log
```

**6B. Exclusions (Prevent Conflicts):**
```
Edit: ~/.clamav.conf (if needed)
├─ Exclude directories:
│  ├─ /Library/Caches (too large, many false positives)
│  ├─ /Library/Logs (historical data)
│  ├─ /tmp (temporary files scanned anyway)
│  └─ /dev (device files)
└─ Exceptions:
   └─ Do NOT exclude /Applications or ~/Warp/
```

**6C. Scan Optimization:**
```
Edit: ~/Warp/scripts/clamav_daily_scan.sh
├─ Current settings optimize for:
│  ├─ Real-time updates
│  ├─ Low system impact
│  ├─ Comprehensive scanning
│  └─ Daily scheduling
└─ No changes needed - already optimal
```

**6D. Quarantine Management:**
```
ClamAV Quarantine: /var/log/clamav/
├─ Infected files: Logged and tracked
├─ Review quarantine: Weekly
├─ Manual cleanup: As needed
└─ Coordinate with KnockKnock findings
```

---

### STEP 7: Time Machine Configuration

**Objective:** Backup system safely alongside security tools.

**7A. Basic Setup:**
```
System Preferences → Time Machine
├─ Backup Drive: (your Time Machine backup disk)
├─ Automatic Backups: ENABLED
├─ Backup Frequency: Every hour (default)
└─ Backup Status: Check regularly
```

**7B. Exclusions (Speed Up Backups):**
```
System Preferences → Time Machine → Options
├─ Exclude from Backup:
│  ├─ /Library/Caches (not needed for recovery)
│  ├─ /Library/Logs (historical, can be regenerated)
│  ├─ ~/Downloads (temporary)
│  ├─ /tmp (temporary files)
│  ├─ /var/tmp (temporary)
│  └─ Third-party app caches
├─ Keep in Backup:
│  ├─ ~/Warp/ (your scripts - CRITICAL)
│  ├─ /Applications (security software)
│  ├─ ~/Library/LaunchAgents (automation)
│  └─ System files
└─ Backup size impact: Reduced by 50%+
```

**7C. Encryption:**
```
Time Machine → Encryption
├─ Encrypt backups: ENABLED
├─ Password: (strong, stored in Keychain)
└─ Encryption algorithm: AES-128
```

**7D. Retention & Maintenance:**
```
Time Machine → Maintenance
├─ Keep backups: All (don't auto-delete)
├─ Manual cleanup: Use tm_retention.sh script
│  └─ Keeps 30 most recent backups
│  └─ Located in ~/Warp/scripts/tm_retention.sh
├─ Verify backup integrity: Monthly
│  └─ Command: tmutil verifybackup
└─ Size limit: Monitor disk usage
```

---

## 🚨 Conflict Resolution Matrix

### Scenario 1: AdGuard + Little Snitch Mini
**Conflict Type:** Both monitor network traffic  
**Resolution:**
- ✅ AdGuard blocks at DNS level (domain names)
- ✅ Little Snitch monitors at connection level (IP connections)
- ✅ No conflict - different layers
- 📋 Action: Both can run simultaneously

### Scenario 2: Little Snitch Mini + LuLu
**Conflict Type:** Both control outbound connections  
**Resolution:**
- ✅ LuLu blocks (blocks connections)
- ✅ Little Snitch logs (monitors connections)
- ✅ No conflict - different roles
- 📋 Action: Configure Little Snitch to MONITOR, LuLu to BLOCK

### Scenario 3: ClamAV + KnockKnock
**Conflict Type:** Both scan for malware  
**Resolution:**
- ✅ ClamAV scans files (signature-based)
- ✅ KnockKnock scans persistence (behavior-based)
- ✅ Minimal overlap, complementary coverage
- 📋 Action: ClamAV daily, KnockKnock weekly (different schedules)

### Scenario 4: OverSight + System Audio
**Conflict Type:** Both access audio devices  
**Resolution:**
- ✅ OverSight monitors access requests (logs, doesn't block)
- ✅ System audio still functions normally
- ✅ No conflict - monitoring vs. functionality
- 📋 Action: OverSight logs, application functions normally

### Scenario 5: All Tools + Time Machine
**Conflict Type:** Backup compatibility  
**Resolution:**
- ✅ Time Machine backs up application configs
- ✅ Security tool states restored if needed
- ✅ Full system recovery possible
- 📋 Action: Exclude caches/logs, keep application data

---

## 📋 Daily Maintenance Schedule

### Every Day
- ✅ Check Little Snitch Mini alerts (review suspicious connections)
- ✅ Check OverSight logs (new camera/mic access)
- ✅ Check LuLu blocked connections (real threats?)

### Daily Automated
- ✅ ClamAV scan at 12:30 PM (~/Warp/scripts/clamav_daily_scan.sh)
- ✅ Battery monitor continuous
- ✅ System check at 9:00 AM

### Weekly
- ✅ Run KnockKnock full system scan
- ✅ Review ClamAV quarantine
- ✅ Check Time Machine backup status
- ✅ Review LuLu blocked connections (trends)
- ✅ Verify backups are current

### Monthly
- ✅ Review AdGuard blocked domains
- ✅ Run manual security audit script
- ✅ Update all security definitions (if manual)
- ✅ Test Time Machine restore (verify integrity)

### Quarterly
- ✅ Review and update whitelists
- ✅ Check for security tool updates
- ✅ Audit system extensions
- ✅ Review historical logs

---

## ✅ Configuration Checklist

- [ ] **AdGuard**
  - [ ] Network Extension enabled
  - [ ] Exclude Warp scripts
  - [ ] VPN configured with local network exceptions
  - [ ] Split tunneling excludes security tools

- [ ] **Little Snitch Mini**
  - [ ] Monitoring mode active
  - [ ] Trusted apps whitelisted (AdGuard, LuLu, system)
  - [ ] Stealth mode enabled
  - [ ] Set to MONITOR (not BLOCK)
  - [ ] Logging enabled

- [ ] **LuLu**
  - [ ] Firewall in BLOCK MODE
  - [ ] All trusted apps whitelisted
  - [ ] Warp scripts whitelisted
  - [ ] Default policy set to DENY
  - [ ] Logging enabled (all connections)

- [ ] **OverSight**
  - [ ] Microphone monitoring enabled
  - [ ] Camera monitoring enabled
  - [ ] Trusted apps whitelisted
  - [ ] Alerts enabled
  - [ ] Logging enabled

- [ ] **KnockKnock**
  - [ ] Weekly scan scheduled (not daily)
  - [ ] System-wide scanning enabled
  - [ ] Auto-quarantine enabled
  - [ ] Report saving enabled
  - [ ] Configured to complement ClamAV

- [ ] **ClamAV**
  - [ ] Daily scan at 12:30 PM active
  - [ ] Database updates automatic
  - [ ] Logging to /tmp/
  - [ ] LaunchAgent verified
  - [ ] Already integrated in ~/Warp/scripts/

- [ ] **Time Machine**
  - [ ] Automatic backups enabled
  - [ ] Encryption enabled
  - [ ] Caches/logs excluded (reduce size)
  - [ ] Critical files included (scripts, configs)
  - [ ] Backup disk with sufficient space

---

## 🔗 System Extension Management

### Current System Extensions (Active):
```
✅ Little Snitch Mini Network Extension (main firewall)
✅ AdGuard Network Extension (DNS filtering)
✅ AdGuard VPN Network Extension (VPN protection)
✅ LuLu System Extension (outbound firewall)
```

### Disable Full Little Snitch (Not Needed):
Since you're using Little Snitch **Mini** (which is enabled), the full Little Snitch network extension should be disabled to avoid confusion:

```bash
# Check status
sudo systemextensionsctl list

# If "Little Snitch Network Extension" (non-mini) shows as "activated,disabled", it's fine
# If it shows "activated,enabled", disable it:
sudo systemextensionsctl uninstall com.obdev.LittleSnitchNetworkExtension
```

---

## 📞 Quick Troubleshooting

### Issue: "Applications can't connect to network"
**Diagnosis:**
- [ ] Check LuLu blocklist
- [ ] Check AdGuard domain filters
- [ ] Check Little Snitch rules
- [ ] Check System Preferences → Security

**Solution:**
1. Open LuLu, find blocked app, allow it
2. Open AdGuard, check if domain is blocked
3. Open Little Snitch, check if connection is logged as blocked

### Issue: "Network is unusually slow"
**Diagnosis:**
- [ ] AdGuard filtering overhead
- [ ] ClamAV scan in progress
- [ ] Time Machine backup running
- [ ] LuLu processing heavy traffic

**Solution:**
1. Check Activity Monitor for high CPU
2. Check clamav process: `ps aux | grep clam`
3. Check Time Machine: `tmutil status`
4. Temporarily lower AdGuard filters if needed

### Issue: "OverSight keeps alerting for normal apps"
**Diagnosis:**
- [ ] App not whitelisted
- [ ] System process not recognized
- [ ] Audio device being accessed

**Solution:**
1. Add app to OverSight whitelist
2. Check if it's a legitimate system app
3. Review what's triggering the alert

### Issue: "ClamAV finds "infected" file but it's legitimate"
**Diagnosis:**
- [ ] False positive in ClamAV database
- [ ] Legitimate tool flagged as suspicious
- [ ] Test file or known-benign sample

**Solution:**
1. Check ClamAV logs: `/tmp/com.user.clamav-daily.out.log`
2. Report to ClamAV team if it's a false positive
3. Add file to ClamAV exclusions if confirmed safe

---

## 🎯 Expected Behavior After Configuration

### Green Light Indicators ✅
- [ ] All applications connect normally (whitelisted)
- [ ] Malicious domains blocked by AdGuard
- [ ] Suspicious outbound connections blocked by LuLu
- [ ] Camera/mic access logged by OverSight
- [ ] Weekly KnockKnock scans complete successfully
- [ ] Daily ClamAV scans complete at 12:30 PM
- [ ] Time Machine backups run hourly
- [ ] Little Snitch shows connection logs (not alerts for whitelisted apps)

### Yellow Light Indicators ⚠️
- [ ] Unknown app trying to connect (verify, then whitelist)
- [ ] Suspicious domain blocked by AdGuard (review logs)
- [ ] ClamAV finds signature match (verify, then quarantine)
- [ ] OverSight alerts for camera access (check which app)

### Red Light Indicators 🔴
- [ ] Network completely blocked (check LuLu whitelist)
- [ ] ClamAV finds active malware (quarantine immediately)
- [ ] KnockKnock finds persistent malware (quarantine, research)
- [ ] OverSight detects unauthorized camera access (disable camera, investigate)

---

## 📚 Reference Documentation

- **README.md** - General repository guide
- **QUICKSTART.md** - Daily operations guide
- **ClamAV Script** - ~/Warp/scripts/clamav_daily_scan.sh
- **LuLu App** - /Applications/LuLu.app
- **Little Snitch Mini** - /Applications/Little Snitch Mini.app
- **AdGuard** - /Applications/AdGuard.app
- **OverSight** - /Applications/OverSight.app
- **KnockKnock** - /Applications/KnockKnock.app

---

## ✨ Summary

Your security stack is comprehensive and well-designed. By following this configuration guide:

1. **No conflicts** - Each tool operates at a different layer
2. **No redundancy** - Each tool has a unique role
3. **Better protection** - Layered defense catches different threat types
4. **Easier maintenance** - Clear logging and monitoring points
5. **Fast performance** - Optimized exclusions and settings

**Result:** A secure, harmonious security stack that works together seamlessly.

---

**Guide Created:** September 12, 2026  
**Configuration Status:** Ready to implement  
**Maintenance Level:** Daily brief, weekly detailed check

