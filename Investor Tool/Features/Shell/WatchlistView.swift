//
//  WatchlistView.swift
//  Investor Tool
//
//  Watchlist tab with mock prices and sparklines
//

import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @State private var path: [Route] = []
    
    private var watchedTickers: [DCFTicker] {
        let repository = TickerRepository.shared
        return Array(flowState.watchlistSymbols)
            .compactMap { symbol in
                repository.findTicker(bySymbol: symbol)
            }
            .sorted { $0.symbol < $1.symbol }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                DSColors.background
                    .ignoresSafeArea()
                
                if watchedTickers.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(watchedTickers) { ticker in
                                watchlistRow(ticker)
                                
                                if ticker.id != watchedTickers.last?.id {
                                    Divider()
                                        .background(DSColors.border)
                                        .padding(.leading, DSSpacing.l)
                                }
                            }
                        }
                        .background(DSColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                                .stroke(DSColors.border, lineWidth: 1)
                        )
                        .padding(DSSpacing.l)
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Route.self) { route in
                routeDestination(for: route)
            }
        }
    }
    
    // MARK: - Watchlist Row
    
    private func watchlistRow(_ ticker: DCFTicker) -> some View {
        Button {
            HapticManager.shared.impact(style: .light)
            startForecast(for: ticker)
        } label: {
            HStack(spacing: DSSpacing.m) {
                // Left: Symbol + Name
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: DSSpacing.s) {
                        Text(ticker.symbol)
                            .font(DSTypography.headline)
                            .foregroundColor(DSColors.textPrimary)
                        
                        DSInlineBadge(ticker.sector, style: .neutral)
                    }
                    
                    Text(ticker.name)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer(minLength: DSSpacing.m)
                
                // Right: Price info + Sparkline
                VStack(alignment: .trailing, spacing: 6) {
                    let currentPrice = MarketMock.mockCurrentPrice(symbol: ticker.symbol)
                    let dayChange = MarketMock.mockDayChange(symbol: ticker.symbol)
                    let isPositive = dayChange.absolute >= 0
                    
                    // Current price
                    Text(Formatters.formatCurrency(currentPrice))
                        .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundColor(DSColors.textPrimary)
                    
                    // Day change
                    HStack(spacing: 4) {
                        Text(String(format: "%+.2f", dayChange.absolute))
                            .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                            .foregroundColor(isPositive ? DSColors.positive : DSColors.negative)
                        
                        Text(String(format: "(%+.2f%%)", dayChange.percent))
                            .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                            .foregroundColor(isPositive ? DSColors.positive : DSColors.negative)
                    }
                    
                    // Mini sparkline
                    let series = MarketMock.mockPriceSeries(symbol: ticker.symbol, range: .oneDay)
                    Sparkline(
                        points: series,
                        height: 24,
                        lineColor: isPositive ? DSColors.positive : DSColors.negative
                    )
                    .frame(width: 80)
                }
            }
            .padding(DSSpacing.l)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DSSpacing.l) {
            Image(systemName: "star.slash")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(DSColors.textSecondary)
            
            VStack(spacing: DSSpacing.s) {
                Text("No Watchlist Items")
                    .font(DSTypography.title)
                    .foregroundColor(DSColors.textPrimary)
                
                Text("Add tickers from the Forecast tab or search to track prices and quickly start valuations.")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.xl)
    }
    
    // MARK: - Navigation
    
    private func startForecast(for ticker: DCFTicker) {
        flowState.selectedTicker = ticker
        flowState.generateRevenueDrivers()
        path.append(.companyContext)
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
    WatchlistView()
        .environmentObject({
            let state = DCFFlowState()
            state.watchlistSymbols = ["AAPL", "TSLA", "MSFT"]
            return state
        }())
}
