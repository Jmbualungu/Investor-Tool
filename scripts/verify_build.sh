#!/bin/bash
# Build verification script for Investor Tool
# This script ensures the project builds successfully before commits

set -e  # Exit on any error

echo "🔍 Starting build verification..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="Investor Tool"
SCHEME="Investor Tool"
SDK="iphonesimulator"
DESTINATION="platform=iOS Simulator,name=iPhone 17 Pro"

# Step 1: Check for missing imports
echo "📋 Step 1: Checking for common import issues..."
MISSING_IMPORTS=0

# Check for @Published without Combine import
while IFS= read -r file; do
    if grep -q "@Published" "$file" && ! grep -q "^import Combine" "$file"; then
        echo -e "${RED}❌ Missing 'import Combine' in: $file${NC}"
        MISSING_IMPORTS=$((MISSING_IMPORTS + 1))
    fi
done < <(find "Investor Tool" -name "*.swift" -type f)

if [ $MISSING_IMPORTS -eq 0 ]; then
    echo -e "${GREEN}✅ All files with @Published have Combine imported${NC}"
else
    echo -e "${RED}❌ Found $MISSING_IMPORTS file(s) with missing Combine import${NC}"
    exit 1
fi
echo ""

# Step 2: Check for SwiftData @Model issues
echo "📋 Step 2: Checking for SwiftData @Model usage..."
SWIFTDATA_ISSUES=0

while IFS= read -r file; do
    if grep -q "@Model" "$file" && grep -q "@ObservedObject.*:" "$file"; then
        # Check if the ObservedObject is used with a @Model class
        echo -e "${YELLOW}⚠️  Warning: File uses @ObservedObject with potential @Model class: $file${NC}"
        echo -e "${YELLOW}   Consider using @Bindable instead for SwiftData models${NC}"
        SWIFTDATA_ISSUES=$((SWIFTDATA_ISSUES + 1))
    fi
done < <(find "Investor Tool" -name "*.swift" -type f)

if [ $SWIFTDATA_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ No obvious SwiftData @Model/@ObservedObject conflicts${NC}"
fi
echo ""

# Step 3: Build the project
echo "🔨 Step 3: Building project..."
echo "   Scheme: $SCHEME"
echo "   SDK: $SDK"
echo "   Destination: $DESTINATION"
echo ""

if xcodebuild \
    -scheme "$SCHEME" \
    -sdk "$SDK" \
    -destination "$DESTINATION" \
    build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    -quiet; then
    echo -e "${GREEN}✅ Build succeeded!${NC}"
else
    echo -e "${RED}❌ Build failed!${NC}"
    echo ""
    echo "To see detailed errors, run:"
    echo "  xcodebuild -scheme \"$SCHEME\" -sdk $SDK -destination '$DESTINATION' build"
    exit 1
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✨ All checks passed! Project is ready.${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
