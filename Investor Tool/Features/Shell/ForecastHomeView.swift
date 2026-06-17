//
//  ForecastHomeView.swift
//  Investor Tool
//
//  Forecast tab - main entry point for starting DCF valuations
//

import SwiftUI

struct ForecastHomeView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @StateObject private var quotes = QuoteStore()
    @State private var path: [Route] = []
    @State private var searchQuery: String = ""
    @State private var searchResults: [DCFTicker] = []
    @FocusState private var isSearchFocused: Bool
    
    private var repository: TickerRepository {
        TickerRepository.shared
    }
    
    private var displayedTickers: [DCFTicker] {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? repository.popularTickers
            : searchResults
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                DSColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xl) {
                        // Hero Section
                        heroSection
                        
                        // Search Field
                        searchField
                        
                        // Popular / Results
                        if searchQuery.isEmpty && !isSearchFocused {
                            popularSection
                        } else {
                            resultsSection
                        }
                    }
                    .padding(DSSpacing.l)
                    .padding(.bottom, 90) // clearance for the floating tab bar
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Forecast")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Route.self) { route in
                routeDestination(for: route)
            }
            .onAppear {
                searchResults = repository.popularTickers
                loadQuotes(for: repository.popularTickers)
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack(spacing: DSSpacing.s) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(DSColors.accent)
                
                Text("Start a Forecast")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
            }
            
            Text("Build a DCF valuation model for any company. Search below or select from popular tickers.")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Search Field
    
    private var searchField: some View {
        HStack(spacing: DSSpacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DSColors.textSecondary)
            
            TextField("Type a ticker (e.g., AAPL)", text: $searchQuery)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isSearchFocused)
                .onChange(of: searchQuery) { _, newValue in
                    performSearch(newValue)
                }
            
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                    searchResults = repository.popularTickers
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.l)
        .frame(height: DSSpacing.buttonHeightStandard)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Popular Section
    
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Popular")
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
            
            // Horizontal chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s) {
                    ForEach(repository.popularTickers) { ticker in
                        DSPillChip(
                            title: ticker.symbol,
                            isSelected: false
                        ) {
                            selectTicker(ticker)
                        }
                    }
                }
            }
            
            // List view
            tickerList(displayedTickers)
        }
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            if !displayedTickers.isEmpty {
                Text("Results")
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColors.textSecondary)
                
                tickerList(displayedTickers)
            } else {
                emptyState
            }
        }
    }
    
    // MARK: - Ticker List
    
    private func tickerList(_ tickers: [DCFTicker]) -> some View {
        VStack(spacing: 0) {
            ForEach(tickers) { ticker in
                tickerRow(ticker)
                
                if ticker.id != tickers.last?.id {
                    Divider()
                        .background(DSColors.border)
                }
            }
        }
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    private func tickerRow(_ ticker: DCFTicker) -> some View {
        Button {
            HapticManager.shared.impact(style: .light)
            selectTicker(ticker)
        } label: {
            HStack(spacing: DSSpacing.m) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(ticker.symbol)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)

                    Text("\(ticker.name) · \(ticker.sector)")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: DSSpacing.m)

                // Live price + intraday change (over the course of the day)
                VStack(alignment: .trailing, spacing: 4) {
                    let quote = quotes.quote(for: ticker.symbol)
                    let day = quote.intradayLabel

                    Text(Formatters.formatCurrency(quote.price))
                        .font(.system(size: 15, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundColor(DSColors.textPrimary)

                    Text(day.text)
                        .font(.system(size: 11, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundColor(day.color)
                }

                // Watchlist button
                watchlistButton(for: ticker)
            }
            .padding(DSSpacing.l)
            .frame(minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func watchlistButton(for ticker: DCFTicker) -> some View {
        Button {
            HapticManager.shared.impact(style: .light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                flowState.toggleWatchlist(symbol: ticker.symbol)
            }
        } label: {
            Image(systemName: flowState.isInWatchlist(symbol: ticker.symbol) ? "checkmark.circle.fill" : "plus.circle")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(flowState.isInWatchlist(symbol: ticker.symbol) ? DSColors.accent : DSColors.textSecondary)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DSSpacing.m) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(DSColors.textSecondary)
            
            Text("No results found")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            Text("Try searching for a different ticker symbol or company name")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xl)
    }
    
    // MARK: - Helpers
    
    private func selectTicker(_ ticker: DCFTicker) {
        flowState.selectedTicker = ticker
        flowState.generateRevenueDrivers()
        path.append(.companyContext)
    }

    private func performSearch(_ query: String) {
        searchResults = repository.search(query: query)
        loadQuotes(for: searchResults)
    }

    /// Fetch live quotes for the visible tickers (live with mock fallback).
    private func loadQuotes(for tickers: [DCFTicker]) {
        let symbols = tickers.map(\.symbol)
        Task { await quotes.load(symbols: symbols) }
    }
    
    @ViewBuilder
    private func routeDestination(for route: Route) -> some View {
        switch route {
        case .companyContext:
            if let ticker = flowState.selectedTicker {
                CompanyContextView(ticker: ticker) {
                    path.append(.investmentLens)
                }
            }
            
        case .investmentLens:
            InvestmentLensView {
                path.append(.revenueDrivers)
            }
            
        case .revenueDrivers:
            RevenueDriversView {
                path.append(.operatingAssumptions)
            }
            
        case .operatingAssumptions:
            OperatingAssumptionsView {
                path.append(.valuationAssumptions)
            }
            
        case .valuationAssumptions:
            ValuationAssumptionsView {
                path.append(.valuationResults)
            }
            
        case .valuationResults:
            ValuationResultsView {
                path.append(.sensitivity)
            }
            
        case .sensitivity:
            SensitivityAnalysisView()
            
        default:
            EmptyView()
        }
    }
}

#Preview {
    ForecastHomeView()
        .environmentObject(DCFFlowState())
}
