# iOS QA findings — Valtyde (Investor Tool)

Harness: `audit/ios-screens.sh` (simctl). Captured Auth + Forecast-home across **compact (iPhone 17e
390×844), standard (iPhone 17), large (17 Pro Max 440×956)**. Deeper screens need idb/manual taps.
Screenshots in `audit/screenshots/ios/<class>/`. Branch `backend-foundation`, deployment target iOS 17.6,
built with Xcode 26 / iOS 26.5 SDK.

## What passes (evidence)
- **Forecast home renders cleanly at all three sizes** — live prices + intraday "% today ▲/▼" +
  custom floating tab bar scale correctly; no clipping/overlap in core layout.
- Auth screen renders (wordmark, email/password, Sign In, "Continue without an account").
- Live Finnhub data flows in the simulator.

## Issues (scored)
| ID | Pri | Issue | Evidence |
|----|-----|-------|----------|
| IOS-1 | P0 | **No `augur://` redirect on Supabase allow-list** (go-live blocker for password-reset/deep-link). | app-store/ARCHIVE_AND_SUBMIT.md §0 |
| IOS-2 | P1 | **Zero XCTest/XCUITest** — no unit tests on DCFEngine, no UI automation, no CI gate. | project has no test target |
| IOS-3 | P1 | **App Store screenshots incomplete** — only 3 in `app-store/screenshots/`; missing ValuationResults + Sensitivity (Apple wants 3–5 polished). | app-store/screenshots/ |
| IOS-4 | P2 | **Debug "Layout" HUD overlays the top-left** on every screen, partially covering the brand mark/nav. Confirm it's `#if DEBUG` gated so it never ships in Release. | all ios screenshots |
| IOS-5 | P2 | **Debug-only auth buttons** ("Skip for now (Debug)", "Create Test Account (Debug)") visible — confirm `#if DEBUG` gated. | compact/01-onboarding.png |
| IOS-6 | P2 | **Fixed frames + hardcoded font sizes** in ValueGauge (`.frame(width:50,height:138)`) and the Sensitivity 2D grid (80×40 cells); `.system(size:48)` ignores Dynamic Type → overflow risk on Large Text. | code audit (ValuationResultsView, SensitivityAnalysisView) |
| IOS-7 | P2 | **Missing loading/empty states** — Watchlist shows blank while quotes load; ForecastHome search has no "no results" copy; TickerDetail loads sections without skeletons. | code audit |
| IOS-8 | P2 | No compact SE-class simulator installed → smallest tested is 390pt wide; true SE (375pt) untested. | simctl device list |

## App Store readiness (good)
Privacy manifest complete (no tracking, email-for-functionality), `ITSAppUsesNonExemptEncryption=false`,
guest mode, account deletion + deployed `delete-account` edge fn, Privacy/Terms URLs live, LISTING.md +
ExportOptions.plist + runbook present, Xcode 26/iOS 26.5 SDK satisfies Apple's 2026 upload rule. Archive
needs the M3F8AR88HZ distribution cert (James, in Xcode).

## Score (rubric: core flows 25 · visual 15 · responsive 15 · data consistency 15 · error handling 10 · security/privacy 10 · docs 10)
- core flows 22/25 (home/auth/live data verified; DCF 7-step + watchlist not auto-captured)
- visual 12/15 (clean; debug HUD overlay + fixed-frame risks)
- responsive 13/15 (holds compact→large; SE 375pt + deep screens untested)
- data consistency 12/15 (live quotes + Supabase auth; web↔iOS parity unverified)
- error handling 5/10 (IOS-7)
- security/privacy 9/10 (privacy manifest + guest + deletion strong; IOS-1 config pending)
- docs 8/10 (strong app-store runbook)
**Total ≈ 81 / 100** (threshold 90) — gated by tests, deep-screen/SE coverage, error states, debug-gating, App Store screenshots.
