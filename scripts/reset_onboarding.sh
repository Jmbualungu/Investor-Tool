#!/bin/bash
#
# Reset onboarding state for testing
# Usage: ./scripts/reset_onboarding.sh
#

BUNDLE_ID="com.example.ForecastAI"

echo "🔄 Resetting onboarding state for $BUNDLE_ID..."

# Delete the hasSeenOnboarding key from UserDefaults
xcrun simctl spawn booted defaults delete "$BUNDLE_ID" hasSeenOnboarding 2>/dev/null || echo "Key not found or already deleted"

# Kill the app to force a fresh launch
xcrun simctl terminate booted "$BUNDLE_ID" 2>/dev/null || echo "App not running"

echo "✅ Onboarding state reset. Launch the app to see onboarding again."
