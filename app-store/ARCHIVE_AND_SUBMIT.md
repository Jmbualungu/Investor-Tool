# Valtyde — Archive & Submit runbook

Everything left to ship v1.0 to the App Store. Items marked **(you)** need
your Apple/Supabase credentials and can't be done from the agent environment.

---

## 0. One-time Supabase go-live (you)

Real accounts now point at the **forecastai** project (`rkfavupthyhadwpocyql`).
Two things to finish so the full auth flow works:

1. **Redirect allow-list (needed for the "Forgot password" deep link).**
   The app sends a reset link with `redirectTo = augur://auth-callback`. Add it
   to the project's allow-list. Either:
   - Dashboard: Supabase → **Authentication → URL Configuration** → add
     `augur://auth-callback` under **Redirect URLs**, and set **Site URL** to
     `https://jmbualungu.github.io/Investor-Tool/`. **Save.**
   - Or run this (paste your token — get it at
     https://supabase.com/dashboard/account/tokens):
     ```sh
     SUPABASE_ACCESS_TOKEN=sbp_xxx \
     curl -s -X PATCH "https://api.supabase.com/v1/projects/rkfavupthyhadwpocyql/config/auth" \
       -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
       -H "Content-Type: application/json" \
       -d '{"site_url":"https://jmbualungu.github.io/Investor-Tool/","uri_allow_list":"augur://auth-callback"}'
     ```
2. **Email confirmation** is ON (Supabase default) — new users get a confirm
   email before they can sign in. That's fine for launch. If you'd rather skip
   it for v1, turn off "Confirm email" under Authentication → Providers → Email.

The `delete-account` edge function is already deployed (ACTIVE) to this project.

---

## 1. Pre-flight (already done in the repo)
- ✅ App icon, launch screen, version keys (1.0 / 1)
- ✅ `PrivacyInfo.xcprivacy` + `ITSAppUsesNonExemptEncryption=false`
- ✅ Guest mode + account deletion in Settings
- ✅ Privacy/Terms live at https://jmbualungu.github.io/Investor-Tool/
- ✅ Debug + Release builds green

If you bump the version later: set `MARKETING_VERSION` (e.g. 1.0.1) and
`CURRENT_PROJECT_VERSION` (build number) in the target's build settings.

---

## 2. Create the app record in App Store Connect (you)
1. https://appstoreconnect.apple.com → **Apps → +** → New App.
2. Platform iOS; Name **Valtyde** (see `LISTING.md` for the exact strings);
   Primary language English (U.S.); Bundle ID `com.jamesmbualungu.InvestorTool`
   (register it in the Developer portal first if it's not in the dropdown);
   SKU `valtyde-ios`.
3. Fill the listing from `LISTING.md` (subtitle, description, keywords,
   promo text, support/privacy URLs), set category **Finance**, age rating
   **4+**, and the App Privacy answers (Email — optional, App Functionality,
   no tracking).
4. Upload screenshots from `app-store/screenshots/` (see §5).

---

## 3. Archive (you — must be in Xcode)
Only an Apple **Development** certificate exists on this Mac, and it's under a
**different team** (XLZVN9AYG2) than the app's team (**M3F8AR88HZ**). So the
agent cannot produce a distribution build. In Xcode:

1. Xcode → **Settings → Accounts** → make sure the Apple ID that owns team
   **M3F8AR88HZ** is added (this is the account your Developer Program is under).
2. Select the **Investor Tool** scheme → destination **Any iOS Device (arm64)**.
3. **Product → Archive.** Xcode auto-creates the Distribution cert + App Store
   provisioning profile for M3F8AR88HZ the first time.

### Optional: archive from the command line
Once the distribution cert/profile exist in Xcode, you can script it:
```sh
cd "/Users/jamesmbualungu/Developer/Repos/Investor Tool"
xcodebuild -scheme "Investor Tool" -configuration Release \
  -destination 'generic/platform=iOS' -archivePath build/Valtyde.xcarchive archive
xcodebuild -exportArchive -archivePath build/Valtyde.xcarchive \
  -exportOptionsPlist app-store/ExportOptions.plist -exportPath build/export
```

---

## 4. Upload (you)
- From the Xcode **Organizer**: select the archive → **Distribute App → App
  Store Connect → Upload**, or
- Use **Transporter** (Mac App Store) with the exported `.ipa` from §3, or
- `xcrun altool`/`notarytool` flows if you prefer CLI.

Wait for the build to finish "Processing" in App Store Connect, then attach it
to the 1.0 version.

---

## 5. Screenshots
Required size: **6.9"** (iPhone 16/17 Pro Max). Files in
`app-store/screenshots/` were captured from a Release simulator build. The
guided DCF result/sensitivity screens need taps the agent couldn't drive
reliably — capture those manually:
```sh
xcrun simctl boot "iPhone 17 Pro Max"
# build+install a Release build, run it, tap AAPL → walk the 7 steps,
# and screenshot each screen you want to feature:
xcrun simctl io booted screenshot ~/Desktop/valtyde-<screen>.png
```
You need at least 1 (Apple recommends 3–5). Good candidates: Start a Forecast,
Company Context, Valuation Results, Sensitivity, Settings.

---

## 6. Submit (you)
Answer Export Compliance (already declared exempt via
`ITSAppUsesNonExemptEncryption=false`), Content Rights, and Advertising
Identifier (No). Add the reviewer notes from `LISTING.md`. **Submit for Review.**
