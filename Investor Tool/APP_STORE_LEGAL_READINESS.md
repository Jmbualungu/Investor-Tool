# App Store Legal Readiness Checklist

## 📋 Overview

This document tracks the completion of Privacy Policy and Terms of Service implementation for ForecastAI's App Store submission.

---

## ✅ Phase 1: Legal Documents Created

### Files Created
- [x] `backend/privacy.html` - Comprehensive Privacy Policy
- [x] `backend/terms.html` - Comprehensive Terms of Service
- [x] `backend/HOSTING_INSTRUCTIONS.md` - Deployment guide
- [x] `backend/vercel.json` - Hosting configuration

### Content Coverage

**Privacy Policy includes:**
- [x] Data collection (email, user content, usage metadata)
- [x] Data we DON'T collect (brokerage credentials, payment info, location)
- [x] How data is used (authentication, service delivery, improvements)
- [x] Third-party services (Supabase)
- [x] Data security measures
- [x] Data retention and deletion rights
- [x] Children's privacy (not for under 18)
- [x] International users notice
- [x] Contact information (support@forecastai.app)
- [x] Effective date (January 21, 2026)

**Terms of Service includes:**
- [x] Clear "not financial advice" disclaimer
- [x] Educational/informational purpose statement
- [x] Investment risk disclosure
- [x] No warranties on accuracy
- [x] Limitation of liability
- [x] User responsibilities
- [x] Termination clause
- [x] Governing law (United States)
- [x] Contact information
- [x] Effective date (January 21, 2026)

---

## ✅ Phase 2: Hosting Setup

### Deployment Options Documented
- [x] GitHub Pages (recommended for simplicity)
- [x] Vercel (recommended for professional setup)
- [x] Netlify (drag-and-drop option)
- [x] Custom hosting instructions

### Next Steps for Deployment
- [ ] Choose hosting platform
- [ ] Deploy `privacy.html` and `terms.html`
- [ ] Verify URLs are publicly accessible
- [ ] Test on mobile Safari
- [ ] Update URLs in app code (see Phase 3)

---

## ✅ Phase 3: iOS App Integration

### Utilities Implemented
- [x] `Core/Utilities/DisclaimerManager.swift` - Manages disclaimer acceptance
- [x] `Core/Utilities/Haptics.swift` - Centralized haptic feedback
- [x] `App/GlobalAppConfig.swift` - App-wide configuration

### Views Updated/Created

**DisclaimerView.swift**
- [x] Added SafariServices import
- [x] Added legal links section (Privacy Policy • Terms of Service)
- [x] Links appear below disclaimer text, above checkbox
- [x] Opens in-app Safari view (SFSafariViewController)
- [x] Does NOT block onboarding flow
- [x] TODOs added for URL replacement

**SettingsView.swift** (Created)
- [x] Legal section with Privacy Policy link
- [x] Legal section with Terms of Service link
- [x] App Info section (version, build number)
- [x] Support section (contact email)
- [x] Opens links in Safari view
- [x] Professional iOS Settings UI
- [x] TODOs added for URL replacement

### URL Placeholders
Both views contain TODO comments at these lines:

**DisclaimerView.swift:**
```swift
// Line ~220-221
private func openPrivacyPolicy() {
    // TODO: Replace with your actual hosted URL after deployment
    if let url = URL(string: "https://your-domain.com/privacy.html") {
```

**SettingsView.swift:**
```swift
// Line ~120-130
private func openPrivacyPolicy() {
    // TODO: Replace with your actual hosted URL after deployment
    if let url = URL(string: "https://your-domain.com/privacy.html") {
```

---

## ⚠️ Action Required: Update URLs

After deploying legal pages, update these URLs in **two files**:

### 1. DisclaimerView.swift
Replace placeholders in `openPrivacyPolicy()` and `openTermsOfService()` methods.

### 2. SettingsView.swift
Replace placeholders in `openPrivacyPolicy()` and `openTermsOfService()` methods.

### Example (after GitHub Pages deployment):
```swift
private func openPrivacyPolicy() {
    if let url = URL(string: "https://yourusername.github.io/forecastai-legal/privacy.html") {
        safariURL = url
        showingSafari = true
    }
}

private func openTermsOfService() {
    if let url = URL(string: "https://yourusername.github.io/forecastai-legal/terms.html") {
        safariURL = url
        showingSafari = true
    }
}
```

---

## ⚠️ Action Required: Contact Email

**Current email:** support@forecastai.app

If this email doesn't exist yet, either:
1. **Create it** before deploying legal pages, OR
2. **Find-and-replace** in both HTML files:
   - `privacy.html`: Line 145, 147
   - `terms.html`: Line 220
   - `SettingsView.swift`: Line 135

---

## 📱 Phase 4: App Store Connect Setup

Once URLs are deployed and updated in code, add them to App Store Connect:

### App Privacy Section
1. Go to App Store Connect → Your App → App Privacy
2. Click "Get Started" or "Edit"
3. **Privacy Policy URL:** `https://your-domain.com/privacy.html`
4. Save

### App Information Section
1. Go to App Store Connect → Your App → App Information
2. Scroll to **Support**
3. **Privacy Policy URL:** `https://your-domain.com/privacy.html` (same as above)
4. **Terms of Service URL:** `https://your-domain.com/terms.html`
5. **Support URL (optional):** Your website or landing page
6. **Marketing URL (optional):** Your website or landing page
7. Save

---

## 🧪 Testing Checklist

Before submitting to App Store:

### In-App Testing
- [ ] Build and run app in Xcode
- [ ] Complete onboarding flow
- [ ] Tap "Privacy Policy" link in disclaimer → Verify Safari opens
- [ ] Tap "Terms of Service" link in disclaimer → Verify Safari opens
- [ ] Navigate to Settings (if accessible via tab bar or menu)
- [ ] Tap "Privacy Policy" in Settings → Verify Safari opens
- [ ] Tap "Terms of Service" in Settings → Verify Safari opens
- [ ] Verify app version displays correctly in Settings

### URL Testing
- [ ] Open Privacy Policy URL in mobile Safari
- [ ] Verify page loads without authentication
- [ ] Verify mobile responsive layout
- [ ] Verify all links work
- [ ] Open Terms of Service URL in mobile Safari
- [ ] Verify page loads without authentication
- [ ] Verify mobile responsive layout
- [ ] Verify all links work

### App Store Connect
- [ ] Privacy Policy URL entered
- [ ] Terms of Service URL entered
- [ ] URLs are publicly accessible (not localhost, not behind auth)
- [ ] URLs use HTTPS (not HTTP)

---

## 🚀 Deployment Steps

### Quick Deploy (GitHub Pages)

1. **Create repository:**
```bash
cd "Investor Tool/backend"
git init
git add privacy.html terms.html
git commit -m "Add legal pages"
git remote add origin https://github.com/YOUR_USERNAME/forecastai-legal.git
git push -u origin main
```

2. **Enable GitHub Pages:**
   - Go to repository Settings → Pages
   - Source: Branch `main` / root folder
   - Save

3. **Your URLs will be:**
   - Privacy: `https://YOUR_USERNAME.github.io/forecastai-legal/privacy.html`
   - Terms: `https://YOUR_USERNAME.github.io/forecastai-legal/terms.html`

4. **Update app code:**
   - Replace URLs in `DisclaimerView.swift` (2 places)
   - Replace URLs in `SettingsView.swift` (2 places)
   - Search for "TODO: Replace with your actual hosted URL"

5. **Test:**
   - Open URLs in mobile Safari
   - Test in-app links
   - Verify App Store Connect URLs

---

## 📝 Notes

### Design Decisions
- **Non-blocking:** Legal links don't block onboarding flow
- **In-app Safari:** Uses SFSafariViewController for seamless experience
- **Consistent UI:** Legal links appear in both onboarding and settings
- **Plain English:** Legal documents use clear, accessible language
- **Mobile-first:** HTML pages are fully responsive

### Architecture Compliance
- **Separation of concerns:** Legal content hosted separately from app
- **No backend dependencies:** Static HTML pages, no API calls
- **No state changes:** Viewing legal pages doesn't modify app state
- **Clean integration:** SafariView wrapper reusable across app

### App Store Compliance
- ✅ Privacy Policy URL required for App Privacy submission
- ✅ Terms of Service URL recommended for financial apps
- ✅ Contact email provided for user support
- ✅ No brokerage credentials or payment data collected
- ✅ Clear "not financial advice" disclaimers
- ✅ Investment risk disclosures prominent
- ✅ Age restriction (18+) stated in Terms

---

## 🎯 Final Checklist

Before App Store submission:
- [ ] Legal pages deployed and publicly accessible
- [ ] URLs updated in DisclaimerView.swift
- [ ] URLs updated in SettingsView.swift
- [ ] Contact email verified (support@forecastai.app)
- [ ] In-app links tested on physical device
- [ ] URLs added to App Store Connect
- [ ] All TODOs resolved in code
- [ ] App builds without warnings
- [ ] Legal links appear correctly in onboarding
- [ ] Settings view accessible (wired into tab bar or menu)

---

## 📧 Support

If you encounter issues:
1. Check `backend/HOSTING_INSTRUCTIONS.md` for detailed deployment steps
2. Verify URLs are HTTPS and publicly accessible
3. Test URLs in private/incognito browser window
4. Ensure no authentication required to view legal pages

---

**Status:** Ready for deployment and URL updates
**Last Updated:** January 21, 2026
**Next Steps:** Deploy legal pages → Update URLs → Test → Submit to App Store
