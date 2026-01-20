//
//  RootAppView.swift
//  Investor Tool
//
//  Single entry point for the app with onboarding gating
//

import SwiftUI

struct RootAppView: View {
    // MARK: - State
    
    @StateObject private var flowState = DCFFlowState()
    @State private var path: [AppRoute] = []
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // Helper for path binding
    private var pathBinding: Binding<[AppRoute]> {
        $path
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasSeenOnboarding {
                    // Main app entry point
                    DCFTickerSearchView(
                        onSelectTicker: { ticker in
                            flowState.selectedTicker = ticker
                            path.append(.dcfCompanyContext(ticker))
                        }
                    )
                } else {
                    // Onboarding
                    FirstLaunchOnboardingView(
                        onComplete: {
                            hasSeenOnboarding = true
                        }
                    )
                }
            }
            .environmentObject(flowState)
            .environment(\.navigationPath, pathBinding)
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .overlay(alignment: .topLeading) {
            debugOverlay
        }
    }
    
    // MARK: - Debug Overlay
    
    private var debugOverlay: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("DEBUG")
                .font(.caption)
                .bold()
            Text("hasSeenOnboarding: \(hasSeenOnboarding.description)")
            Text("path: \(path.count)")
            Text("ticker: \(flowState.selectedTicker?.symbol ?? "nil")")
        }
        .font(.caption)
        .padding(8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
    
    // MARK: - Navigation Destinations
    
    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .tickerSearch:
            // Legacy route - not used in new flow
            EmptyView()
            
        case .assumptions:
            // Legacy route - not used in new flow
            EmptyView()
            
        case .forecast:
            // Legacy route - not used in new flow
            EmptyView()
            
        case .returns:
            // Legacy route - not used in new flow
            EmptyView()
            
        case .sensitivity:
            // Legacy route - not used in new flow
            EmptyView()
            
        // DCF Setup Flow
        case .dcfTickerSearch:
            DCFTickerSearchView(
                onSelectTicker: { ticker in
                    flowState.selectedTicker = ticker
                    path.append(.dcfCompanyContext(ticker))
                }
            )
            .environmentObject(flowState)
            
        case .dcfCompanyContext(let ticker):
            CompanyContextView(
                ticker: ticker,
                onContinue: {
                    path.append(.dcfInvestmentLens)
                }
            )
            .environmentObject(flowState)
            
        case .dcfInvestmentLens:
            InvestmentLensView(
                onContinue: {
                    flowState.generateRevenueDrivers()
                    path.append(.dcfRevenueDrivers)
                }
            )
            .environmentObject(flowState)
            
        case .dcfRevenueDrivers:
            RevenueDriversView(
                onContinue: {
                    path.append(.dcfOperatingAssumptions)
                }
            )
            .environmentObject(flowState)
            
        case .dcfOperatingAssumptions:
            OperatingAssumptionsView(
                onContinue: {
                    path.append(.dcfValuationAssumptions)
                }
            )
            .environmentObject(flowState)
            
        case .dcfValuationAssumptions:
            ValuationAssumptionsView(
                onContinue: {
                    path.append(.dcfValuationResults)
                }
            )
            .environmentObject(flowState)
            
        case .dcfValuationResults:
            ValuationResultsView(
                onShowSensitivity: {
                    path.append(.dcfSensitivity)
                }
            )
            .environmentObject(flowState)
            
        case .dcfSensitivity:
            SensitivityAnalysisView()
                .environmentObject(flowState)
        }
    }
}

#Preview {
    RootAppView()
}
