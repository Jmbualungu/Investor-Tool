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
    
    @StateObject private var flowState = DCFFlowState()
    @State private var path: [AppRoute] = []
    
    // Bump this string manually when you want to verify simulator updated
    private let buildStamp: String = "BuildStamp-001"
    
    // Helper for path binding
    private var pathBinding: Binding<[AppRoute]> {
        $path
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasSeenOnboarding == false {
                    FirstLaunchOnboardingView(onComplete: {
                        hasSeenOnboarding = true
                    })
                } else {
                    // Main app entry point - ticker search
                    DCFTickerSearchView(
                        onSelectTicker: { ticker in
                            flowState.selectedTicker = ticker
                            path.append(.dcfCompanyContext(ticker))
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
            DebugHUD(
                buildStamp: buildStamp,
                hasSeenOnboarding: hasSeenOnboarding,
                pathCount: path.count,
                ticker: flowState.selectedTicker?.symbol
            ) {
                // Reset button action
                hasSeenOnboarding = false
                marketingMode = false
                path = []
                flowState.resetAllToDefaults()
            }
            .padding()
        }
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
    AppRoot()
}
