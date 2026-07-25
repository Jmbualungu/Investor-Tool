import SwiftUI

/*
 BrowseView - Robinhood-style market browser
 
 HOW IT WORKS:
 - Search bar at top triggers typeahead overlay with debounced search (200ms)
 - Segmented control switches between Now/Macro/Crypto/Sports tabs
 - Macro tab shows: Top movers chips, Sector heatmap with selector, Futures cards, Economic events
 - Tapping any ticker navigates to TickerDetailView
 - Search overlay provides watchlist & forecast management with haptic feedback
 - All data is local/stub-based (no external APIs)
 */

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    @EnvironmentObject private var watchlistStore: WatchlistStore
    @EnvironmentObject private var forecastStore: ForecastStore
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                tabSelector
                contentSection
            }
            
            if viewModel.showSearchOverlay {
                SearchOverlayView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98)),
                        removal: .opacity
                    ))
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 14) {
            Text("Browse")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            searchBar
        }
        .padding(.horizontal, DSSpacing.l)
        .padding(.top, DSSpacing.l)
        .background(DSColors.background)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(viewModel.showSearchOverlay ? DSColors.accent : DSColors.textSecondary)
            
            TextField("Search Robinhood...", text: $viewModel.searchQuery)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(DSColors.textPrimary)
                .autocapitalization(.allCharacters)
                .disableAutocorrection(true)
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.clearSearch()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(DSColors.textSecondary)
                }
                .accessibilityLabel("Clear search")
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    viewModel.showSearchOverlay ? DSColors.accent.opacity(0.5) : DSColors.border,
                    lineWidth: viewModel.showSearchOverlay ? 1.5 : 0.5
                )
        )
        .animation(.easeOut(duration: 0.2), value: viewModel.showSearchOverlay)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MarketTab.allCases) { tab in
                    DSPillChip(
                        title: tab.rawValue,
                        isSelected: viewModel.selectedTab == tab
                    ) {
                        // Haptic feedback for tab selection
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                        
                        withAnimation(.easeOut(duration: 0.2)) {
                            viewModel.selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, DSSpacing.l)
        }
        .padding(.vertical, 14)
        .background(DSColors.background)
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        ScrollView {
            VStack(spacing: 28) {
                switch viewModel.selectedTab {
                case .macro:
                    macroTabContent
                case .now, .crypto, .sports:
                    placeholderTabContent
                }
            }
            .padding(.horizontal, DSSpacing.l)
            .padding(.top, 4)
            .padding(.bottom, 100)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity.combined(with: .move(edge: .leading))
            ))
            .animation(.easeOut(duration: 0.25), value: viewModel.selectedTab)
        }
        .refreshable {
            await refreshAllData()
        }
    }
    
    private func refreshAllData() async {
        viewModel.loadData()
        try? await Task.sleep(nanoseconds: 500_000_000) // Minimum feedback time
    }
    
    // MARK: - Macro Tab Content
    
    private var macroTabContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            topMoversSection
            sectorHeatmapSection
            futuresMarketsSection
            economicEventsSection
        }
    }
    
    private var topMoversSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DSBrowseSectionHeader(title: "Top movers", showInfo: true)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.topMovers) { mover in
                        NavigationLink(destination: TickerDetailView(ticker: Ticker(symbol: mover.ticker, name: mover.companyName))) {
                            DSTopMoverChip(mover: mover)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
    }
    
    private var sectorHeatmapSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                DSBrowseSectionHeader(title: viewModel.selectedSector.rawValue)
                
                Spacer()
                
                // Sector performance indicator
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(DSColors.textSecondary.opacity(0.7))
                    Text("0.34%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DSColors.textSecondary.opacity(0.7))
                }
            }
            
            // Sector selector with haptic feedback
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Sector.allCases) { sector in
                        DSPillChip(
                            title: sector.rawValue,
                            isSelected: viewModel.selectedSector == sector
                        ) {
                            // Haptic feedback for sector change
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                            
                            withAnimation(.easeOut(duration: 0.18)) {
                                viewModel.updateSector(sector)
                            }
                        }
                    }
                }
            }
            
            // Heatmap grid with crossfade animation on sector change
            if viewModel.isLoadingSectorData {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 95, maximum: 120), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(0..<12, id: \.self) { _ in
                        SkeletonTile()
                    }
                }
                .transition(.opacity)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 95, maximum: 120), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    ForEach(viewModel.sectorTiles) { tile in
                        NavigationLink(destination: TickerDetailView(ticker: Ticker(symbol: tile.ticker, name: tile.companyName))) {
                            DSHeatmapTile(tile: tile)
                                .frame(height: 62)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(16)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(DSColors.border.opacity(0.5), lineWidth: 0.5)
        )
    }
    
    private var futuresMarketsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DSBrowseSectionHeader(title: "Futures markets")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.futuresContracts) { contract in
                        Button(action: {
                            // Future detail action (placeholder)
                        }) {
                            DSFutureCard(contract: contract)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
    }
    
    private var economicEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            DSBrowseSectionHeader(title: "Economic events")
            
            VStack(spacing: 10) {
                ForEach(viewModel.economicEvents) { event in
                    Button(action: {
                        // Show detail sheet (placeholder)
                    }) {
                        DSEconomicEventRow(event: event)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Placeholder Tab Content
    
    private var placeholderTabContent: some View {
        emptyStateFor(tab: viewModel.selectedTab)
    }
    
    private func emptyStateFor(tab: MarketTab) -> some View {
        VStack(spacing: 18) {
            Image(systemName: iconFor(tab))
                .font(.system(size: 56, weight: .light))
                .foregroundColor(DSColors.textSecondary.opacity(0.4))
            
            VStack(spacing: 6) {
                Text("\(tab.rawValue) Coming Soon")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                
                Text("This section is under development")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(DSColors.textSecondary.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    private func iconFor(_ tab: MarketTab) -> String {
        switch tab {
        case .now: return "clock"
        case .macro: return "chart.line.uptrend.xyaxis"
        case .crypto: return "bitcoinsign.circle"
        case .sports: return "sportscourt"
        }
    }
}

// MARK: - Skeleton Tile

struct SkeletonTile: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(DSColors.surface.opacity(0.3))
            .frame(height: 62)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        DSColors.surface.opacity(0.5),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 200 : -200)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BrowseView()
            .environmentObject(WatchlistStore())
            .environmentObject(ForecastStore())
    }
}
