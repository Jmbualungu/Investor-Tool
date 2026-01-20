# Disclaimer Implementation Test Plan

## Pre-Testing Setup

### Reset App State
To properly test the disclaimer flow, you'll need to start with a fresh state:

**Option 1: Delete and Reinstall**
1. Delete app from simulator/device
2. Run app from Xcode

**Option 2: Reset UserDefaults (Debug Only)**
1. Add debug button to reset flags:
```swift
UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
UserDefaults.standard.removeObject(forKey: "hasAcceptedFinancialDisclaimer")
```

**Option 3: Reset Simulator**
1. iOS Simulator → Device → Erase All Content and Settings

## Test Scenarios

### Scenario 1: First Launch (Fresh Install)
**Expected Behavior:** Disclaimer shows as the very first screen

**Steps:**
1. Launch app for the first time
2. Verify onboarding appears (full-screen overlay)
3. Verify disclaimer is the first screen (page 0)
4. Verify page indicator shows 4 dots (disclaimer + 3 content pages)

**Validation Points:**
- ✅ Shield icon with "Important Disclosure" title visible
- ✅ Disclaimer text is scrollable
- ✅ Checkbox is unchecked by default
- ✅ "Accept & Continue" button is disabled (opacity 0.5)
- ✅ Microcopy "This helps us keep ForecastAI transparent and responsible." visible
- ✅ No "Skip" button on disclaimer page
- ✅ No "Back" button on disclaimer page
- ✅ Progress dots show page 1 of 4

---

### Scenario 2: User Interaction Flow
**Expected Behavior:** User must check box and accept to proceed

**Steps:**
1. Try tapping "Accept & Continue" without checking box
   - **Expected:** Button does nothing (disabled)
2. Scroll through disclaimer text
   - **Expected:** Smooth scrolling, text is readable
3. Tap checkbox to check it
   - **Expected:** 
     - Checkbox shows checkmark
     - Haptic feedback
     - Button becomes enabled (opacity 1.0)
4. Tap "Accept & Continue"
   - **Expected:**
     - Haptic feedback (medium impact)
     - Smooth transition to page 1 (Build a Forecast)
     - Progress dots update to show page 2 of 4
     - "Skip" button appears at top right
     - Bottom navigation controls appear

**Validation Points:**
- ✅ Cannot proceed without checking checkbox
- ✅ Checkbox toggles correctly
- ✅ Button state updates correctly
- ✅ Transition animation is smooth
- ✅ Next page loads correctly

---

### Scenario 3: Completing Onboarding
**Expected Behavior:** After accepting disclaimer, user can complete onboarding normally

**Steps:**
1. Accept disclaimer (from Scenario 2)
2. Navigate through onboarding pages using "Next" button
   - Page 1: Build a Forecast
   - Page 2: Control the Drivers
   - Page 3: See the Range
3. On page 3, tap "Start" button
4. Verify onboarding dismisses and user lands on main app

**Validation Points:**
- ✅ Can navigate forward through pages
- ✅ Can navigate backward (page 3 → 2, page 2 → 1)
- ✅ Cannot navigate back from page 1 to disclaimer
- ✅ "Skip" button works on any content page
- ✅ "Start" button on final page completes onboarding
- ✅ Onboarding dismisses with smooth animation

---

### Scenario 4: Subsequent App Launch (Disclaimer Accepted)
**Expected Behavior:** Disclaimer does not show again

**Steps:**
1. Close and relaunch app
2. If onboarding would show for any reason, verify it starts at page 1 (not page 0)

**Validation Points:**
- ✅ `hasAcceptedFinancialDisclaimer == true` persists
- ✅ Onboarding shows page 1 as first page (page 0 skipped)
- ✅ User is not asked to accept disclaimer again

---

### Scenario 5: Data Reset
**Expected Behavior:** Clearing app data re-shows disclaimer

**Steps:**
1. Delete app from device/simulator
2. Reinstall and launch
3. Verify disclaimer shows again as first screen

**Validation Points:**
- ✅ UserDefaults flags are cleared
- ✅ Disclaimer shows again
- ✅ Must accept again to proceed

---

### Scenario 6: Navigation Edge Cases

**Test 6a: Skip from Content Page**
1. Accept disclaimer, advance to page 1
2. Tap "Skip" button
3. Verify onboarding dismisses correctly

**Validation Points:**
- ✅ Skip works from any content page
- ✅ `hasSeenOnboarding` is set to true
- ✅ `hasAcceptedFinancialDisclaimer` remains true

**Test 6b: Back Navigation**
1. Accept disclaimer, advance to page 1
2. Verify no back button on page 1
3. Tap "Next" to page 2
4. Tap "Back" button
5. Verify returns to page 1 (not disclaimer)

**Validation Points:**
- ✅ Cannot navigate back to disclaimer after accepting
- ✅ Back button only appears from page 2 onwards

**Test 6c: Swipe Gestures (if applicable)**
1. Accept disclaimer
2. Try swiping left/right on pages
3. Verify swipe behavior matches button navigation

**Validation Points:**
- ✅ Swipe forward works correctly
- ✅ Cannot swipe back to disclaimer from page 1

---

### Scenario 7: UI/Layout Testing

**Test 7a: Different Device Sizes**
Test on:
- iPhone SE (small screen)
- iPhone 15 Pro (standard)
- iPhone 15 Pro Max (large)
- iPad (if supported)

**Validation Points:**
- ✅ Text is readable on all sizes
- ✅ Scrollable content works on small screens
- ✅ Button and checkbox are properly sized
- ✅ Safe areas respected
- ✅ No clipping or overflow

**Test 7b: Dynamic Type**
1. Settings → Accessibility → Display & Text Size → Larger Text
2. Increase text size to maximum
3. Launch app and verify disclaimer

**Validation Points:**
- ✅ Text scales correctly
- ✅ Layout adapts to larger text
- ✅ No text truncation
- ✅ Scrolling still works

**Test 7c: Dark Mode**
1. Enable Dark Mode
2. Launch app and verify disclaimer

**Validation Points:**
- ✅ All colors adapt correctly
- ✅ Text is readable
- ✅ Contrast is sufficient
- ✅ Design looks polished

**Test 7d: Orientation (iPhone)**
1. Rotate device while on disclaimer
2. Verify layout adapts

**Validation Points:**
- ✅ No layout breaks
- ✅ State is preserved
- ✅ Checkbox state maintained

---

### Scenario 8: Persistence Validation

**Test 8a: Background/Foreground**
1. On disclaimer page, check checkbox
2. Background app (home button/swipe)
3. Return to app
4. Verify checkbox is still checked

**Validation Points:**
- ✅ UI state preserved during backgrounding
- ✅ No state loss

**Test 8b: Force Quit**
1. On disclaimer page, check checkbox
2. Force quit app (swipe up from app switcher)
3. Relaunch app
4. Verify disclaimer shows again with unchecked checkbox

**Validation Points:**
- ✅ Acceptance only persists after tapping "Accept & Continue"
- ✅ Checkbox state is not persisted (by design)

---

### Scenario 9: Integration with Main App Flow

**Test 9a: App Router Integration**
1. Complete onboarding (including disclaimer)
2. Tap "Start Forecasting" on landing screen
3. Verify navigation to DCF ticker search

**Validation Points:**
- ✅ AppRouter checks `disclaimerManager.hasAccepted`
- ✅ Navigation proceeds normally
- ✅ No blocking or errors

**Test 9b: Bypass Attempt**
1. Without accepting disclaimer, try to access main features
2. Verify user is blocked

**Validation Points:**
- ✅ Cannot bypass disclaimer
- ✅ App properly gates features

---

### Scenario 10: Error Handling

**Test 10a: Rapid Interactions**
1. Rapidly tap checkbox multiple times
2. Rapidly tap "Accept & Continue"

**Validation Points:**
- ✅ No crashes
- ✅ State updates correctly
- ✅ Only one navigation event fires

**Test 10b: Memory Pressure**
1. Run under memory constraints
2. Navigate through disclaimer

**Validation Points:**
- ✅ No memory leaks
- ✅ Views are properly deallocated

---

## Automated Testing Suggestions

### Unit Tests
```swift
import XCTest
@testable import Investor_Tool

class DisclaimerManagerTests: XCTestCase {
    var disclaimerManager: DisclaimerManager!
    
    override func setUp() {
        super.setUp()
        disclaimerManager = DisclaimerManager()
        disclaimerManager.reset() // Start fresh
    }
    
    func testInitialState() {
        XCTAssertFalse(disclaimerManager.hasAccepted)
    }
    
    func testAcceptance() {
        disclaimerManager.accept()
        XCTAssertTrue(disclaimerManager.hasAccepted)
    }
    
    func testPersistence() {
        disclaimerManager.accept()
        
        // Create new instance
        let newManager = DisclaimerManager()
        XCTAssertTrue(newManager.hasAccepted)
    }
    
    func testReset() {
        disclaimerManager.accept()
        disclaimerManager.reset()
        XCTAssertFalse(disclaimerManager.hasAccepted)
    }
}
```

### UI Tests
```swift
func testDisclaimerFlow() {
    let app = XCUIApplication()
    app.launch()
    
    // Verify disclaimer is first screen
    XCTAssertTrue(app.staticTexts["Important Disclosure"].exists)
    
    // Verify button is disabled
    let continueButton = app.buttons["Accept & Continue"]
    XCTAssertFalse(continueButton.isEnabled)
    
    // Check checkbox
    app.images["square"].tap()
    
    // Verify button is enabled
    XCTAssertTrue(continueButton.isEnabled)
    
    // Tap continue
    continueButton.tap()
    
    // Verify next page loads
    XCTAssertTrue(app.staticTexts["Build a Forecast"].exists)
}
```

---

## Success Criteria

All tests must pass with the following criteria:
- ✅ No crashes
- ✅ No UI glitches
- ✅ No console errors or warnings
- ✅ Smooth animations
- ✅ Correct state management
- ✅ Proper persistence
- ✅ Accessibility compliant
- ✅ Works on all supported devices and orientations

---

## Known Limitations / Future Enhancements

1. **Analytics:** Consider adding analytics to track disclaimer acceptance rate
2. **Localization:** Disclaimer text is hardcoded (English only)
3. **Version Tracking:** No tracking of which version of disclaimer was accepted
4. **Backend Sync:** Currently local-only (could sync to backend in future)
5. **Legal Updates:** No mechanism to force re-acceptance if legal copy changes

---

## Sign-off

- [ ] All test scenarios passed
- [ ] No regressions found
- [ ] Accessibility verified
- [ ] Performance acceptable
- [ ] Code review completed
- [ ] Ready for production

**Tested by:** _________________

**Date:** _________________

**Build Version:** _________________

**Notes:**
