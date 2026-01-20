import SwiftUI

struct RootView: View {
    @StateObject private var bootGate = DebugBootGate()
    @EnvironmentObject private var router: AppRouterCoordinator
    
    var body: some View {
        Group {
            if bootGate.debugBootMinimal {
                // Safety fallback - always renders
                minimalDiagnosticView
            } else {
                // Real app content (will be populated in steps)
                appContent
            }
        }
        .onAppear {
            // Safety: if app hangs, user can toggle debugBootMinimal in UserDefaults
            print("RootView loaded. debugBootMinimal = \(bootGate.debugBootMinimal)")
        }
    }
    
    private var minimalDiagnosticView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("App Loaded")
                    .font(.largeTitle)
                    .foregroundColor(.white)

                Text("Simulator diagnostic root fixed")
                    .foregroundColor(.gray)
                
                Text("(Minimal Mode)")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var appContent: some View {
        // STEP 5: NavigationStack with AppRouterCoordinator
        NavigationStack(path: $router.path) {
            SimpleHomeView()
                .navigationDestination(for: Route.self) { route in
                    routeDestination(for: route)
                }
        }
    }
    
    @ViewBuilder
    private func routeDestination(for route: Route) -> some View {
        switch route {
        case .home:
            SimpleHomeView()
        case .settings:
            SimpleDetailView(title: "Settings")
        case .tickerDetail(let ticker):
            TickerDetailScreen(ticker: ticker)
        case .tickerSearch:
            SimpleDetailView(title: "Ticker Search")
        case .assumptions:
            SimpleDetailView(title: "Assumptions")
        case .forecast:
            SimpleDetailView(title: "Forecast")
        
        // DCF Flow routes (handled in tab navigation)
        case .companyContext, .investmentLens, .revenueDrivers,
             .operatingAssumptions, .valuationAssumptions,
             .valuationResults, .sensitivity:
            EmptyView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
        .environmentObject(AppRouterCoordinator())
}
