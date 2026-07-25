import Foundation

// MARK: - Market Tabs

enum MarketTab: String, CaseIterable, Identifiable {
    case now = "Now"
    case macro = "Macro"
    case crypto = "Crypto"
    case sports = "Sports"
    
    var id: String { rawValue }
}

// MARK: - Top Movers

struct MoverItem: Identifiable, Hashable {
    let id: String
    let ticker: String
    let companyName: String
    let price: Double
    let percentChange: Double
    
    init(ticker: String, companyName: String, price: Double, percentChange: Double) {
        self.id = ticker
        self.ticker = ticker
        self.companyName = companyName
        self.price = price
        self.percentChange = percentChange
    }
}

// MARK: - Sectors

enum Sector: String, CaseIterable, Identifiable {
    case technology = "Technology"
    case finance = "Finance"
    case energy = "Energy"
    case healthcare = "Healthcare"
    case consumer = "Consumer"
    case industrials = "Industrials"
    
    var id: String { rawValue }
}

struct SectorTile: Identifiable, Hashable {
    let id: String
    let ticker: String
    let companyName: String
    let percentChange: Double
    let sector: Sector
    
    init(ticker: String, companyName: String, percentChange: Double, sector: Sector) {
        self.id = ticker
        self.ticker = ticker
        self.companyName = companyName
        self.percentChange = percentChange
        self.sector = sector
    }
}

// MARK: - Futures

struct FutureContract: Identifiable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let price: Double
    let percentChange: Double
    let sparklinePoints: [Double]
    
    init(name: String, symbol: String, price: Double, percentChange: Double, sparklinePoints: [Double]) {
        self.id = symbol
        self.name = name
        self.symbol = symbol
        self.price = price
        self.percentChange = percentChange
        self.sparklinePoints = sparklinePoints
    }
}

// MARK: - Economic Events

struct EconomicEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let date: Date
    let description: String
    
    init(title: String, date: Date, description: String) {
        self.id = UUID().uuidString
        self.title = title
        self.date = date
        self.description = description
    }
}

// MARK: - Search Results

struct TickerSearchResult: Identifiable, Hashable {
    let id: String
    let ticker: String
    let companyName: String
    let price: Double
    let percentChange: Double
    
    init(ticker: String, companyName: String, price: Double, percentChange: Double) {
        self.id = ticker
        self.ticker = ticker
        self.companyName = companyName
        self.price = price
        self.percentChange = percentChange
    }
}
