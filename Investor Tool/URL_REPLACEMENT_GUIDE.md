# URL Replacement Guide

After deploying your legal pages, you need to replace placeholder URLs in the app code.

## 🔍 Find and Replace

### Your Deployed URLs
After deploying to GitHub Pages, Vercel, or Netlify, you'll have two URLs:

**Example (GitHub Pages):**
```
Privacy: https://yourusername.github.io/forecastai-legal/privacy.html
Terms:   https://yourusername.github.io/forecastai-legal/terms.html
```

**Example (Vercel):**
```
Privacy: https://forecastai-legal.vercel.app/privacy.html
Terms:   https://forecastai-legal.vercel.app/terms.html
```

---

## 📝 File 1: DisclaimerView.swift

**Path:** `Features/Onboarding/DisclaimerView.swift`

**Line 233 - Privacy Policy:**
```swift
// TODO: Replace with your actual hosted URL after deployment
if let url = URL(string: "https://your-domain.com/privacy.html") {
```

**Replace with:**
```swift
if let url = URL(string: "https://YOUR_ACTUAL_URL/privacy.html") {
```

**Line 241 - Terms of Service:**
```swift
// TODO: Replace with your actual hosted URL after deployment
if let url = URL(string: "https://your-domain.com/terms.html") {
```

**Replace with:**
```swift
if let url = URL(string: "https://YOUR_ACTUAL_URL/terms.html") {
```

---

## 📝 File 2: SettingsView.swift

**Path:** `Features/Shell/SettingsView.swift`

**Line 130 - Privacy Policy:**
```swift
// TODO: Replace with your actual hosted URL after deployment
if let url = URL(string: "https://your-domain.com/privacy.html") {
```

**Replace with:**
```swift
if let url = URL(string: "https://YOUR_ACTUAL_URL/privacy.html") {
```

**Line 138 - Terms of Service:**
```swift
// TODO: Replace with your actual hosted URL after deployment
if let url = URL(string: "https://your-domain.com/terms.html") {
```

**Replace with:**
```swift
if let url = URL(string: "https://YOUR_ACTUAL_URL/terms.html") {
```

---

## 🔎 Quick Find in Xcode

1. Press `⌘⇧F` (Find in Project)
2. Search for: `https://your-domain.com`
3. Should find exactly 4 matches
4. Replace all with your actual domain

---

## ✅ Verification

After replacement, search for:
- `your-domain.com` → Should find 0 matches
- `TODO: Replace` → Should still find 4 matches (comments are OK)
- Your actual URL → Should find 4 matches

---

## 🧪 Test

1. Build app (`⌘R`)
2. Complete onboarding → Tap "Privacy Policy" → Should open your deployed page
3. Tap "Terms of Service" → Should open your deployed page
4. Open Settings → Tap both legal links → Should work

---

## 📧 Email Verification

If you need to change the support email from `support@forecastai.app`:

**iOS Files:**
- `SettingsView.swift` line 145: `mailto:support@forecastai.app`

**HTML Files:**
- `backend/privacy.html` lines 145, 147
- `backend/terms.html` line 220

**Total:** 4 places to update
