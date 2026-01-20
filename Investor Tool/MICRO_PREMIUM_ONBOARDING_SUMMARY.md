# Micro-Premium Onboarding Upgrades

## Summary

Added two subtle, premium micro-interactions to the first-launch onboarding experience:
1. **Parallax Title Effect** - Titles subtly animate with 2-4px offset on page change
2. **Button Shimmer Effect** - Primary CTA buttons show a gentle shine highlight

## Files Created

### 1. ParallaxTitle.swift
- **Location**: `Features/Onboarding/ParallaxTitle.swift`
- **Purpose**: Reusable component for onboarding page titles with subtle parallax animation
- **Behavior**:
  - Animates title and subtitle with 2-4px horizontal offset on page change
  - Offset direction alternates by page index (left/right)
  - Includes opacity transition (0.92 → 1.0 for title, 0.88 → 1.0 for subtitle)
  - Animation duration: 0.35s with easeOut timing
  - Respects Reduce Motion accessibility setting (no animation when enabled)
  - Re-triggers animation on page change with 50ms delay

### 2. ShimmerButtonOverlay.swift
- **Location**: `Features/Onboarding/ShimmerButtonOverlay.swift`
- **Purpose**: View modifier that adds a subtle shine effect to buttons
- **Behavior**:
  - Diagonal gradient band (20° rotation) sweeps across button
  - Very low opacity (0.12 max) for subtlety
  - Single-pass animation on appear (1.2s duration, 0.3s initial delay)
  - Uses easeInOut timing
  - Respects Reduce Motion accessibility setting (disabled when enabled)
  - `allowsHitTesting(false)` to prevent interaction blocking
  - Properly clips to button's pill-shaped corner radius

## Files Modified

### FirstLaunchOnboardingView.swift
- **Location**: `Features/Onboarding/FirstLaunchOnboardingView.swift`

#### Changes to Page Titles:
- **Page 1**: Replaced title Text with `ParallaxTitle(title: "Build a Forecast", subtitle: nil, pageIndex: currentPage)`
- **Page 2**: Replaced title/subtitle with `ParallaxTitle(title: "Control the Drivers", subtitle: "Change assumptions...", pageIndex: currentPage)`
- **Page 3**: Replaced title/subtitle with `ParallaxTitle(title: "See the Range", subtitle: "Explore scenarios...", pageIndex: currentPage)`, preserving long-press gesture

#### Changes to Buttons:
- **Next Button** (pages 0-1): Added `.shimmerOverlay(enabled: true)` modifier
- **Start Button** (page 2): Added `.shimmerOverlay(enabled: true)` modifier

## Technical Details

### Reduce Motion Compliance
Both features fully respect `UIAccessibility.isReduceMotionEnabled`:
- **ParallaxTitle**: Returns static offsets (0) and full opacity when reduce motion is enabled
- **ShimmerButtonOverlay**: Returns empty overlay (no shimmer) when reduce motion is enabled

### Animation Performance
- All animations use `.easeOut` or `.easeInOut` timing for smooth, natural motion
- No continuous loops or heavy effects that could impact battery/performance
- Parallax offsets are minimal (2-4px) to avoid jarring motion
- Shimmer uses low opacity (max 0.12) to stay subtle

### Layout Safety
- Background elements use `.allowsHitTesting(false)` to prevent gesture conflicts
- Shimmer overlay uses `.allowsHitTesting(false)` to not block button taps
- No changes to TabView gesture handling (swipe paging still works perfectly)
- Preserved all existing transitions and button behaviors

### Accessibility
- Reduce Motion support ensures users with motion sensitivity are not affected
- No changes to button hit targets or interaction patterns
- Text remains fully readable with VoiceOver (animations are visual only)

## Testing Checklist

- [x] No compilation errors
- [x] No linter errors
- [ ] Titles animate subtly on page swipe
- [ ] Button shimmer appears once on button appearance
- [ ] Reduce Motion disables both effects
- [ ] Swiping between pages works smoothly
- [ ] Next/Start buttons work correctly
- [ ] Skip button still works
- [ ] Back button still works
- [ ] Long-press on page 3 title still toggles marketing mode
- [ ] No layout shifts or clipped content
- [ ] Works on simulator
- [ ] Works on physical device

## QA Notes

### Expected Behavior:
1. **On First Launch**:
   - Page 1 title "Build a Forecast" fades in with slight right offset (4px)
   - Next button shows a gentle diagonal shimmer ~0.5s after appearing

2. **Swiping to Page 2**:
   - Title "Control the Drivers" and subtitle fade in with left offset (-4px for title, -2px for subtitle)
   - Next button is already visible, shimmer doesn't retrigger (by design)

3. **Swiping to Page 3**:
   - Title "See the Range" and subtitle fade in with right offset (4px for title, 2px for subtitle)
   - Start button appears with shimmer effect

4. **Swiping Back**:
   - Titles re-animate on page change
   - Buttons maintain state (shimmer doesn't retrigger on existing buttons)

### With Reduce Motion Enabled:
- Titles appear instantly with no offset or opacity animation
- No shimmer effect on buttons
- All other functionality remains identical

## Design Rationale

These micro-interactions add perceived quality without being distracting:
- **Parallax titles**: Creates a sense of depth and polish during page transitions
- **Button shimmer**: Draws subtle attention to the primary CTA, encouraging progression
- Both effects are "one-shot" (not looping), avoiding fatigue
- Very low motion amounts (2-4px, 0.12 opacity) ensure subtlety
- Accessibility-first design with Reduce Motion support

## Future Enhancements (Not Implemented)

Potential future additions if desired:
1. Shimmer could retrigger when Next button content changes (currently doesn't)
2. Could add a subtle scale bounce to icons on page appear
3. Could sync parallax to drag gesture offset (complex, may impact performance)
4. Could add a fade-through transition to progress dots
