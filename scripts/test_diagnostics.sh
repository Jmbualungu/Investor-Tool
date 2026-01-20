#!/bin/bash
# Test Diagnostics Root View
# This script builds and displays instructions for testing

set -e

PROJECT_DIR="/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
cd "$PROJECT_DIR"

echo "🔍 Diagnostics Test"
echo "==================="
echo ""

# Check current configuration
if grep -q "DiagnosticsRootView()" "Investor Tool/App/ForecastAIApp.swift"; then
    echo "✅ Diagnostics mode: ACTIVE"
    echo "   App will show yellow diagnostics screen"
else
    echo "❌ Diagnostics mode: INACTIVE"
    echo "   App is using normal AppRoot"
    exit 1
fi

echo ""
echo "Building project..."
echo ""

# Build
if xcodebuild -project "Investor Tool.xcodeproj" \
              -scheme "Investor Tool" \
              -sdk iphonesimulator \
              -configuration Debug \
              build \
              2>&1 | grep -q "BUILD SUCCEEDED"; then
    echo "✅ Build succeeded"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "==================="
echo "✅ Ready to test!"
echo ""
echo "Next steps:"
echo "1. Open Xcode: open 'Investor Tool.xcodeproj'"
echo "2. Select a simulator (iPhone 15 Pro recommended)"
echo "3. Press Cmd+R to run"
echo ""
echo "Expected result:"
echo "┌─────────────────────────────────────┐"
echo "│  🟨 Light yellow background          │"
echo "│                                     │"
echo "│  DIAGNOSTICS ROOT                   │"
echo "│  Large text in center               │"
echo "│                                     │"
echo "│  Current timestamp below            │"
echo "│  'App is running' in green          │"
echo "└─────────────────────────────────────┘"
echo ""
echo "If you see BLACK screen instead:"
echo "  - Check Console (Cmd+Shift+Y) for errors"
echo "  - See DIAGNOSTICS_GUIDE.md for troubleshooting"
echo ""
echo "If you see YELLOW screen:"
echo "  ✅ SwiftUI is working"
echo "  ↳ Issue is with AppRoot, not SwiftUI itself"
echo "  ↳ Run: ./scripts/restore_approot.sh to restore normal app"
echo ""
