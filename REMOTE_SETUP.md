# Remote Repository Setup Guide

**Date:** September 12, 2026  
**Repository:** ~/Warp/  
**Local Status:** ✅ Ready to push

---

## 🚀 Quick Setup (Choose One)

### GitHub (Recommended)
```bash
# 1. Go to github.com and create new repository named "Warp"
# 2. Run these commands:
cd ~/Warp
git remote add origin https://github.com/YOUR_USERNAME/Warp.git
git branch -M main
git push -u origin main
```

### GitLab
```bash
cd ~/Warp
git remote add origin https://gitlab.com/YOUR_USERNAME/Warp.git
git branch -M main
git push -u origin main
```

### Bitbucket
```bash
cd ~/Warp
git remote add origin https://bitbucket.org/YOUR_USERNAME/Warp.git
git branch -M main
git push -u origin main
```

### Self-Hosted Git Server
```bash
cd ~/Warp
git remote add origin git@your-server.com:path/to/Warp.git
git branch -M main
git push -u origin main
```

---

## 📊 Current Repository Status

**Local Repository:**
- ✅ 2 commits (ef2018e, 6e75966)
- ✅ 486 files tracked
- ✅ 2.9 MB repository size
- ✅ Branch: main
- ✅ No uncommitted changes

**Ready to Push:**
- ✅ All documentation committed
- ✅ All scripts committed
- ✅ All configuration backups committed
- ✅ Git history clean

---

## 🔐 Authentication Methods

### HTTPS (Easier, Recommended for First Time)
Requires GitHub/GitLab personal access token instead of password.

```bash
git remote add origin https://github.com/your-username/Warp.git
git push -u origin main
# Enter username and personal access token when prompted
```

**Create Personal Access Token:**
- GitHub: Settings > Developer settings > Personal access tokens > Generate new token
- GitLab: Settings > Access tokens > Create personal access token
- Bitbucket: Personal settings > App passwords > Create app password

### SSH (More Secure, Recommended After Setup)
Requires SSH key pair configured.

```bash
git remote add origin git@github.com:your-username/Warp.git
git push -u origin main
# Uses your SSH key for authentication
```

**Generate SSH Key (if needed):**
```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
cat ~/.ssh/id_ed25519.pub  # Copy this to GitHub/GitLab SSH keys settings
```

---

## ✅ Verification Steps

After pushing, verify everything is correct:

```bash
# Check remote is configured
git remote -v

# Verify branch is pushed
git branch -r

# Check commit history
git log --oneline --all

# View repository on GitHub/GitLab
# Open https://github.com/your-username/Warp in browser
```

Expected output from `git remote -v`:
```
origin  https://github.com/your-username/Warp.git (fetch)
origin  https://github.com/your-username/Warp.git (push)
```

---

## 📋 What Will Be Pushed

Your repository contains:

### Scripts (9 files)
- All automation scripts with version control
- Executable permissions preserved
- Full history available for each file

### LaunchAgent Backups (6 files)
- Configuration files for reference
- Can be restored from git if needed

### Documentation (6 files)
- Complete guides and references
- Commit history for documentation changes
- Easy to view online

### System Backups & Archives
- Timestamped configuration snapshots
- Compressed archives of old folders
- Full restore capability

**Total: 486 files, 2.9 MB**

---

## 🔄 Ongoing Workflow

After pushing:

### Making Changes
```bash
cd ~/Warp
# Edit files
nano scripts/myscript.sh

# Test changes
~/Warp/scripts/myscript.sh

# Commit changes
git add scripts/myscript.sh
git commit -m "Update myscript.sh: description"

# Push to remote
git push origin main
```

### Pulling Updates (if using multiple machines)
```bash
cd ~/Warp
git pull origin main
```

### Creating Branches
```bash
git checkout -b feature/new-feature
# Make changes
git commit -m "Add feature"
git push -u origin feature/new-feature
```

---

## 🔒 Security Considerations

### Keep Private
- Don't push sensitive data (passwords, API keys, etc.)
- Bitwarden backups should only exist locally/on SD card
- SSH keys should never be committed

### Public Repository Recommendations
- Review `.gitignore` for excluded files
- Keep sensitive credentials in environment variables
- Use GitHub Secrets for CI/CD if needed

### Private Repository Option
- Create as private if managing sensitive scripts
- Grant access only to trusted users
- Still benefits from version control and backup

---

## 📞 Troubleshooting

### "fatal: remote origin already exists"
```bash
# Remove existing remote
git remote remove origin

# Add the correct one
git remote add origin <url>
```

### "permission denied (publickey)"
SSH authentication failed. Try HTTPS instead:
```bash
git remote set-url origin https://github.com/your-username/Warp.git
```

### "authentication failed"
Personal access token expired or invalid:
- GitHub: Create new token at Settings > Developer settings
- GitLab: Create new token at Settings > Access tokens
- Update local credentials: `git credential-osxkeychain erase`

### "failed to push some refs"
Remote has changes you don't have locally:
```bash
git pull origin main
git push origin main
```

---

## 🎯 Next Steps

1. **Create Remote Repository**
   - Go to GitHub.com (or your chosen platform)
   - Create new repository named "Warp"
   - Copy the HTTPS or SSH URL

2. **Add Remote**
   ```bash
   git remote add origin <your-url>
   ```

3. **Push Repository**
   ```bash
   git push -u origin main
   ```

4. **Verify**
   - Visit your repository online
   - Confirm all files are there
   - Check commit history

5. **Configure for Future Use**
   - Set default push branch: `git config --global push.default current`
   - Cache credentials: `git config --global credential.helper osxkeychain`
   - Update email: `git config --global user.email "your-email@example.com"`

---

## 📚 Useful Commands After Push

```bash
# View remote info
git remote show origin

# Update remote tracking branches
git fetch origin

# Sync with remote
git pull origin main

# Push current branch
git push origin main

# Push all branches
git push origin --all

# Push with tags
git push origin --tags

# Delete remote branch
git push origin --delete branch-name

# Rename local branch
git branch -m old-name new-name
git push origin --delete old-name
git push -u origin new-name
```

---

## ✨ Benefits of Remote Repository

✅ **Backup** - Your code is safely stored offsite  
✅ **Collaboration** - Easy to share with others  
✅ **History** - Full git history accessible online  
✅ **CI/CD** - Can automate testing with GitHub Actions, GitLab CI  
✅ **Access** - View and manage repository from anywhere  
✅ **Documentation** - Markdown files render nicely  

---

## 📈 Repository Statistics

**Before Push:**
- Location: `~/Warp/`
- Commits: 2
- Files: 486
- Size: 2.9 MB (git + content)
- Status: Ready to push

**After Push:**
- Remote: origin (github.com/gitlab.com/etc)
- Backup: ✅ Safe offsite
- Access: ✅ Online viewing
- Collaboration: ✅ Ready for team use

---

**Instructions Created:** September 12, 2026  
**Next Action:** Follow steps above to create remote and push  
**Repository Status:** ✨ Ready for remote backup
