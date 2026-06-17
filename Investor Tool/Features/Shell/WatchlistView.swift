//
//  WatchlistView.swift
//  Investor Tool
//
//  Watchlist tab with mock prices and sparklines
//

import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @StateObject private var quotes = QuoteStore()
    @State private var path: [Route] = []

    private var watchedTickers: [DCFTicker] {
        let repository = TickerRepository.shared
        return Array(flowState.watchlistSymbols)
            .compactMap { symbol in
                repository.findTicker(bySymbol: symbol)
            }
            .sorted { marginOfSafety(for: $0) > marginOfSafety(for: $1) }
    }

    // Deterministic value/price ratio per symbol (0.80–1.25) — a demo intrinsic
    // multiplier until live DCF valuations feed the gauge.
    private func valueFactor(for symbol: String) -> Double {
        var h: UInt64 = 1469598103934665603
        for b in symbol.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
        return 0.80 + Double(h % 1000) / 1000.0 * 0.45
    }

    // Demo intrinsic value anchored to the live price so the gauge stays sensible.
    private func demoIntrinsicValue(for ticker: DCFTicker) -> Double {
        quotes.quote(for: ticker.symbol).price * valueFactor(for: ticker.symbol)
    }

    // Margin of safety is the value/price gap — equal to valueFactor − 1, so the
    // ordering is stable whether prices are live or mock.
    private func marginOfSafety(for ticker: DCFTicker) -> Double {
        valueFactor(for: ticker.symbol) - 1
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
                        .padding(.bottom, 80) // clearance for the floating tab bar
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Route.self) { route in
                routeDestination(for: route)
            }
            .task(id: flowState.watchlistSymbols) {
                await quotes.load(symbols: watchedTickers.map(\.symbol))
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
                // Left: micro Value Gauge — predicted value vs live market price
                let quote = quotes.quote(for: ticker.symbol)
                let price = quote.price
                let value = demoIntrinsicValue(for: ticker)
                let mos = marginOfSafety(for: ticker)
                let isUnder = mos >= 0
                let isFair = abs(mos) < 0.02

                MicroValueGauge(price: price, value: value)

                // Middle: Symbol + Name
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticker.symbol)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)

                    Text(ticker.name)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer(minLength: DSSpacing.m)

                // Right: live price, intraday change, margin of safety
                VStack(alignment: .trailing, spacing: 3) {
                    Text(Formatters.formatCurrency(price))
                        .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundColor(DSColors.textPrimary)

                    Text(quote.intradayLabel.text)
                        .font(.system(size: 10.5, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundColor(quote.intradayLabel.color)

                    Text(
                        isFair
                            ? String(format: "fair · %+.1f%%", mos * 100)
                            : isUnder
                                ? String(format: "+%.0f%% safety", mos * 100)
                                : String(format: "%.0f%% rich", mos * 100)
                    )
                    .font(.system(size: 10.5, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundColor(isFair ? DSColors.sky : (isUnder ? DSColors.positive : DSColors.negative))
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
