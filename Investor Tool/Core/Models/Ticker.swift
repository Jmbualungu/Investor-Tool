import Foundation

struct Ticker: Identifiable, Hashable, Codable {
    let id: String
    let symbol: String
    let name: String
    let popularityRank: Int

    init(
        id: String? = nil,
        symbol: String,
        name: String,
        popularityRank: Int = 999
    ) {
        let normalizedSymbol = symbol.uppercased()
        self.id = id ?? normalizedSymbol
        self.symbol = normalizedSymbol
        self.name = name
        self.popularityRank = popularityRank
    }
}
