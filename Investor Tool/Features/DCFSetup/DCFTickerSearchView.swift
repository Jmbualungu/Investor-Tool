//
//  DCFTickerSearchView.swift
//  Investor Tool
//
//  Ticker search screen for DCF Setup Flow
//

import SwiftUI

struct DCFTickerSearchView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @State private var searchQuery: String = ""
    @State private var searchResults: [DCFTicker] = []
    @FocusState private var isSearchFocused: Bool
    
    let onSelectTicker: (DCFTicker) -> Void
    
    private var repository: TickerRepository {
        TickerRepository.shared
    }
    
    private var displayedTickers: [DCFTicker] {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? repository.popularTickers
            : searchResults
    }
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Search Field
                    searchField
                    
                    // Popular/Results Section
                    if searchQuery.isEmpty && !isSearchFocused {
                        popularSection
                    } else {
                        resultsSection
                    }
                }
                .padding(DSSpacing.l)
            }
        }
        .premiumFlowChrome(
            step: .ticker,
            flowState: flowState
        )
        .navigationTitle("Find a Company")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            searchResults = repository.popularTickers
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
                            onSelectTicker(ticker)
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
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    private func tickerRow(_ ticker: DCFTicker) -> some View {
        Button {
            onSelectTicker(ticker)
        } label: {
            HStack(spacing: DSSpacing.m) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: DSSpacing.s) {
                        Text(ticker.symbol)
                            .font(DSTypography.headline)
                            .foregroundColor(DSColors.textPrimary)
                        
                        // Sector tag
                        Text(ticker.sector)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(DSColors.textSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(DSColors.surface2)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    
                    Text(ticker.name)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
                
                Spacer()
                
                // Watchlist button
                watchlistButton(for: ticker)
            }
            .padding(DSSpacing.m)
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
    
    // MARK: - Search Logic
    
    private func performSearch(_ query: String) {
        searchResults = repository.search(query: query)
    }
}

#Preview {
    NavigationStack {
        DCFTickerSearchView(onSelectTicker: { _ in })
            .environmentObject(DCFFlowState())
    }
}
