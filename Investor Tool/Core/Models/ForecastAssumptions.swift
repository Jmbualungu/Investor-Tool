import Foundation

struct ForecastAssumptions: Hashable, Codable {
    var currentPrice: Double
    var currentRevenue: Double
    var revenueCagr: Double
    var operatingMargin: Double
    var taxRate: Double
    var sharesOutstanding: Double
    var netDebt: Double
    var exitMultiple: Double
    var horizonYears: Int
    var discountRate: Double?

    static let `default` = ForecastAssumptions(
        currentPrice: 100,
        currentRevenue: 1_000,
        revenueCagr: 0.08,
        operatingMargin: 0.22,
        taxRate: 0.21,
        sharesOutstanding: 1_000,
        netDebt: 0,
        exitMultiple: 4,
        horizonYears: 5,
        discountRate: nil
    )
}
