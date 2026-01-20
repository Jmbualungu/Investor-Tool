# Investor Tool (Forecast AI) — iOS SwiftUI App

## Quick Start
1) Open in Xcode
- Open Xcode.
- Choose **File → Open** and select the folder: `Investor Tool`.
- Open `Investor Tool.xcodeproj`.

2) Select iPhone simulator and run
- In the top toolbar, select a simulator device (e.g. **iPhone 16**).
- Ensure the scheme is **Investor Tool**.
- Press **Run** (▶︎) or `⌘R`.

3) Run on a physical device (signing steps)
- Connect your iPhone via USB or ensure it’s paired over Wi‑Fi.
- In Xcode, select your device from the toolbar.
- Go to **Signing & Capabilities** for the `Investor Tool` target.
- Set **Team** to your Apple ID or a paid team.
- Ensure **Bundle Identifier** is unique (e.g. `com.example.ForecastAI.yourname`).
- Xcode will prompt to enable developer mode on device if needed.
- Press **Run**.

## Common Errors and Fixes
- **Signing / bundle id error**
  - Fix: Update the bundle identifier to something unique and select a valid **Team**.
  - Location: **Signing & Capabilities** → Bundle Identifier.

- **Missing scheme**
  - Fix: In Xcode, go to **Product → Scheme → Manage Schemes** and ensure `Investor Tool` is shared.
  - If needed: close/reopen the project.

- **Build failures due to Derived Data**
  - Fix: **Xcode → Settings → Locations → Derived Data → Delete**.
  - Then **Product → Clean Build Folder** and rebuild.

## App Health Checklist (Before Each Session)
- Build once in the simulator (`⌘R`).
- Confirm **Signing & Capabilities** has a valid team and unique bundle id.
- Verify all Swift files are in the target: **Target → Build Phases → Compile Sources**.
- Clean build if you see stale errors (`⌘⇧K`).
- Ensure Previews load for at least one screen.
