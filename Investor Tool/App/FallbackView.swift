//
//  FallbackView.swift
//  Investor Tool
//
//  Emergency fallback view with direct navigation to any screen
//

import SwiftUI

struct FallbackView: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("App Recovery Mode")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Navigate to any screen directly")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 16)
                
                // Navigation Buttons
                VStack(spacing: 12) {
                    navigationButton("Go to Welcome", icon: "hand.wave.fill") {
                        router.goToWelcome()
                    }
                    
                    navigationButton("Go to Ticker Search", icon: "magnifyingglass") {
                        if config.safeMode {
                            router.selectedTicker = config.sampleTicker
                        }
                        router.goToTickerSearch()
                    }
                    
                    navigationButton("Go to Assumptions", icon: "slider.horizontal.3") {
                        if config.safeMode {
                            router.selectedTicker = config.sampleTicker
                            router.assumptions = config.sampleAssumptions
                        }
                        router.goToAssumptions()
                    }
                    
                    navigationButton("Go to Sensitivity Analysis", icon: "square.grid.3x3.fill") {
                        if config.safeMode {
                            router.selectedTicker = config.sampleTicker
                            router.assumptions = config.sampleAssumptions
                        }
                        router.goToSensitivity()
                    }
                }
                .padding(.horizontal, 24)
                
                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.vertical, 8)
                
                // Safe Mode Toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Safe Mode")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Uses sample data, no network calls")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $config.safeMode)
                        .labelsHidden()
                        .tint(.green)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func navigationButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    FallbackView()
        .environmentObject(FlowRouter())
        .environmentObject(GlobalAppConfig())
}
