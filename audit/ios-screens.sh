#!/bin/bash
#
# iOS launch-readiness screenshot harness (audit-only).
#
# Builds the Debug app once, then on each device class installs it and captures
# the two screens reachable without UI taps (simctl can't tap without idb):
#   1. Onboarding  — fresh install, first launch
#   2. Forecast home — after setting guest + onboarding defaults
#
# Output: audit/screenshots/ios/<device>/{01-onboarding,02-forecast}.png
# Deeper screens (Watchlist/Sensitivity/Results) need idb or manual capture.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="Investor Tool.xcodeproj"
SCHEME="Investor Tool"
BUNDLE_ID="com.jamesmbualungu.InvestorTool"
DERIVED="$PROJECT_DIR/build"
APP="$DERIVED/Build/Products/Debug-iphonesimulator/$SCHEME.app"
OUT="$PROJECT_DIR/audit/screenshots/ios"

# Device classes (no SE-class simulator is installed on this machine).
DEVICES=(
  "compact:iPhone 17e"
  "standard:iPhone 17"
  "large:iPhone 17 Pro Max"
)

cd "$PROJECT_DIR"

echo "🔨 Building once for simulator..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -sdk iphonesimulator -configuration Debug \
  -derivedDataPath "$DERIVED" build >/dev/null
echo "✅ Build ready: $APP"

udid_for() {
  xcrun simctl list devices available | grep -F "$1 (" | grep -oE '[0-9A-F-]{36}' | head -1
}

shoot() {  # udid  outfile
  sleep 3
  mkdir -p "$(dirname "$2")"
  xcrun simctl io "$1" screenshot "$2" >/dev/null 2>&1 && echo "   📸 $(basename "$(dirname "$2")")/$(basename "$2")"
}

for entry in "${DEVICES[@]}"; do
  label="${entry%%:*}"; name="${entry#*:}"
  udid="$(udid_for "$name")"
  if [ -z "$udid" ]; then echo "⚠️  $name not available — skipping"; continue; fi
  echo "📱 $label ($name) → $udid"

  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 || true

  # Fresh state for onboarding capture.
  xcrun simctl uninstall "$udid" "$BUNDLE_ID" 2>/dev/null || true
  xcrun simctl install "$udid" "$APP"
  xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
  shoot "$udid" "$OUT/$label/01-onboarding.png"
  xcrun simctl terminate "$udid" "$BUNDLE_ID" 2>/dev/null || true

  # Skip auth + onboarding → land on Forecast home.
  xcrun simctl spawn "$udid" defaults write "$BUNDLE_ID" hasSeenOnboarding -bool true 2>/dev/null || true
  xcrun simctl spawn "$udid" defaults write "$BUNDLE_ID" isGuestMode -bool true 2>/dev/null || true
  xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
  shoot "$udid" "$OUT/$label/02-forecast.png"
done

echo "✅ Done. Screenshots in $OUT"
