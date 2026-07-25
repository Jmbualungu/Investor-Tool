import Foundation

final class StubMarketDataService {
    static let shared = StubMarketDataService()
    
    private init() {}
    
    // MARK: - Top Movers
    
    func getTopMovers() -> [MoverItem] {
        return [
            MoverItem(ticker: "RIOT", companyName: "Riot Platforms", price: 12.45, percentChange: 16.54),
            MoverItem(ticker: "ASTS", companyName: "AST SpaceMobile", price: 28.32, percentChange: 15.06),
            MoverItem(ticker: "FLY", companyName: "Fly Leasing", price: 15.67, percentChange: 12.27),
            MoverItem(ticker: "AGX", companyName: "Argan Inc", price: 42.18, percentChange: 16.38),
            MoverItem(ticker: "FIGR", companyName: "Figr Inc", price: 8.92, percentChange: 14.89),
            MoverItem(ticker: "IREN", companyName: "Iris Energy", price: 11.34, percentChange: 12.20),
            MoverItem(ticker: "MARA", companyName: "Marathon Digital", price: 16.78, percentChange: 13.45),
            MoverItem(ticker: "CLSK", companyName: "CleanSpark", price: 9.87, percentChange: 14.21),
            MoverItem(ticker: "HUT", companyName: "Hut 8 Mining", price: 7.23, percentChange: 12.89),
            MoverItem(ticker: "BTBT", companyName: "Bit Digital", price: 3.45, percentChange: 15.67)
        ]
    }
    
    // MARK: - Sector Tiles
    
    func getSectorTiles(for sector: Sector) -> [SectorTile] {
        switch sector {
        case .technology:
            return [
                SectorTile(ticker: "NVDA", companyName: "NVIDIA", percentChange: -0.43, sector: .technology),
                SectorTile(ticker: "MSFT", companyName: "Microsoft", percentChange: 0.88, sector: .technology),
                SectorTile(ticker: "GOOG", companyName: "Alphabet", percentChange: -0.99, sector: .technology),
                SectorTile(ticker: "GOOGL", companyName: "Alphabet Class A", percentChange: -0.97, sector: .technology),
                SectorTile(ticker: "AAPL", companyName: "Apple", percentChange: -1.16, sector: .technology),
                SectorTile(ticker: "META", companyName: "Meta", percentChange: -0.10, sector: .technology),
                SectorTile(ticker: "AMZN", companyName: "Amazon", percentChange: 0.27, sector: .technology),
                SectorTile(ticker: "TSM", companyName: "Taiwan Semiconductor", percentChange: 0.30, sector: .technology),
                SectorTile(ticker: "AVGO", companyName: "Broadcom", percentChange: 2.62, sector: .technology),
                SectorTile(ticker: "ORCL", companyName: "Oracle", percentChange: 1.24, sector: .technology),
                SectorTile(ticker: "ASML", companyName: "ASML", percentChange: 0.89, sector: .technology),
                SectorTile(ticker: "MU", companyName: "Micron", percentChange: 1.45, sector: .technology),
                SectorTile(ticker: "PLTR", companyName: "Palantir", percentChange: -0.67, sector: .technology),
                SectorTile(ticker: "NFLX", companyName: "Netflix", percentChange: -0.34, sector: .technology),
                SectorTile(ticker: "ADBE", companyName: "Adobe", percentChange: 0.56, sector: .technology)
            ]
        case .finance:
            return [
                SectorTile(ticker: "JPM", companyName: "JPMorgan Chase", percentChange: 1.12, sector: .finance),
                SectorTile(ticker: "BAC", companyName: "Bank of America", percentChange: 0.89, sector: .finance),
                SectorTile(ticker: "WFC", companyName: "Wells Fargo", percentChange: 0.67, sector: .finance),
                SectorTile(ticker: "GS", companyName: "Goldman Sachs", percentChange: 1.45, sector: .finance),
                SectorTile(ticker: "MS", companyName: "Morgan Stanley", percentChange: 0.98, sector: .finance),
                SectorTile(ticker: "C", companyName: "Citigroup", percentChange: -0.34, sector: .finance),
                SectorTile(ticker: "BLK", companyName: "BlackRock", percentChange: 0.78, sector: .finance),
                SectorTile(ticker: "SCHW", companyName: "Charles Schwab", percentChange: 1.23, sector: .finance),
                SectorTile(ticker: "AXP", companyName: "American Express", percentChange: 0.45, sector: .finance),
                SectorTile(ticker: "USB", companyName: "U.S. Bancorp", percentChange: 1.02, sector: .finance),
                SectorTile(ticker: "PNC", companyName: "PNC Financial", percentChange: 0.67, sector: .finance),
                SectorTile(ticker: "TFC", companyName: "Truist Financial", percentChange: -0.23, sector: .finance)
            ]
        case .energy:
            return [
                SectorTile(ticker: "XOM", companyName: "Exxon Mobil", percentChange: 0.89, sector: .energy),
                SectorTile(ticker: "CVX", companyName: "Chevron", percentChange: 1.12, sector: .energy),
                SectorTile(ticker: "COP", companyName: "ConocoPhillips", percentChange: 0.67, sector: .energy),
                SectorTile(ticker: "SLB", companyName: "Schlumberger", percentChange: 1.34, sector: .energy),
                SectorTile(ticker: "EOG", companyName: "EOG Resources", percentChange: 0.45, sector: .energy),
                SectorTile(ticker: "MPC", companyName: "Marathon Petroleum", percentChange: 0.78, sector: .energy),
                SectorTile(ticker: "PSX", companyName: "Phillips 66", percentChange: 0.56, sector: .energy),
                SectorTile(ticker: "VLO", companyName: "Valero Energy", percentChange: -0.23, sector: .energy),
                SectorTile(ticker: "OXY", companyName: "Occidental Petroleum", percentChange: 1.45, sector: .energy),
                SectorTile(ticker: "HAL", companyName: "Halliburton", percentChange: 0.89, sector: .energy)
            ]
        case .healthcare:
            return [
                SectorTile(ticker: "UNH", companyName: "UnitedHealth", percentChange: 0.67, sector: .healthcare),
                SectorTile(ticker: "JNJ", companyName: "Johnson & Johnson", percentChange: 0.45, sector: .healthcare),
                SectorTile(ticker: "LLY", companyName: "Eli Lilly", percentChange: 1.89, sector: .healthcare),
                SectorTile(ticker: "PFE", companyName: "Pfizer", percentChange: -0.34, sector: .healthcare),
                SectorTile(ticker: "ABBV", companyName: "AbbVie", percentChange: 0.78, sector: .healthcare),
                SectorTile(ticker: "TMO", companyName: "Thermo Fisher", percentChange: 0.56, sector: .healthcare),
                SectorTile(ticker: "ABT", companyName: "Abbott Labs", percentChange: 0.89, sector: .healthcare),
                SectorTile(ticker: "DHR", companyName: "Danaher", percentChange: 0.67, sector: .healthcare),
                SectorTile(ticker: "MRK", companyName: "Merck", percentChange: 0.34, sector: .healthcare),
                SectorTile(ticker: "BMY", companyName: "Bristol Myers", percentChange: -0.23, sector: .healthcare),
                SectorTile(ticker: "AMGN", companyName: "Amgen", percentChange: 0.45, sector: .healthcare),
                SectorTile(ticker: "GILD", companyName: "Gilead Sciences", percentChange: 0.67, sector: .healthcare)
            ]
        case .consumer:
            return [
                SectorTile(ticker: "TSLA", companyName: "Tesla", percentChange: -1.44, sector: .consumer),
                SectorTile(ticker: "WMT", companyName: "Walmart", percentChange: 0.45, sector: .consumer),
                SectorTile(ticker: "HD", companyName: "Home Depot", percentChange: 0.67, sector: .consumer),
                SectorTile(ticker: "MCD", companyName: "McDonald's", percentChange: 0.34, sector: .consumer),
                SectorTile(ticker: "NKE", companyName: "Nike", percentChange: -0.56, sector: .consumer),
                SectorTile(ticker: "SBUX", companyName: "Starbucks", percentChange: 0.78, sector: .consumer),
                SectorTile(ticker: "TGT", companyName: "Target", percentChange: 0.45, sector: .consumer),
                SectorTile(ticker: "LOW", companyName: "Lowe's", percentChange: 0.56, sector: .consumer),
                SectorTile(ticker: "COST", companyName: "Costco", percentChange: 0.89, sector: .consumer),
                SectorTile(ticker: "DIS", companyName: "Disney", percentChange: -0.23, sector: .consumer),
                SectorTile(ticker: "PG", companyName: "Procter & Gamble", percentChange: 0.34, sector: .consumer),
                SectorTile(ticker: "KO", companyName: "Coca-Cola", percentChange: 0.23, sector: .consumer)
            ]
        case .industrials:
            return [
                SectorTile(ticker: "BA", companyName: "Boeing", percentChange: -0.67, sector: .industrials),
                SectorTile(ticker: "CAT", companyName: "Caterpillar", percentChange: 0.89, sector: .industrials),
                SectorTile(ticker: "GE", companyName: "General Electric", percentChange: 1.12, sector: .industrials),
                SectorTile(ticker: "HON", companyName: "Honeywell", percentChange: 0.45, sector: .industrials),
                SectorTile(ticker: "UPS", companyName: "United Parcel Service", percentChange: 0.67, sector: .industrials),
                SectorTile(ticker: "RTX", companyName: "Raytheon", percentChange: 0.34, sector: .industrials),
                SectorTile(ticker: "LMT", companyName: "Lockheed Martin", percentChange: 0.56, sector: .industrials),
                SectorTile(ticker: "DE", companyName: "Deere & Company", percentChange: 0.78, sector: .industrials),
                SectorTile(ticker: "MMM", companyName: "3M", percentChange: -0.23, sector: .industrials),
                SectorTile(ticker: "GD", companyName: "General Dynamics", percentChange: 0.45, sector: .industrials)
            ]
        }
    }
    
    // MARK: - Futures Contracts
    
    func getFuturesContracts() -> [FutureContract] {
        return [
            FutureContract(
                name: "S&P 500",
                symbol: "/MESH26",
                price: 6916.00,
                percentChange: -0.87,
                sparklinePoints: generateSparkline(baseValue: 6916, trend: .down, volatility: 0.01)
            ),
            FutureContract(
                name: "Nasdaq 100",
                symbol: "/MNQH26",
                price: 25384.50,
                percentChange: -1.19,
                sparklinePoints: generateSparkline(baseValue: 25384, trend: .down, volatility: 0.012)
            ),
            FutureContract(
                name: "Bitcoin",
                symbol: "/MBTF26",
                price: 92730.00,
                percentChange: -3.07,
                sparklinePoints: generateSparkline(baseValue: 92730, trend: .down, volatility: 0.03)
            ),
            FutureContract(
                name: "Crude Oil",
                symbol: "/CLH26",
                price: 78.45,
                percentChange: 0.56,
                sparklinePoints: generateSparkline(baseValue: 78.45, trend: .up, volatility: 0.015)
            ),
            FutureContract(
                name: "Gold",
                symbol: "/GCG26",
                price: 2045.30,
                percentChange: 0.34,
                sparklinePoints: generateSparkline(baseValue: 2045, trend: .up, volatility: 0.008)
            )
        ]
    }
    
    // MARK: - Economic Events
    
    func getEconomicEvents() -> [EconomicEvent] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            EconomicEvent(
                title: "Fed decision in Jan 2026",
                date: calendar.date(byAdding: .day, value: 10, to: now)!,
                description: "Federal Reserve interest rate decision"
            ),
            EconomicEvent(
                title: "CPI Report",
                date: calendar.date(byAdding: .day, value: 5, to: now)!,
                description: "Consumer Price Index monthly inflation data"
            ),
            EconomicEvent(
                title: "Jobs Report",
                date: calendar.date(byAdding: .day, value: 3, to: now)!,
                description: "Non-farm payrolls employment data"
            ),
            EconomicEvent(
                title: "GDP Release",
                date: calendar.date(byAdding: .day, value: 15, to: now)!,
                description: "Q4 2025 GDP preliminary estimate"
            ),
            EconomicEvent(
                title: "Retail Sales",
                date: calendar.date(byAdding: .day, value: 7, to: now)!,
                description: "December retail sales data"
            ),
            EconomicEvent(
                title: "PCE Index",
                date: calendar.date(byAdding: .day, value: 12, to: now)!,
                description: "Personal Consumption Expenditures price index"
            )
        ].sorted { $0.date < $1.date }
    }
    
    // MARK: - Search
    
    func searchTickers(query: String) -> [TickerSearchResult] {
        guard !query.isEmpty else { return [] }
        
        let normalizedQuery = query.uppercased()
        
        // Use existing ticker data from MockData
        let allTickers = MockData.tickers
        
        let results = allTickers.filter { ticker in
            // Prefix match on ticker OR substring match on company name
            ticker.symbol.hasPrefix(normalizedQuery) ||
            ticker.name.uppercased().contains(normalizedQuery)
        }
        
        // Convert to TickerSearchResult with stub prices
        return results.prefix(20).map { ticker in
            TickerSearchResult(
                ticker: ticker.symbol,
                companyName: ticker.name,
                price: generateStubPrice(for: ticker.symbol),
                percentChange: generateStubPercentChange()
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private enum Trend {
        case up, down, flat
    }
    
    private func generateSparkline(baseValue: Double, trend: Trend, volatility: Double) -> [Double] {
        var points: [Double] = []
        let pointCount = 25
        
        var currentValue = baseValue
        
        for i in 0..<pointCount {
            let trendComponent: Double
            switch trend {
            case .up:
                trendComponent = Double(i) * volatility * baseValue * 0.5
            case .down:
                trendComponent = -Double(i) * volatility * baseValue * 0.5
            case .flat:
                trendComponent = 0
            }
            
            let randomNoise = Double.random(in: -volatility...volatility) * baseValue
            currentValue = baseValue + trendComponent + randomNoise
            points.append(currentValue)
        }
        
        return points
    }
    
    private func generateStubPrice(for ticker: String) -> Double {
        // Generate deterministic but varied stub prices based on ticker
        let hash = ticker.hashValue
        let basePrice = Double(abs(hash % 500) + 10)
        return basePrice + Double(abs(hash % 100)) / 100.0
    }
    
    private func generateStubPercentChange() -> Double {
        return Double.random(in: -3.0...3.0)
    }
}

// Helper extension for MockData access
extension StubMarketDataService {
    private var mockTickers: [Ticker] {
        MockData.tickers
    }
}
