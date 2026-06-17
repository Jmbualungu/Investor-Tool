#!/bin/bash

# Build, install, and launch Valtyde (Investor Tool) on the iOS Simulator.
# One command: builds from this repo, installs a fresh copy, launches it.

set -euo pipefail

# Resolve repo dir from this script's location (no hard-coded paths).
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="Investor Tool.xcodeproj"
SCHEME="Investor Tool"
BUNDLE_ID="com.jamesmbualungu.InvestorTool"
DERIVED="$PROJECT_DIR/build"

cd "$PROJECT_DIR"

# Pick a simulator: prefer one that's already booted, else boot iPhone 17.
DEVICE_ID="$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1 || true)"
if [ -z "$DEVICE_ID" ]; then
  echo "📱 No booted simulator — booting iPhone 17..."
  DEVICE_ID="$(xcrun simctl list devices available | grep 'iPhone 17 (' | grep -Eo '[0-9A-F-]{36}' | head -1)"
  xcrun simctl boot "$DEVICE_ID"
fi
echo "📱 Using simulator: $DEVICE_ID"

echo "🔨 Building (picks up your latest code)..."
xcodebuild -project "$PROJECT_NAME" -scheme "$SCHEME" \
  -sdk iphonesimulator -configuration Debug \
  -destination "platform=iOS Simulator,id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED" build

APP="$DERIVED/Build/Products/Debug-iphonesimulator/$SCHEME.app"

echo "🧹 Removing any stale install..."
xcrun simctl uninstall "$DEVICE_ID" "$BUNDLE_ID" 2>/dev/null || true

echo "📦 Installing fresh build..."
xcrun simctl install "$DEVICE_ID" "$APP"

echo "🚀 Launching..."
open -a Simulator
xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"

echo ""
echo "✅ Valtyde is running the latest build in the Simulator."
