#!/bin/bash
# Verify Build Harness Implementation
# This script checks that all components are in place

set -e

echo "🔍 Build Harness Verification"
echo "================================"
echo ""

PROJECT_DIR="/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
cd "$PROJECT_DIR"

# Check files exist
echo "✅ Checking files..."

if [ -f "Investor Tool/App/AppRoot.swift" ]; then
    echo "  ✓ AppRoot.swift exists"
else
    echo "  ✗ AppRoot.swift missing"
    exit 1
fi

if [ -f "Investor Tool/App/DebugHUD.swift" ]; then
    echo "  ✓ DebugHUD.swift exists"
else
    echo "  ✗ DebugHUD.swift missing"
    exit 1
fi

# Check AppRoot has required components
echo ""
echo "✅ Checking AppRoot.swift components..."

if grep -q "buildStamp" "Investor Tool/App/AppRoot.swift"; then
    echo "  ✓ Build stamp present"
else
    echo "  ✗ Build stamp missing"
    exit 1
fi

if grep -q "resetAllToDefaults" "Investor Tool/App/AppRoot.swift"; then
    echo "  ✓ Reset function call present"
else
    echo "  ✗ Reset function call missing"
    exit 1
fi

if grep -q "@StateObject private var flowState" "Investor Tool/App/AppRoot.swift"; then
    echo "  ✓ FlowState creation present"
else
    echo "  ✗ FlowState creation missing"
    exit 1
fi

if grep -q "DebugHUD" "Investor Tool/App/AppRoot.swift"; then
    echo "  ✓ DebugHUD integration present"
else
    echo "  ✗ DebugHUD integration missing"
    exit 1
fi

# Check ForecastAIApp uses AppRoot
echo ""
echo "✅ Checking ForecastAIApp.swift..."

if grep -q "AppRoot()" "Investor Tool/App/ForecastAIApp.swift"; then
    echo "  ✓ Uses AppRoot as root view"
else
    echo "  ✗ Not using AppRoot"
    exit 1
fi

# Check DCFFlowState has resetAllToDefaults
echo ""
echo "✅ Checking DCFFlowState.swift..."

if grep -q "func resetAllToDefaults" "Investor Tool/Core/Models/DCFFlowState.swift"; then
    echo "  ✓ resetAllToDefaults method present"
else
    echo "  ✗ resetAllToDefaults method missing"
    exit 1
fi

# Check onboarding view has safety features
echo ""
echo "✅ Checking FirstLaunchOnboardingView.swift..."

if grep -q "allowsHitTesting(false)" "Investor Tool/Features/Onboarding/FirstLaunchOnboardingView.swift"; then
    echo "  ✓ Background non-interactive"
else
    echo "  ✗ Background might block interactions"
    exit 1
fi

# Try to build
echo ""
echo "✅ Building project..."
echo "  (This may take a moment...)"

if xcodebuild -project "Investor Tool.xcodeproj" \
              -scheme "Investor Tool" \
              -sdk iphonesimulator \
              -configuration Debug \
              clean build \
              2>&1 | grep -q "BUILD SUCCEEDED"; then
    echo "  ✓ Build succeeded"
else
    echo "  ✗ Build failed"
    exit 1
fi

# Success
echo ""
echo "================================"
echo "✅ All checks passed!"
echo ""
echo "📱 Ready to run in Simulator"
echo ""
echo "Next steps:"
echo "1. Open Xcode"
echo "2. Run the app in Simulator"
echo "3. Look for Debug HUD in top-left"
echo "4. Test 'Reset App State' button"
echo ""
