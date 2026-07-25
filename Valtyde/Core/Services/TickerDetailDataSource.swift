import Foundation

/// Protocol defining the interface for fetching ticker detail data
/// This abstraction allows easy swapping between mock and real API implementations
protocol TickerDetailDataSource {
    /// Fetches comprehensive ticker detail data for the given symbol
    /// - Parameter symbol: The stock ticker symbol (e.g., "AAPL", "MSFT")
    /// - Returns: Complete ticker detail data including profile, stats, news, and analyst ratings
    /// - Throws: An error if the data fetch fails
    func fetchTickerDetail(symbol: String) async throws -> TickerDetailData
}
