//
//  MainFlowView.swift
//  Investor Tool
//
//  Main flow controller with guaranteed visibility
//

import SwiftUI

struct MainFlowView: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showFallback = false
    
    var body: some View {
        ZStack {
            // Main navigation
            NavigationStack(path: $router.path) {
                rootScreen
                    .navigationDestination(for: FlowRoute.self) { route in
                        destinationView(for: route)
                    }
            }
            .overlay(alignment: .topLeading) {
                DebugHUDView()
            }
            
            // Fallback overlay (emergency)
            if showFallback {
                FallbackView()
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .onAppear {
            print("MainFlowView appeared")
            print("Config - Safe Mode: \(config.safeMode), Seen Onboarding: \(config.hasSeenOnboarding)")
            
            // If safe mode, prepare sample data
            if config.safeMode {
                router.selectedTicker = config.sampleTicker
                router.assumptions = config.sampleAssumptions
            }
        }
        .onShake {
            // Shake device to show fallback
            withAnimation {
                showFallback.toggle()
            }
        }
    }
    
    @ViewBuilder
    private var rootScreen: some View {
        if config.hasSeenOnboarding {
            // Go straight to ticker search
            TickerSearchWrapper()
        } else {
            // Show welcome/landing
            WelcomeWrapper()
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: FlowRoute) -> some View {
        switch route {
        case .welcome:
            WelcomeWrapper()
        case .tickerSearch:
            TickerSearchWrapper()
        case .assumptions:
            AssumptionsWrapper()
        case .forecast:
            ForecastWrapper()
        case .sensitivity:
            SensitivityWrapper()
        case .settings:
            SettingsWrapper()
        }
    }
}

// MARK: - Welcome Wrapper

struct WelcomeWrapper: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    
    var body: some View {
        LandingView(
            onStart: {
                config.hasSeenOnboarding = true
                router.push(.tickerSearch)
            },
            onLogin: {
                // For now, just go to ticker search
                config.hasSeenOnboarding = true
                router.push(.tickerSearch)
            }
        )
    }
}

// MARK: - Ticker Search Wrapper

struct TickerSearchWrapper: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        if config.safeMode {
            // Safe mode: auto-advance with sample data
            SafeTickerSearchView()
        } else {
            // Normal mode: use real view
            TickerSearchView(
                viewModel: appViewModel.tickerSearchViewModel,
                onContinue: { ticker, horizon in
                    router.continueFromTickerSearch(ticker: ticker, horizon: horizon)
                }
            )
        }
    }
}

struct SafeTickerSearchView: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Ticker Search")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Safe Mode Active")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    
                    Text("Using sample ticker: \(config.sampleTicker.symbol)")
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    router.continueFromTickerSearch(
                        ticker: config.sampleTicker,
                        horizon: 5
                    )
                }) {
                    Text("Continue with \(config.sampleTicker.symbol)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Ticker Search")
    }
}

// MARK: - Assumptions Wrapper

struct AssumptionsWrapper: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        if config.safeMode {
            SafeAssumptionsView()
        } else {
            AssumptionsView(
                viewModel: appViewModel.assumptionsViewModel,
                ticker: router.selectedTicker,
                horizonYears: router.selectedHorizon,
                onContinue: {
                    router.continueFromAssumptions(
                        assumptions: appViewModel.assumptionsViewModel.assumptions
                    )
                }
            )
        }
    }
}

struct SafeAssumptionsView: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Assumptions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Safe Mode Active")
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    
                    Text("Using sample assumptions for \(config.sampleTicker.symbol)")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    assumptionRow("Revenue", value: "$\(Int(config.sampleAssumptions.currentRevenue))M")
                    assumptionRow("CAGR", value: "\(Int(config.sampleAssumptions.revenueCagr * 100))%")
                    assumptionRow("Margin", value: "\(Int(config.sampleAssumptions.operatingMargin * 100))%")
                    assumptionRow("Horizon", value: "\(config.sampleAssumptions.horizonYears)Y")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                Button(action: {
                    router.continueFromAssumptions(assumptions: config.sampleAssumptions)
                }) {
                    Text("Generate Forecast")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Assumptions")
    }
    
    func assumptionRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Forecast Wrapper

struct ForecastWrapper: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        if config.safeMode {
            SafeForecastView()
        } else {
            ForecastView(
                viewModel: appViewModel.forecastViewModel,
                assumptionsViewModel: appViewModel.assumptionsViewModel,
                onShowReturns: { router.push(.sensitivity) },
                onShowSensitivity: { router.continueToSensitivity() }
            )
        }
    }
}

struct SafeForecastView: View {
    @EnvironmentObject var router: FlowRouter
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Forecast Results")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    resultCard("Target Price", value: "$215", change: "+43.3%")
                    resultCard("Fair Value", value: "$195", change: "+30.0%")
                    resultCard("5Y Return", value: "15.2%", change: "Annualized")
                }
                .padding(.horizontal, 24)
                
                Button(action: {
                    router.continueToSensitivity()
                }) {
                    Text("View Sensitivity Analysis")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Forecast")
    }
    
    func resultCard(_ label: String, value: String, change: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            HStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text(change)
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Sensitivity Wrapper

struct SensitivityWrapper: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        if config.safeMode {
            SafeSensitivityView()
        } else {
            SensitivityView(
                viewModel: appViewModel.sensitivityViewModel,
                assumptionsViewModel: appViewModel.assumptionsViewModel,
                onDone: {
                    router.popToRoot()
                }
            )
        }
    }
}

struct SafeSensitivityView: View {
    @EnvironmentObject var router: FlowRouter
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Sensitivity Analysis")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("5-Year Annualized Returns")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                // Sample sensitivity grid
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        gridCell("8.5%")
                        gridCell("12.3%")
                        gridCell("16.1%")
                    }
                    HStack(spacing: 8) {
                        gridCell("10.2%")
                        gridCell("15.2%")
                        gridCell("19.8%")
                    }
                    HStack(spacing: 8) {
                        gridCell("12.1%")
                        gridCell("18.4%")
                        gridCell("23.7%")
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                Text("✓ Analysis Complete")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                
                Button(action: {
                    router.popToRoot()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .navigationTitle("Sensitivity")
    }
    
    func gridCell(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 16, weight: .semibold, design: .monospaced))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(8)
    }
}

// MARK: - Settings Wrapper

struct SettingsWrapper: View {
    @EnvironmentObject var config: GlobalAppConfig
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Form {
                Section("App Configuration") {
                    Toggle("Safe Mode", isOn: $config.safeMode)
                    Toggle("Has Seen Onboarding", isOn: $config.hasSeenOnboarding)
                }
                
                Section("About") {
                    Text("ForecastAI v1.0")
                    Text("Build: Debug")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Shake Gesture Extension

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeModifier(action: action))
    }
}

struct ShakeModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

#Preview {
    MainFlowView()
        .environmentObject(FlowRouter())
        .environmentObject(GlobalAppConfig())
        .environmentObject(AppViewModel())
}
