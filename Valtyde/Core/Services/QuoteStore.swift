//
//  QuoteStore.swift
//  Valtyde
//
//  Publishes live quotes to the UI, with a deterministic mock fallback.
//

import Combine
import Foundation
import SwiftUI

/// Drives live price + intraday-change UI for a set of symbols.
///
/// Live data comes from ``LiveMarketDataService`` (Finnhub). Any symbol without
/// a live quote — because the key is unset, the request failed, or it's still
/// loading — falls back to deterministic mock data via ``MarketMock`` so rows
/// always render. The UI reads quotes through ``quote(for:)`` and never has to
/// branch on live-vs-mock itself.
@MainActor
final class QuoteStore: ObservableObject {

    @Published private(set) var quotes: [String: Quote] = [:]
    /// True once at least one real live quote has been received.
    @Published private(set) var isLive: Bool = false

    private let service = LiveMarketDataService.shared

    /// The best available quote for a symbol — live if we have it, otherwise a
    /// deterministic mock so the row always shows a sensible price + change.
    func quote(for symbol: String) -> Quote {
        let key = symbol.uppercased()
        return quotes[key] ?? Self.mockQuote(for: key)
    }

    /// Fetch live quotes for the given symbols and merge them in. Falls back to
    /// mock for any symbol we don't already have and that came back without a
    /// live quote, so the UI is fully populated either way.
    func load(symbols: [String]) async {
        let unique = Array(Set(symbols.map { $0.uppercased() }))
        guard !unique.isEmpty else { return }

        let live = await service.quotes(for: unique)

        var merged = quotes
        for symbol in unique {
            if let liveQuote = live[symbol] {
                merged[symbol] = liveQuote
            } else if merged[symbol] == nil {
                merged[symbol] = Self.mockQuote(for: symbol)
            }
        }
        quotes = merged
        if !live.isEmpty { isLive = true }
    }

    /// Deterministic offline quote built from the existing mock generators.
    static func mockQuote(for symbol: String) -> Quote {
        let price = MarketMock.mockCurrentPrice(symbol: symbol)
        let change = MarketMock.mockDayChange(symbol: symbol)
        return Quote(
            symbol: symbol.uppercased(),
            price: price,
            change: change.absolute,
            changePercent: change.percent
        )
    }
}

extension Quote {
    /// Presentation for the "% today" intraday line: formatted text + the
    /// semantic color (green up, red down, sky when ~flat) and a ▲/▼/◆ marker.
    var intradayLabel: (text: String, color: Color) {
        let arrow = changePercent > 0.01 ? "▲" : (changePercent < -0.01 ? "▼" : "◆")
        let color: Color = changePercent > 0.01
            ? DSColors.positive
            : (changePercent < -0.01 ? DSColors.negative : DSColors.sky)
        return (String(format: "%+.2f%% today %@", changePercent, arrow), color)
    }
}
