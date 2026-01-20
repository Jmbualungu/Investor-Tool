#!/bin/bash

# Run Investor Tool in Simulator
# This script cleans, builds, and runs the app

set -e

PROJECT_DIR="/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
PROJECT_NAME="Investor Tool.xcodeproj"
SCHEME="Investor Tool"

echo "🧹 Cleaning build..."
cd "$PROJECT_DIR"
xcodebuild -project "$PROJECT_NAME" -scheme "$SCHEME" clean

echo "🔨 Building app..."
xcodebuild -project "$PROJECT_NAME" -scheme "$SCHEME" -sdk iphonesimulator -configuration Debug build

echo "📱 Opening Simulator..."
open -a Simulator

echo ""
echo "✅ Build complete!"
echo ""
echo "Now press Cmd+R in Xcode to run the app, or:"
echo "1. Open Xcode: open '$PROJECT_DIR/$PROJECT_NAME'"
echo "2. Select an iPhone simulator from the dropdown"
echo "3. Press Cmd+R or click the Play button"
echo ""
