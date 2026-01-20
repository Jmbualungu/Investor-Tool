# Onboarding Test Plan

## Quick Start Testing

### Initial Setup
1. Open Xcode
2. Select "Investor Tool" scheme
3. Choose iOS Simulator (any iPhone model) or physical device
4. Build and run (⌘R)

### Reset Onboarding State
Before each test, reset onboarding:
1. Launch app
2. Tap the Debug HUD (top-left corner with build stamp)
3. Tap "Reset" button
4. App should show onboarding again

## Test Cases

### TC1: Skip Button Flow
**Steps:**
1. Launch app (first time or after reset)
2. Tap "Skip" button (top-right)

**Expected:**
- ✅ Haptic feedback (light)
- ✅ App transitions to AppShellView
- ✅ Forecast tab is selected by default
- ✅ `hasSeenOnboarding` is set to true

### TC2: Complete Onboarding Flow (Page 1 → 2 → 3)
**Steps:**
1. Launch app (first time or after reset)
2. Verify you're on Page 1 (Build a Forecast)
3. Tap "Next" button
4. Verify you're on Page 2 (Control the Drivers)
5. Tap "Next" button
6. Verify you're on Page 3 (See the Range)
7. Tap "Start" button

**Expected:**
- ✅ Each "Next" tap triggers light haptic
- ✅ Smooth page transitions with animation
- ✅ Page indicator updates (dot fills in)
- ✅ "Start" tap triggers medium haptic
- ✅ App transitions to AppShellView
- ✅ `hasSeenOnboarding` is set to true

### TC3: Back Button Flow
**Steps:**
1. Launch app (first time or after reset)
2. Tap "Next" to go to Page 2
3. Verify "Back" button appears
4. Tap "Back"
5. Verify you're back on Page 1
6. Verify "Back" button is hidden

**Expected:**
- ✅ "Back" button only shows on pages 2-3
- ✅ Back navigation works smoothly
- ✅ Light haptic on Back tap
- ✅ Page indicator updates correctly

### TC4: Swipe Gestures
**Steps:**
1. Launch app (first time or after reset)
2. Swipe left to go to Page 2
3. Swipe left to go to Page 3
4. Swipe right to go to Page 2
5. Swipe right to go to Page 1

**Expected:**
- ✅ Swipe gestures work on all pages
- ✅ Page indicator updates with swipes
- ✅ Buttons update correctly (Back/Next/Start)
- ✅ Smooth transitions

### TC5: Quote Display
**Steps:**
1. Launch app (first time or after reset)
2. Verify Page 1 shows Buffett quote: "Risk comes from not knowing what you're doing."
3. Go to Page 2
4. Verify Page 2 shows Munger quote: "The big money is not in the buying and selling, but in the waiting."
5. Go to Page 3
6. Verify Page 3 shows Marks quote: "The most important thing is to keep the most important thing the most important thing."

**Expected:**
- ✅ Quotes render without truncation
- ✅ Quote cards have glass morphism effect
- ✅ Author attribution shows correctly
- ✅ Quote icon visible (subtle accent color)

### TC6: Button State Management
**Steps:**
1. Launch app
2. Page 1: Verify "Next" button present, no "Back" button
3. Page 2: Verify both "Back" and "Next" buttons present
4. Page 3: Verify "Back" and "Start" buttons present (no "Next")

**Expected:**
- ✅ Correct buttons show on each page
- ✅ Transitions are smooth when buttons appear/disappear
- ✅ All buttons are tappable

### TC7: Dark Mode
**Steps:**
1. Enable Dark Mode in iOS Settings or Control Center
2. Launch app (first time or after reset)
3. Go through all pages

**Expected:**
- ✅ Background gradient adapts to dark mode
- ✅ Text is readable (proper contrast)
- ✅ Quote cards look good in dark mode
- ✅ Buttons have proper styling

### TC8: Light Mode
**Steps:**
1. Enable Light Mode in iOS Settings or Control Center
2. Launch app (first time or after reset)
3. Go through all pages

**Expected:**
- ✅ Background gradient adapts to light mode
- ✅ Text is readable (proper contrast)
- ✅ Quote cards look good in light mode
- ✅ Buttons have proper styling

### TC9: Reduce Motion
**Steps:**
1. Enable Reduce Motion: Settings → Accessibility → Motion → Reduce Motion
2. Launch app (first time or after reset)
3. Navigate through pages

**Expected:**
- ✅ Page transitions still work
- ✅ No jarring animations
- ✅ Buttons work correctly

### TC10: Physical Device
**Steps:**
1. Connect physical iPhone
2. Build and run on device
3. Go through complete onboarding flow

**Expected:**
- ✅ All gestures work
- ✅ Haptic feedback works
- ✅ Performance is smooth
- ✅ Transitions to AppShellView correctly

### TC11: Returning User
**Steps:**
1. Complete onboarding (reach AppShellView)
2. Force quit app
3. Relaunch app

**Expected:**
- ✅ App goes directly to AppShellView
- ✅ Onboarding does not show
- ✅ Forecast tab is selected

### TC12: Debug Reset
**Steps:**
1. Complete onboarding
2. Tap Debug HUD (top-left)
3. Tap "Reset"

**Expected:**
- ✅ Onboarding shows again
- ✅ `hasSeenOnboarding` is false
- ✅ Can complete onboarding again

## Visual Checks

### Page 1: Build a Forecast
- [ ] Icon: Chart line uptrend (accent color circle background)
- [ ] Title: "Build a Forecast" (large bold)
- [ ] Subtitle: "Understand value, not just price."
- [ ] Body text: DCF model explanation
- [ ] Quote card: Buffett quote with icon
- [ ] Skip button: Top-right
- [ ] Next button: Bottom, primary style

### Page 2: Control the Drivers
- [ ] Title: "Control the Drivers" (large bold)
- [ ] Subtitle: "Change assumptions and see valuation update instantly."
- [ ] 3 rows with icons: Revenue Growth, Operating Margins, Valuation Multiples
- [ ] Quote card: Munger quote with icon
- [ ] Skip button: Top-right
- [ ] Back button: Bottom-left, secondary style
- [ ] Next button: Bottom-right, primary style

### Page 3: See the Range
- [ ] Title: "See the Range" (large bold)
- [ ] Subtitle: "Explore scenarios and understand what matters most."
- [ ] 3 feature highlights: Scenarios, Sensitivity, Save/Share
- [ ] Quote card: Marks quote with icon
- [ ] Skip button: Top-right
- [ ] Back button: Bottom-left, secondary style
- [ ] Start button: Bottom-right, primary style with shimmer

## Performance Checks

- [ ] No lag when swiping between pages
- [ ] Smooth button transitions
- [ ] Instant haptic feedback
- [ ] Quick transition to AppShellView
- [ ] No memory issues

## Accessibility Checks

- [ ] VoiceOver reads all content correctly
- [ ] Buttons have proper accessibility labels
- [ ] Page indicator is accessible
- [ ] Dynamic Type scales text properly
- [ ] Works with Reduce Motion enabled

## Edge Cases

### EC1: Rapid Button Tapping
**Steps:** Tap Next/Back rapidly
**Expected:** No crashes, smooth handling

### EC2: Swipe During Transition
**Steps:** Swipe while page is animating
**Expected:** Handles gracefully, no broken state

### EC3: Rotation (iPad)
**Steps:** Rotate device during onboarding
**Expected:** Layout adapts correctly

## Sign-Off Checklist

Before considering this feature complete, verify:

- [ ] All buttons work (Skip, Back, Next, Start)
- [ ] Routing is correct (onboarding → AppShellView)
- [ ] Quotes display tastefully on all pages
- [ ] Haptic feedback works
- [ ] Compiles without errors
- [ ] Works on Simulator
- [ ] Works on physical device
- [ ] No external APIs used
- [ ] Light mode looks good
- [ ] Dark mode looks good
- [ ] Reduce Motion works
- [ ] Background doesn't block gestures
- [ ] Page indicator updates correctly
- [ ] No black screens or broken states

## Known Issues

None at this time.

## Future Enhancements

1. Add onboarding analytics
2. A/B test different quote sets
3. Add subtle parallax effects
4. Prepare for localization
5. Add skip animation variant
