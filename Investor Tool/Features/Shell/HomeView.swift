import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var store: AppItemStore
    @State private var navigateToTickerSearch = false
    
    // Hardcoded recent tickers
    private let recentTickers = ["AAPL", "MSFT", "NVDA"]
    
    var body: some View {
        ZStack {
            // Dark background
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Header Section
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        Text("Forecast")
                            .dsTitle()
                        
                        Text("Build DCF models and analyze investment opportunities")
                            .dsBody()
                    }
                    .padding(.top, DSSpacing.xl)
                    
                    // Start Forecast Card
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("New Forecast")
                                        .dsHeadline()
                                    Text("Create a DCF valuation model")
                                        .dsCaption()
                                }
                                Spacer()
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(DSColors.accent)
                            }
                            
                            NavigationLink(destination: TickerSearchView(
                                viewModel: TickerSearchViewModel(),
                                onContinue: { _, _ in }
                            )) {
                                HStack {
                                    Text("Start Forecast")
                                        .font(DSTypography.button)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: DSSpacing.buttonHeightStandard)
                                .background(DSColors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
                            }
                        }
                    }
                    
                    // Recent Tickers Card
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            Text("Recent")
                                .dsHeadline()
                            
                            DSChipBar(items: recentTickers) { ticker in
                                // Placeholder action - could navigate to forecast for that ticker
                                print("Tapped ticker: \(ticker)")
                            }
                        }
                    }
                    
                    Spacer(minLength: DSSpacing.xl)
                }
                .padding(.horizontal, DSSpacing.l)
            }
            
            // Settings Button (top-right)
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        DSIconCircleButton(icon: "gear") {
                            // Navigation handled by NavigationLink
                        }
                    }
                    .padding(.trailing, DSSpacing.l)
                    .padding(.top, DSSpacing.m)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeViewPreview()
}

private struct HomeViewPreview: View {
    var body: some View {
        if let container = try? ModelContainer(
            for: AppItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) {
            let store = AppItemStore()
            let tabs = TabSelectionStore()
            NavigationStack {
                HomeView()
            }
            .environmentObject(store)
            .environmentObject(tabs)
            .modelContainer(container)
            .onAppear {
                store.configure(modelContext: container.mainContext)
            }
        } else {
            Text("Preview unavailable")
                .padding()
        }
    }
}
