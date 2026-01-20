#!/bin/bash
# Enable diagnostics mode (use DiagnosticsRootView)

set -e

PROJECT_DIR="/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
MAIN_FILE="$PROJECT_DIR/Investor Tool/App/ForecastAIApp.swift"

echo "🔍 Enabling Diagnostics Mode"
echo "============================="
echo ""

# Check if already in diagnostics mode
if grep -q "DiagnosticsRootView()" "$MAIN_FILE"; then
    echo "ℹ️  Already in diagnostics mode"
    exit 0
fi

# Create backup
cp "$MAIN_FILE" "$MAIN_FILE.backup"
echo "✅ Created backup: ForecastAIApp.swift.backup"

# Enable diagnostics
cat > "$MAIN_FILE" << 'EOF'
import SwiftUI
import SwiftData

@main
struct ForecastAIApp: App {
    var body: some Scene {
        WindowGroup {
            // TEMPORARY: Using DiagnosticsRootView to verify SwiftUI rendering
            DiagnosticsRootView()
            
            // NORMAL: Uncomment this when diagnostics pass
            // AppRoot()
        }
        .modelContainer(for: [
            AppItem.self,
            EntityAssumptionsTemplate.self,
            AssumptionItem.self
        ])
    }
}
EOF

echo "✅ Enabled diagnostics mode"
echo ""
echo "Next steps:"
echo "1. Run: ./scripts/test_diagnostics.sh"
echo "2. Or build manually: Cmd+R in Xcode"
echo ""
echo "Expected: Yellow screen with 'DIAGNOSTICS ROOT'"
echo ""
echo "To restore normal app:"
echo "  ./scripts/restore_approot.sh"
echo ""
