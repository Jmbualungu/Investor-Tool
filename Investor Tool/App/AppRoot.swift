//
//  AppRoot.swift
//  Investor Tool
//
//  Single stable root view with FlowState injection and debug HUD
//

import SwiftUI

struct AppRoot: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("marketingMode") private var marketingMode: Bool = false
    
    // Bump this string manually when you want to verify simulator updated
    private let buildStamp: String = "BuildStamp-002"
    
    var body: some View {
        Group {
            if hasSeenOnboarding == false {
                // Onboarding flow
                FirstLaunchOnboardingView(onComplete: {
                    hasSeenOnboarding = true
                })
            } else {
                // Main app shell with tab bar
                AppShellView()
            }
        }
        .overlay(alignment: .topLeading) {
            DebugHUD(
                buildStamp: buildStamp,
                hasSeenOnboarding: hasSeenOnboarding,
                pathCount: 0,
                ticker: nil
            ) {
                // Reset button action
                hasSeenOnboarding = false
                marketingMode = false
            }
            .padding()
        }
    }
}

#Preview {
    AppRoot()
}
