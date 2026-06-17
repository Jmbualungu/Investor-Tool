# DCF / sensitivity model findings — Valtyde

> **Update 2026-06-16 (fix pass):** **DCF-1 RESOLVED** — `SensitivityAnalysisView.calculateIntrinsicValue`
> now calls `DCFEngine.discountedValuation` with the same FCF index + `investmentLens.horizon.years` as
> the Results page, so the grid reconciles (Base Case row == headline intrinsic). **DCF-3 RESOLVED** — 1D
> flex is now multiplicative for all variables; labels show "±N%" uniformly. iOS build green. Score 65 → **83**.
> **DCF-2 RESOLVED** — exit-multiple terminal method is now functional: `DCFEngine.discountedValuation`
> branches on `terminalMethod` (perpetuity Gordon vs `multiple × final-year FCF`), wired through
> `evaluateDCF`/`derivedValuation`/sensitivity; the UI toggle is enabled with an exit-multiple stepper
> (default 15×). Score 83 → **87**. Still open: DCF-4 (index-vs-$ disclaimer, P2), DCF-5 (legacy
> ForecastEngine, P2).


Files: `Core/Services/DCFEngine.swift`, `Features/DCFSetup/SensitivityAnalysisView.swift`,
`Core/Services/ForecastEngine.swift`, `DCFFlowState.swift`, assumption/result models.

## What's correct (evidence)
- **`DCFEngine.discountedValuation` (lines 116–157) is a genuine Gordon-growth DCF**: per-year FCF
  discounting `pvForecast += fcf / pow(1.0 + r, t)` (141), discounted terminal value
  `pvTerminal = terminalValue / pow(1.0 + r, n)` (147), `r−g ≥ 2%` guard (126), terminal-share %
  (151). Sound mechanics.
- **Scenario manager exists** — bear/base/bull adjusters in `DCFEngine` (lines ~205–246).

## Issues (scored)
| ID | Pri | Issue | Evidence |
|----|-----|-------|----------|
| DCF-1 | **P0** | **Sensitivity grid ≠ main valuation.** `SensitivityAnalysisView.calculateIntrinsicValue` (501–520) uses a *separate, non-discounted* formula: `baseScale=1.2` (512), `forecastPV = fcfIndex*1.2*0.9*pvFactor` (516), `terminalPV = fcfIndex*1.2*0.6*terminalFactor` (517), with `pvFactor = 1/(discountRate/100)` (513) — **no `pow(1+r,t)`** — and clamps `[20,800]` (520). The main engine discounts properly and clamps `[5,2000]`. So the same inputs yield **different intrinsic values** on the Results vs Sensitivity screens. Fix: have the grid call `DCFEngine.discountedValuation`. | lines cited |
| DCF-2 | P1 | **`terminalMethod` toggle is dead.** The perpetuity-vs-exit-multiple enum is never read by the engine (always Gordon perpetuity). A visible toggle that does nothing misleads users. | no `terminalMethod` ref in DCFEngine |
| DCF-3 | P1 | **Inconsistent 1D flex semantics.** Discount-rate flex is additive points while revenue/margin flex multiplicatively, so "±20%" means different things per row. | SensitivityAnalysisView 1D adjust |
| DCF-4 | P2 | **Index-unit model, not $/share.** Base revenue normalized to 100, intrinsic clamped — outputs are illustrative index values, not real per-share dollars. Must be explicit in the UI/disclaimer. | DCFEngine normalization |
| DCF-5 | P2 | **Legacy `ForecastEngine` is not a DCF** — revenue-multiple at horizon year, no discounting (secondary Forecast screen). Isolate/label or remove to avoid confusion. | ForecastEngine.swift |

## Score (rubric, threshold 95)
- formula correctness 18/25 (main engine correct; legacy non-DCF + sensitivity wrong)
- sensitivity linkage 4/20 (**broken — DCF-1**)
- scenario manager 15/15 (bear/base/bull present)
- error checks 12/15 (r−g guard + clamps; clamps arbitrary/undocumented)
- output clarity 10/15 (results page clean; index-vs-$ ambiguity)
- documentation 6/10 (index model not clearly disclaimed)
**Total ≈ 65 / 100** (threshold 95) — dominated by the P0 sensitivity mismatch, which is central to a DCF tool's credibility.
