# Build Requirements & Environment

## Build Environment

**Xcode Version:** 26.2 (Swift 5.9+)
**Minimum iOS Version:** 17.6
**Platform:** iOS / iPadOS
**Architecture:** arm64 (Apple Silicon)

## Build Command

```bash
xcodebuild -scheme "Investor Tool" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

## Verification Script

A build verification script is provided to check for common issues before building:

```bash
./scripts/verify_build.sh
```

This script:
1. Checks for missing `import Combine` statements in files using `@Published`
2. Warns about potential `@ObservedObject` usage with SwiftData `@Model` classes
3. Runs a full clean build

## Common Build Issues & Solutions

### 1. Missing Combine Framework Import

**Error:**
```
error: static subscript 'subscript(_enclosingInstance:wrapped:storage:)' is not available 
due to missing import of defining module 'Combine'
```

**Solution:** Add `import Combine` to any file that uses:
- `@Published` property wrapper
- `ObservableObject` protocol
- `objectWillChange.send()`

**Files Fixed:**
- `Core/Services/AssumptionTemplateStore.swift`
- `Features/Assumptions/AssumptionsTemplateViewModel.swift`

### 2. SwiftData @Model with @ObservedObject

**Error:**
```
error: generic struct 'ObservedObject' requires that 'AssumptionItem' conform to 'ObservableObject'
```

**Solution:** SwiftData `@Model` classes should use `@Bindable` instead of `@ObservedObject` in SwiftUI views.

**Example:**
```swift
// ❌ Wrong
struct MyView: View {
    @ObservedObject var item: MyModelClass
}

// ✅ Correct
struct MyView: View {
    @Bindable var item: MyModelClass
}
```

**Files Fixed:**
- `Features/Assumptions/AssumptionRowView.swift` (2 occurrences)

### 3. Missing Design System Tokens

**Error:**
```
error: type 'DSColors' has no member 'surfaceSecondary'
error: type 'DSColors' has no member 'textTertiary'
error: type 'DSSpacing' has no member 'xxs'
error: type 'DSTypography' has no member 'title3'
```

**Solution:** Add missing design system constants.

**Files Fixed:**
- `DesignSystem/DSColors.swift` - Added `textTertiary` and `surfaceSecondary`
- `DesignSystem/DSSpacing.swift` - Added `xxs` spacing (2pt)
- `DesignSystem/DSTypography.swift` - Added `title3` font style

## Code Quality Gates

To prevent these issues from recurring:

### Pre-Commit Checks
1. Run `./scripts/verify_build.sh` before committing
2. Ensure all SwiftUI `@Published` properties are in classes with `import Combine`
3. Use `@Bindable` for SwiftData `@Model` objects in views

### CI/CD Integration
Add this to your CI pipeline:
```yaml
- name: Build iOS App
  run: |
    xcodebuild -scheme "Investor Tool" \
      -sdk iphonesimulator \
      -destination 'platform=iOS Simulator,OS=latest,name=iPhone 17 Pro' \
      clean build
```

## Architecture Notes

### State Management
- **ObservableObject + Combine**: Used for ViewModels and service classes
- **SwiftData @Model**: Used for persisted data models
- **@Bindable**: Used in views for two-way binding with SwiftData models
- **@Published**: Requires `import Combine`

### Design System
All UI components use the centralized design system:
- **DSColors**: Color palette (dark theme optimized)
- **DSSpacing**: Consistent spacing values and corner radii
- **DSTypography**: Font styles and text modifiers

## Troubleshooting

### Build fails with "missing import"
- Check if the file uses `@Published` and add `import Combine`
- Run `./scripts/verify_build.sh` to find all occurrences

### Type conformance errors with ObservableObject
- Check if the class is a SwiftData `@Model`
- If yes, use `@Bindable` in views instead of `@ObservedObject`

### Design system member not found
- Check if the token exists in the design system files
- Add the missing token following the existing naming convention
- Keep the design system minimal and consistent

## Summary of Fixes Applied

| Issue | Root Cause | Fix | Files Affected |
|-------|-----------|-----|----------------|
| Combine framework missing | `@Published` used without import | Added `import Combine` | 2 files |
| SwiftData binding error | `@ObservedObject` used with `@Model` | Changed to `@Bindable` | 1 file (2 locations) |
| Missing color tokens | Incomplete design system | Added missing colors | DSColors.swift |
| Missing spacing token | Incomplete design system | Added `xxs: 2` | DSSpacing.swift |
| Missing typography | Incomplete design system | Added `title3` | DSTypography.swift |

**Result:** ✅ Clean build with zero errors
