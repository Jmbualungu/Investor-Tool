#!/bin/bash
# Restore AppRoot as main view (exit diagnostics mode)

set -e

PROJECT_DIR="/Users/jamesmbualungu/Desktop/Coding/Investor Tool"
MAIN_FILE="$PROJECT_DIR/Investor Tool/App/ForecastAIApp.swift"

echo "🔄 Restoring AppRoot"
echo "==================="
echo ""

# Check if in diagnostics mode
if ! grep -q "DiagnosticsRootView()" "$MAIN_FILE"; then
    echo "ℹ️  Already using AppRoot (not in diagnostics mode)"
    exit 0
fi

# Create backup
cp "$MAIN_FILE" "$MAIN_FILE.backup"
echo "✅ Created backup: ForecastAIApp.swift.backup"

# Restore AppRoot
cat > "$MAIN_FILE" << 'EOF'
import SwiftUI
import SwiftData

@main
struct ForecastAIApp: App {
    var body: some Scene {
        WindowGroup {
            AppRoot()
        }
        .modelContainer(for: [
            AppItem.self,
            EntityAssumptionsTemplate.self,
            AssumptionItem.self
        ])
    }
}
EOF

echo "✅ Restored AppRoot as main view"
echo ""
echo "Next steps:"
echo "1. Build and run (Cmd+R)"
echo "2. If you see black screen:"
echo "   → The issue is in AppRoot or its dependencies"
echo "   → Check DIAGNOSTICS_GUIDE.md for recovery steps"
echo "3. If you see the app:"
echo "   → Everything is working!"
echo "   → Check for Debug HUD in top-left corner"
echo ""
echo "To switch back to diagnostics:"
echo "  ./scripts/enable_diagnostics.sh"
echo ""
