import SwiftUI

@main
struct ForecastAIApp: App {
    @StateObject private var config = GlobalAppConfig()
    
    // Build stamp to verify device is running latest build
    private let buildStamp = "RH-UI-2026-01-20"
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topLeading) {
                Group {
                    if config.hasSeenOnboarding {
                        // Show main app with tab bar
                        AppShellView()
                            .environmentObject(config)
                    } else {
                        // Show onboarding first
                        NavigationStack {
                            OnboardingFlowView()
                                .navigationBarBackButtonHidden(true)
                                .toolbar {
                                    ToolbarItem(placement: .topBarTrailing) {
                                        Button("Skip") {
                                            config.hasSeenOnboarding = true
                                        }
                                        .foregroundColor(DSColors.accent)
                                    }
                                }
                        }
                        .environmentObject(config)
                    }
                }
                
                #if DEBUG
                // Build stamp overlay (top-left)
                Text(buildStamp)
                    .font(.caption2.bold())
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 50)
                    .padding(.leading, 12)
                #endif
            }
        }
    }
}
