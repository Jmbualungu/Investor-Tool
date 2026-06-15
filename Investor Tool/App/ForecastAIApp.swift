import SwiftUI

@main
struct ForecastAIApp: App {
    @StateObject private var config = GlobalAppConfig()
    @StateObject private var authViewModel = AuthViewModel()
    
    // Build stamp to verify device is running latest build
    private let buildStamp = "AUTH-ENABLED-2026-01-21"
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .topLeading) {
                // Background that fills entire window (ensures no black bars)
                DSColors.background
                    .ignoresSafeArea()
                
                // Auth Gate wraps everything
                AuthGate(viewModel: authViewModel) {
                    // Main app content (only shown when authenticated)
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .environmentObject(config)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onOpenURL { url in
                    // CRITICAL: Handle deep links for password recovery
                    print("🔗 App received URL: \(url.absoluteString)")
                    Task {
                        await authViewModel.handleOpenURL(url)
                    }
                }
                
                #if DEBUG
                // Build stamp overlay (top-left) — passthrough so it doesn't block header taps
                Text(buildStamp)
                    .font(.caption2.bold())
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 50)
                    .padding(.leading, 12)
                    .allowsHitTesting(false)
                #endif
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            #if DEBUG
            .debugLayoutInstrumentation()
            #endif
        }
    }
}
