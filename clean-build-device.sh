#!/bin/bash

# Clean Build Script for Physical Device Testing
# This script helps verify the new Robinhood UI is deployed to your device

set -e  # Exit on error

PROJECT_PATH="/Users/jamesmbualungu/Desktop/Coding/Investor Tool/Valtyde.xcodeproj"
SCHEME_NAME="Valtyde"
BUILD_STAMP="RH-UI-2026-01-20"

echo "🧹 Starting clean build process..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Clean build folder
echo "1️⃣  Cleaning build folder..."
xcodebuild clean -project "$PROJECT_PATH" -scheme "$SCHEME_NAME" -quiet
echo "   ✅ Build folder cleaned"
echo ""

# Step 2: Clean derived data
echo "2️⃣  Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Investor_Tool-*
echo "   ✅ Derived data cleaned"
echo ""

# Step 3: Instructions for device deployment
echo "3️⃣  Next steps (manual):"
echo "   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   1. Delete the app from your physical device"
echo "   2. In Xcode, select your device as the target"
echo "   3. Press ⌘R to build and run"
echo "   4. Look for build stamp in top-left: '$BUILD_STAMP'"
echo ""
echo "🎯 Expected Result:"
echo "   • Build stamp visible in top-left corner"
echo "   • Robinhood-like tab bar (4 tabs)"
echo "   • NO 'Safe Mode Active' screen"
echo "   • NO 'sample ticker AAPL' text"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Clean build preparation complete!"
echo ""
