import SwiftUI

enum AppRoute: Hashable {
    case tickerSearch
    case assumptions
    case forecast
    case returns
    case sensitivity
    
    // DCF Setup Flow
    case dcfTickerSearch
    case dcfCompanyContext(DCFTicker)
    case dcfInvestmentLens
    case dcfRevenueDrivers
    case dcfOperatingAssumptions
    case dcfValuationAssumptions
    case dcfValuationResults
    case dcfSensitivity
}

struct AppRouter: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var path: [AppRoute] = []
    @State private var showOnboarding = false
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var disclaimerManager = DisclaimerManager()
    @StateObject private var dcfFlowState = DCFFlowState()
    
    // Navigation helper
    private var pathBinding: Binding<[AppRoute]> {
        $path
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                LandingView(
                    onStart: {
                        // Check if user has seen onboarding
                        if !hasSeenOnboarding {
                            showOnboarding = true
                        } else if disclaimerManager.hasAccepted {
                            // Only allow navigation if disclaimer has been accepted
                            path.append(.dcfTickerSearch)
                        }
                        // If not accepted, user must complete disclaimer flow first
                    },
                    onLogin: {
                        // TODO: Navigate to login/authentication flow
                        // For now, navigate to settings as placeholder
                        print("Login tapped - authentication flow not yet implemented")
                    }
                )
                .environmentObject(disclaimerManager)
                .environmentObject(dcfFlowState)
                .environment(\.navigationPath, pathBinding)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
            }
            
            // Full-screen onboarding overlay
            if showOnboarding {
                FirstLaunchOnboardingView {
                    Motion.withAnimation(Motion.appear) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .tickerSearch:
            TickerSearchView(
                viewModel: appViewModel.tickerSearchViewModel,
                onContinue: { ticker, horizonYears in
                    appViewModel.assumptionsViewModel.ticker = ticker
                    appViewModel.assumptionsViewModel.assumptions.horizonYears = horizonYears
                    path.append(.assumptions)
                }
            )
        case .assumptions:
            AssumptionsView(
                viewModel: appViewModel.assumptionsViewModel,
                ticker: appViewModel.assumptionsViewModel.ticker,
                horizonYears: appViewModel.assumptionsViewModel.assumptions.horizonYears,
                onContinue: {
                    runForecast()
                    path.append(.forecast)
                }
            )
        case .forecast:
            ForecastView(
                viewModel: appViewModel.forecastViewModel,
                assumptionsViewModel: appViewModel.assumptionsViewModel,
                onShowReturns: { path.append(.returns) },
                onShowSensitivity: { path.append(.sensitivity) }
            )
        case .returns:
            ReturnsView(
                viewModel: appViewModel.returnsViewModel,
                forecastViewModel: appViewModel.forecastViewModel,
                onShowSensitivity: { path.append(.sensitivity) }
            )
        case .sensitivity:
            SensitivityView(
                viewModel: appViewModel.sensitivityViewModel,
                assumptionsViewModel: appViewModel.assumptionsViewModel,
                onDone: { path = [] }
            )
            
        // DCF Setup Flow
        case .dcfTickerSearch:
            DCFTickerSearchView(
                onSelectTicker: { ticker in
                    dcfFlowState.selectedTicker = ticker
                    path.append(.dcfCompanyContext(ticker))
                }
            )
            .environmentObject(dcfFlowState)
            
        case .dcfCompanyContext(let ticker):
            CompanyContextView(
                ticker: ticker,
                onContinue: {
                    path.append(.dcfInvestmentLens)
                }
            )
            .environmentObject(dcfFlowState)
            
        case .dcfInvestmentLens:
            InvestmentLensView(
                onContinue: {
                    dcfFlowState.generateRevenueDrivers()
                    path.append(.dcfRevenueDrivers)
                }
            )
            .environmentObject(dcfFlowState)
            
        case .dcfRevenueDrivers:
            RevenueDriversView(
                onContinue: {
                    path.append(.dcfOperatingAssumptions)
                }
            )
            .environmentObject(dcfFlowState)
            
        case .dcfOperatingAssumptions:
            OperatingAssumptionsView(
                onContinue: {
                    path.append(.dcfValuationAssumptions)
                }
            )
            .environmentObject(dcfFlowState)
            
        case .dcfValuationAssumptions:
            ValuationAssumptionsView(
                onContinue: {
                    path.append(.dcfValuationResults)
                }
            )
            .environmentObject(dcfFlowState)
            
        case .dcfValuationResults:
            ValuationResultsView(
                onShowSensitivity: {
                    path.append(.dcfSensitivity)
                }
            )
            .environmentObject(dcfFlowState)
            
        case .dcfSensitivity:
            SensitivityAnalysisView()
                .environmentObject(dcfFlowState)
        }
    }

    private func runForecast() {
        let ticker = appViewModel.assumptionsViewModel.ticker ?? Ticker(symbol: "TBD", name: "Selected Ticker")
        appViewModel.forecastViewModel.runForecast(
            ticker: ticker,
            assumptions: appViewModel.assumptionsViewModel.assumptions,
            horizons: [1, 3, 5, 10]
        )
    }
}
