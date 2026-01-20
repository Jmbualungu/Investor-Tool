# Setup Guide: Assumptions Template Module

## Overview

This guide explains how to add the new Assumptions Template module files to your Xcode project.

## Files Created

The following files have been created and need to be added to the Xcode project:

### Core/Models/
- `AssumptionTemplate.swift` - Data models for templates and items

### Core/Services/
- `AssumptionTemplateStore.swift` - Storage service with seed data
- `ForecastPreviewEngine.swift` - Preview calculator

### Features/Assumptions/
- `HorizonSelectorView.swift` - Horizon picker component
- `AssumptionRowView.swift` - Slider-first row editor
- `AssumptionsTemplateView.swift` - Main template editor view
- `AssumptionsTemplateViewModel.swift` - View model for template editor

### Documentation/
- `README_Assumptions.md` - Architecture documentation

## Adding Files to Xcode Project

### Method 1: Via Xcode (Recommended)

1. **Open the project in Xcode**
   ```bash
   open "Investor Tool.xcodeproj"
   ```

2. **Add Model files**
   - Right-click on `Investor Tool/Core/Models/` folder in Xcode
   - Select "Add Files to 'Investor Tool'..."
   - Navigate to and select `AssumptionTemplate.swift`
   - Ensure "Copy items if needed" is UNCHECKED (file is already in place)
   - Ensure "Investor Tool" target is checked
   - Click "Add"

3. **Add Service files**
   - Right-click on `Investor Tool/Core/Services/` folder
   - Add both:
     - `AssumptionTemplateStore.swift`
     - `ForecastPreviewEngine.swift`

4. **Add Feature files**
   - Right-click on `Investor Tool/Features/Assumptions/` folder
   - Add all four:
     - `HorizonSelectorView.swift`
     - `AssumptionRowView.swift`
     - `AssumptionsTemplateView.swift`
     - `AssumptionsTemplateViewModel.swift`

### Method 2: Via Terminal (Alternative)

If you prefer command-line, you can use:

```bash
cd "/Users/jamesmbualungu/Desktop/Coding/Investor Tool"

# This will add files to git, and Xcode will auto-detect them on next open
git add "Investor Tool/Core/Models/AssumptionTemplate.swift"
git add "Investor Tool/Core/Services/AssumptionTemplateStore.swift"
git add "Investor Tool/Core/Services/ForecastPreviewEngine.swift"
git add "Investor Tool/Features/Assumptions/HorizonSelectorView.swift"
git add "Investor Tool/Features/Assumptions/AssumptionRowView.swift"
git add "Investor Tool/Features/Assumptions/AssumptionsTemplateView.swift"
git add "Investor Tool/Features/Assumptions/AssumptionsTemplateViewModel.swift"
git add "README_Assumptions.md"
```

Then reopen Xcode and manually add the files using Method 1.

## Verifying the Setup

1. **Build the project** (Cmd+B)
   - Should compile without errors
   - SwiftData models will be registered in `ForecastAIApp.swift`

2. **Run on simulator or device**
   - Navigate to Settings (from LandingView)
   - Tap "Assumptions Templates"
   - Select an entity (e.g., "Apple")
   - Adjust assumptions via sliders
   - View preview impact at bottom

3. **Check data persistence**
   - Close and reopen app
   - Navigate back to Assumptions Templates
   - Changes should be persisted

## Troubleshooting

### "Cannot find type 'EntityAssumptionsTemplate' in scope"
- Ensure `AssumptionTemplate.swift` is added to the Xcode project
- Clean build folder (Cmd+Shift+K) and rebuild

### "No such module 'SwiftData'"
- Ensure deployment target is iOS 17.0+
- Check in project settings: General > Deployment Info > Minimum Deployments

### "Model context not found"
- Ensure `ForecastAIApp.swift` includes the new models in `.modelContainer(for: [...])`
- This should already be done in the updated file

### Templates not showing data
- The seed happens on first launch
- If empty, check console for errors
- Force delete app and reinstall to trigger re-seed

### Slider not updating preview
- Check that `handleItemUpdate()` is being called
- Verify `ForecastPreviewEngine` is calculating correctly
- Look for console warnings

## Testing the Module

### Quick Test Checklist

- [ ] App builds successfully
- [ ] Can navigate to Assumptions Templates from Settings
- [ ] Entity picker shows all 6 entities
- [ ] Horizon selector shows 1Y/3Y/5Y/10Y
- [ ] Key assumptions section shows top items
- [ ] All sections are collapsible
- [ ] Sliders update values smoothly
- [ ] Preview panel updates when sliders change
- [ ] Info button shows assumption details
- [ ] Reset button restores template defaults
- [ ] Data persists across app restarts

### Sample Test Flow

1. Launch app → accept disclaimer → navigate to Settings
2. Tap "Assumptions Templates"
3. Select "Apple" entity
4. Select "5Y" horizon
5. Find "Revenue Growth" slider
6. Adjust from 8% to 15%
7. Observe "Implied Total Return" in preview update
8. Tap info button on "Revenue Growth"
9. Verify detail sheet shows metadata
10. Tap "Reset to Template"
11. Verify slider returns to original 8%

## Next Steps

After successful setup:

1. **Review README_Assumptions.md** for architecture details
2. **Customize seed data** if needed (edit `AssumptionTemplateStore.swift`)
3. **Add more entities** by extending the store
4. **Integrate with ticker system** when ready for real market data

## Notes

- This module is **local-first** with no network dependencies
- All data is **sample/illustrative** - not real market data
- Template system is designed for **future ticker mapping**
- Preview calculator is **simplified** - not a full DCF model

---

**Status**: Files created, ready to add to Xcode project  
**Estimated setup time**: 5-10 minutes  
**Support**: See README_Assumptions.md for detailed architecture
