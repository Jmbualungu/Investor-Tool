# Quick Start: Legal Pages for App Store

## ⚡ 5-Minute Deployment Guide

### 1. Deploy to GitHub Pages (Recommended)

```bash
# Navigate to backend folder
cd "Investor Tool/backend"

# Create new repo (do this once on GitHub first)
# Repository name: forecastai-legal
# Visibility: Public

# Initialize and push
git init
git add privacy.html terms.html
git commit -m "Add ForecastAI legal pages"
git remote add origin https://github.com/YOUR_USERNAME/forecastai-legal.git
git push -u origin main
```

**Enable GitHub Pages:**
1. Go to your repo → Settings → Pages
2. Source: `main` branch, `/` (root)
3. Save

**Your URLs:**
- Privacy: `https://YOUR_USERNAME.github.io/forecastai-legal/privacy.html`
- Terms: `https://YOUR_USERNAME.github.io/forecastai-legal/terms.html`

### 2. Update App Code

Search and replace in **2 files**:

**Find:** `https://your-domain.com/privacy.html`  
**Replace:** `https://YOUR_USERNAME.github.io/forecastai-legal/privacy.html`

**Find:** `https://your-domain.com/terms.html`  
**Replace:** `https://YOUR_USERNAME.github.io/forecastai-legal/terms.html`

**Files to update:**
- `Features/Onboarding/DisclaimerView.swift` (lines ~220-230)
- `Features/Shell/SettingsView.swift` (lines ~120-140)

### 3. Wire Settings into App

Add SettingsView to your tab bar or navigation:

```swift
// In your TabView or main navigation
SettingsView()
    .tabItem {
        Label("Settings", systemImage: "gearshape")
    }
```

### 4. Test

```bash
# Build and run
⌘R in Xcode

# Test in app:
# - Tap Privacy Policy link in onboarding
# - Tap Terms link in onboarding
# - Open Settings
# - Tap Privacy Policy in Settings
# - Tap Terms in Settings
```

### 5. Add to App Store Connect

**App Privacy:**
- Privacy Policy URL: `https://YOUR_USERNAME.github.io/forecastai-legal/privacy.html`

**App Information:**
- Terms URL: `https://YOUR_USERNAME.github.io/forecastai-legal/terms.html`

---

## 🎯 That's It!

You're ready to submit to App Store.

See `LEGAL_IMPLEMENTATION_SUMMARY.md` for full details.
