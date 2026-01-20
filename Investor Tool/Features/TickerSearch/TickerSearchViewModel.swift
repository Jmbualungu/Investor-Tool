import Foundation
import Combine

final class TickerSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var selectedTicker: Ticker?

    var matchedTickers: [Ticker] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return MockData.popularTickers }
        let normalized = trimmed.lowercased()

        return MockData.tickers
            .filter {
                $0.symbol.lowercased().hasPrefix(normalized)
                || $0.name.lowercased().contains(normalized)
            }
            .sorted {
                if $0.popularityRank != $1.popularityRank {
                    return $0.popularityRank < $1.popularityRank
                }
                return $0.symbol < $1.symbol
            }
    }

    var filteredTickers: [Ticker] {
        matchedTickers
    }

    var isValidQuery: Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !matchedTickers.isEmpty
    }

    var topResults: [Ticker] {
        Array(matchedTickers.prefix(6))
    }

    var moreResults: [Ticker] {
        Array(matchedTickers.dropFirst(6))
    }

    func finalizeSelection() -> Ticker? {
        if let selectedTicker {
            return selectedTicker
        }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return matchedTickers.first
    }
}
