# Legal Pages Hosting Instructions

This folder contains the Privacy Policy and Terms of Service HTML pages for ForecastAI.

## Files
- `privacy.html` - Privacy Policy
- `terms.html` - Terms of Service

## Deployment Options

### Option 1: GitHub Pages (Recommended - Free & Simple)

1. **Create a new repository** (e.g., `forecastai-legal`)
2. **Upload files:**
   ```bash
   git init
   git add privacy.html terms.html
   git commit -m "Add legal pages"
   git remote add origin https://github.com/YOUR_USERNAME/forecastai-legal.git
   git push -u origin main
   ```
3. **Enable GitHub Pages:**
   - Go to repository Settings → Pages
   - Source: Deploy from branch `main` / root folder
   - Save

4. **Your URLs will be:**
   - Privacy: `https://YOUR_USERNAME.github.io/forecastai-legal/privacy.html`
   - Terms: `https://YOUR_USERNAME.github.io/forecastai-legal/terms.html`

### Option 2: Vercel (Recommended - Professional)

1. **Install Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Deploy from this folder:**
   ```bash
   cd backend
   vercel
   ```

3. **Follow prompts:**
   - Link to existing project or create new
   - Accept defaults
   - Your pages will be live at `https://your-project.vercel.app/privacy.html` and `/terms.html`

4. **Optional: Custom domain:**
   - Go to Vercel dashboard → Settings → Domains
   - Add `legal.forecastai.app` or similar
   - Update DNS records as instructed

### Option 3: Netlify

1. **Drag and drop:**
   - Go to https://app.netlify.com/drop
   - Drag the `backend` folder
   - Done! Pages live instantly

2. **URLs:**
   - Privacy: `https://your-site.netlify.app/privacy.html`
   - Terms: `https://your-site.netlify.app/terms.html`

### Option 4: Simple Static Hosting

Upload `privacy.html` and `terms.html` to any web server:
- AWS S3 + CloudFront
- Firebase Hosting
- Cloudflare Pages
- Your own domain

## After Deployment

### 1. Update App Store Connect

Once deployed, add URLs to App Store Connect:

**App Privacy:**
- Privacy Policy URL: `https://your-domain.com/privacy.html`

**App Information:**
- Terms of Service URL: `https://your-domain.com/terms.html`

### 2. Update iOS App Code

Replace placeholder URLs in:
- `DisclaimerView.swift` (line ~205-206)
- `SettingsView.swift` (line ~60-61)

Change from:
```swift
let privacyURL = URL(string: "https://your-domain.com/privacy.html")!
let termsURL = URL(string: "https://your-domain.com/terms.html")!
```

To your actual URLs:
```swift
let privacyURL = URL(string: "https://yourusername.github.io/forecastai-legal/privacy.html")!
let termsURL = URL(string: "https://yourusername.github.io/forecastai-legal/terms.html")!
```

### 3. Test URLs

Before submitting to App Store:
- ✅ Open URLs on iPhone Safari
- ✅ Verify pages load without authentication
- ✅ Check mobile responsiveness
- ✅ Test in-app Safari view
- ✅ Verify all links work

## Quick Deploy Script (GitHub Pages)

```bash
#!/bin/bash
# Run from project root

cd "Investor Tool/backend"

# Initialize git if needed
if [ ! -d .git ]; then
    git init
    git remote add origin https://github.com/YOUR_USERNAME/forecastai-legal.git
fi

# Commit and push
git add privacy.html terms.html
git commit -m "Update legal pages"
git push origin main

echo "✅ Legal pages deployed!"
echo "📝 Enable GitHub Pages in repository settings"
```

## Maintenance

To update legal pages:
1. Edit `privacy.html` or `terms.html`
2. Update "Effective Date" at the top
3. Re-deploy using your chosen method
4. Notify users of material changes via the app

## Contact Email

All legal pages reference: `support@forecastai.app`

If this email doesn't exist yet, either:
- Create it before deploying, OR
- Replace with your actual support email in both HTML files
