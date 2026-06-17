//
//  LiveMarketDataService.swift
//  Investor Tool
//
//  Live stock quotes from Finnhub — the same provider the marketing site uses.
//

import Foundation

/// Fetches live quotes from Finnhub's `/quote` endpoint.
///
/// Reads `FINNHUB_API_KEY` from the app's Info.plist (populated from
/// `Config/Secrets.xcconfig`). When the key is missing or a request fails, the
/// service returns `nil` so callers can fall back to mock data — mirroring the
/// website's graceful degradation. Responses are cached for 60s per symbol to
/// stay under the Finnhub free-tier rate limit (matches the web's `revalidate`).
actor LiveMarketDataService {

    static let shared = LiveMarketDataService()

    private struct CacheEntry {
        let quote: Quote
        let fetchedAt: Date
    }

    /// Usable API key, or `nil` when unset / still the placeholder.
    private let apiKey: String?
    private var cache: [String: CacheEntry] = [:]
    private let ttl: TimeInterval = 60

    init() {
        let raw = Bundle.main.object(forInfoDictionaryKey: "FINNHUB_API_KEY") as? String
        if let raw, !raw.isEmpty, !raw.contains("YOUR_FINNHUB_KEY_HERE") {
            self.apiKey = raw
        } else {
            self.apiKey = nil
        }
    }

    /// True when a real API key is configured (immutable `let`, safe off-actor).
    nonisolated var isConfigured: Bool { apiKey != nil }

    /// Live quote for a single symbol, or `nil` when unconfigured / unavailable.
    func quote(symbol: String) async -> Quote? {
        guard let apiKey else { return nil }
        let key = symbol.uppercased()

        if let entry = cache[key], Date().timeIntervalSince(entry.fetchedAt) < ttl {
            return entry.quote
        }

        guard let encoded = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(encoded)&token=\(apiKey)")
        else { return nil }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            let raw = try JSONDecoder().decode(FinnhubQuote.self, from: data)
            // c == 0 means Finnhub has no data for the symbol (e.g. unknown ticker).
            guard let current = raw.c, current != 0 else { return nil }

            let quote = Quote(
                symbol: key,
                price: current,
                change: raw.d ?? 0,
                changePercent: raw.dp ?? 0
            )
            cache[key] = CacheEntry(quote: quote, fetchedAt: Date())
            return quote
        } catch {
            return nil
        }
    }

    /// Live quotes for many symbols, fetched concurrently. Symbols without a
    /// live quote are simply absent from the returned dictionary.
    func quotes(for symbols: [String]) async -> [String: Quote] {
        guard apiKey != nil else { return [:] }

        return await withTaskGroup(of: Quote?.self) { group in
            for symbol in symbols {
                group.addTask { await self.quote(symbol: symbol) }
            }
            var result: [String: Quote] = [:]
            for await quote in group {
                if let quote { result[quote.symbol] = quote }
            }
            return result
        }
    }

    /// Subset of Finnhub's `/quote` payload we use.
    private struct FinnhubQuote: Decodable {
        let c: Double?   // current price
        let d: Double?   // change
        let dp: Double?  // percent change
    }
}
