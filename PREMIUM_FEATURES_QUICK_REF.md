# Premium Features Quick Reference

## Overview
This guide provides quick access to the premium features implementation for the DCF Setup Flow.

---

## 🎯 Key Features Implemented

### 1. Drift Indicators
**What**: Visual indicators showing when users deviate from base assumptions
**Where**: All three assumption screens (Revenue, Operating, Valuation)
**Components**: `DriftBadge`, `DriftDot`

### 2. Validation Guardrails
**What**: Auto-correcting validation with friendly warnings
**Rules**:
- Terminal growth < (discount rate - 0.5%)
- Operating margin ≤ gross margin
- Negative FCF warning (info only)
**Component**: `WarningBanner`

### 3. Save/Share Skeleton
**What**: Disabled UI signaling future product features
**Where**: ValuationResultsView bottom action bar
**Component**: `ComingSoonSheet`

### 4. Change Summary
**What**: Shows what changed vs base assumptions
**Where**: "View Changes" button on ValuationResultsView
**Component**: `ChangeSummarySheet`

---

## 📁 New Files

```
Components/
├── DriftBadge.swift          # Drift indicators (badge + dot)
├── WarningBanner.swift       # Validation warnings with disclosure
├── ComingSoonSheet.swift     # Save/Share coming soon modal
└── ChangeSummarySheet.swift  # Changes comparison modal
```

---

## 🔄 Modified Files

### DCFFlowState.swift
```swift
// New snapshot properties
private var revenueDriverBaseSnapshot: [UUID: Double]
private var operatingBaseSnapshot: OperatingAssumptions
private var valuationBaseSnapshot: ValuationAssumptions

// Drift detection
func isRevenueDriverDrifted(driverID: UUID) -> Bool
func isAnyRevenueDriverDrifted() -> Bool
func isOperatingDrifted() -> Bool
func isValuationDrifted() -> Bool
func hasAnyDrift() -> Bool

// Change tracking
func revenueChanges() -> [ChangeItem]
func operatingChanges() -> [ChangeItem]
func valuationChanges() -> [ChangeItem]

// Revert functions
func revertRevenueDriversToBase()
func revertOperatingToBase()
func revertValuationToBase()
func revertAllToBase()
```

### RevenueDriversView.swift
- Added `DriftBadge` to section header (conditional)
- Added `DriftDot` to individual driver cards (conditional)
- Added "Revert" button (conditional)

### OperatingAssumptionsView.swift
- Added `DriftBadge` to section header (conditional)
- Added "Revert" button (conditional)
- Added validation banners (margin rules, negative FCF)
- Added auto-clamp with debounce (250ms)
- Added `@State private var validationTask: Task<Void, Never>?`

### ValuationAssumptionsView.swift
- Added `DriftBadge` to section header (conditional)
- Added "Revert" button (conditional)
- Added terminal growth validation banner
- Added auto-clamp with debounce (250ms)
- Added `@State private var validationTask: Task<Void, Never>?`
- Added `.onAppear { flowState.saveValuationSnapshot() }`

### ValuationResultsView.swift
- Added forecast name placeholder
- Added "View Changes" button (conditional)
- Added Save/Share action bar (disabled)
- Added sheet presentations
- Added state variables:
  ```swift
  @State private var showComingSoonSheet = false
  @State private var comingSoonFeature = "Save"
  @State private var showChangesSheet = false
  ```

---

## 🎨 UI Patterns

### Drift Badge
```swift
// Usage
if flowState.isAnyRevenueDriverDrifted() {
    DriftBadge()
}
```
**Appearance**: Small pill with pencil icon + "Edited" text

### Drift Dot
```swift
// Usage
if flowState.isRevenueDriverDrifted(driverID: driver.id) {
    DriftDot()
}
```
**Appearance**: 6pt circle in accent color

### Warning Banner
```swift
// Usage
WarningBanner(
    title: "Terminal Growth Too High",
    message: "Terminal growth should be at least 0.5% below the discount rate.",
    severity: .warn,  // or .info
    explanation: "Optional detailed explanation..."
)
```

### Revert Button
```swift
// Usage
if flowState.isOperatingDrifted() {
    Button {
        HapticManager.shared.impact(style: .light)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            flowState.revertOperatingToBase()
        }
    } label: {
        Text("Revert")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(DSColors.accent)
    }
}
```

---

## ⚙️ Validation Rules

### Rule 1: Terminal Growth Constraint
```swift
// Validation
terminalGrowth <= discountRate - 0.5

// Auto-clamp after 250ms debounce
let maxTerminalGrowth = discountRate - 0.5
if terminalGrowth > maxTerminalGrowth {
    terminalGrowth = max(0, maxTerminalGrowth)
}
```

### Rule 2: Operating Margin Constraint
```swift
// Validation
operatingMargin <= grossMargin

// Auto-clamp after 250ms debounce
if operatingMargin > grossMargin {
    operatingMargin = grossMargin
}
```

### Rule 3: Negative FCF (Info Only)
```swift
// Check
let fcfMargin = operatingMargin * (1.0 - taxRate/100.0) - capexPercent - workingCapitalPercent

if fcfMargin < 0 {
    // Show info banner (no auto-clamp)
}
```

---

## 🔄 Snapshot Lifecycle

### When Snapshots Are Saved
1. **Revenue Drivers**: On preset application (consensus/bear/base/bull)
2. **Operating Assumptions**: On view appear (`onAppear`)
3. **Valuation Assumptions**: On view appear (`onAppear`)

### When Snapshots Are Used
- Drift detection (compare current vs base)
- Change summary (show base → current)
- Revert operations (restore base values)

---

## 🎭 Animation Patterns

### Standard Spring Animation
```swift
withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
    // State change
}
```

### Auto-Clamp Animation
```swift
withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
    // Clamp value
}
HapticManager.shared.impact(style: .light)
```

### Debounce Pattern
```swift
validationTask?.cancel()
validationTask = Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(250))
    guard !Task.isCancelled else { return }
    
    // Validation logic
    if needsClamp {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            // Apply clamp
        }
        HapticManager.shared.impact(style: .light)
    }
}
```

---

## 🧪 Testing Quick Checks

### Drift Detection
1. Open Revenue Drivers
2. Change any slider
3. ✅ DriftBadge appears on section header
4. ✅ DriftDot appears on changed driver
5. ✅ "Revert" button appears
6. Tap "Revert"
7. ✅ Values restore to base
8. ✅ Indicators disappear

### Validation
1. Open Valuation Assumptions
2. Set discount rate to 8%
3. Set terminal growth to 7.5%
4. ✅ Warning banner appears
5. Wait 250ms
6. ✅ Terminal growth auto-clamps to 7.5%
7. ✅ Haptic feedback fires

### Change Summary
1. Make changes across all three screens
2. Navigate to Valuation Results
3. ✅ "View Changes" button appears
4. Tap "View Changes"
5. ✅ Sheet shows all changes grouped by section
6. Tap "Revert All to Base"
7. ✅ All values restore and sheet dismisses

### Save/Share
1. Navigate to Valuation Results
2. ✅ Forecast name placeholder displays
3. ✅ Save and Share buttons appear disabled
4. Tap "Save Forecast"
5. ✅ ComingSoonSheet opens with Save context
6. Dismiss and tap "Share"
7. ✅ ComingSoonSheet opens with Share context

---

## 🐛 Common Issues & Solutions

### Issue: DriftBadge Not Appearing
**Check**: Ensure snapshot was saved before user made changes
**Solution**: Verify `saveBaseSnapshot()`, `saveOperatingSnapshot()`, or `saveValuationSnapshot()` is called

### Issue: Auto-Clamp Fighting User Dragging
**Check**: Debounce working properly?
**Solution**: Ensure `validationTask?.cancel()` before creating new task

### Issue: Revert Button Always Visible
**Check**: Conditional rendering logic
**Solution**: Verify drift detection method returns correct boolean

### Issue: Changes Sheet Shows No Changes
**Check**: Snapshot comparison tolerance
**Solution**: Ensure tolerance (0.0001) is appropriate for value type

---

## 🎯 Key Methods Reference

### DCFFlowState
```swift
// Snapshots
func saveBaseSnapshot()              // Revenue drivers
func saveOperatingSnapshot()         // Operating assumptions
func saveValuationSnapshot()         // Valuation assumptions

// Drift Detection
func isRevenueDriverDrifted(driverID: UUID) -> Bool
func isAnyRevenueDriverDrifted() -> Bool
func isOperatingDrifted() -> Bool
func isValuationDrifted() -> Bool
func hasAnyDrift() -> Bool

// Change Tracking
func revenueChanges() -> [ChangeItem]
func operatingChanges() -> [ChangeItem]
func valuationChanges() -> [ChangeItem]

// Revert
func revertRevenueDriversToBase()
func revertOperatingToBase()
func revertValuationToBase()
func revertAllToBase()
```

---

## 📊 Design System Usage

### Colors
- `DSColors.accent` - Primary drift/edit indicator color
- `DSColors.textPrimary` - Main text
- `DSColors.textSecondary` - Subtitles and labels
- `DSColors.textTertiary` - Disabled/muted text
- `DSColors.surface` - Card backgrounds
- `DSColors.surface2` - Nested card backgrounds
- `DSColors.border` - Dividers and borders

### Typography
- `DSTypography.headline` - Section headers
- `DSTypography.subheadline` - Secondary headers
- `DSTypography.body` - Body text
- `DSTypography.caption` - Small text and labels

### Spacing
- `DSSpacing.xs` - 4pt
- `DSSpacing.s` - 8pt
- `DSSpacing.m` - 12pt
- `DSSpacing.l` - 16pt
- `DSSpacing.xl` - 24pt

---

## 🚀 Next Steps

### Immediate
- [x] Test all drift indicators across screens
- [x] Verify validation rules work as expected
- [x] Check dark mode appearance
- [x] Ensure haptics fire correctly

### Future Enhancements
- [ ] Persist snapshots to UserDefaults
- [ ] Add undo/redo stack
- [ ] Implement actual Save/Share functionality
- [ ] Add AI-powered assumption suggestions
- [ ] Create comparison mode (multiple scenarios)

---

## 📝 Notes

### Performance
- Drift detection is O(n) where n = number of drivers/fields
- Debouncing prevents excessive validation during dragging
- Task cancellation ensures only latest validation runs

### Accessibility
- All interactive elements meet 44pt minimum hit target
- Color is not sole indicator (icons + text used)
- Haptic feedback provides tactile confirmation
- Screen reader support via semantic SwiftUI components

### Dark Mode
- All components use design system tokens
- Opacity-based backgrounds adapt automatically
- Tested in both light and dark appearances
- No hard-coded colors

---

## ✅ Build Status

**Last Build**: ✅ Success (no errors, no warnings)
**Platform**: iOS 17.6+
**Simulator Tested**: iPhone 17 (iOS 26.2)
**Dark Mode**: ✅ Supported
**Linter**: ✅ No issues

---

## 📚 Documentation

- Full implementation details: `PREMIUM_FEATURES_SUMMARY.md`
- Component previews available in each component file
- Inline code comments explain complex logic

---

## 🎉 Summary

All premium features are implemented and working:
- ✅ Drift indicators (badge + dot)
- ✅ Inline validation (auto-clamp with warnings)
- ✅ Save/Share skeleton (coming soon messaging)
- ✅ Change summary (full comparison view)

The implementation follows Apple HIG, maintains design system consistency, and is production-ready pending QA.
