import Foundation

struct ForecastResult: Hashable, Codable {
    var fairValue: Double
    var currentPrice: Double
    var upsidePercent: Double
    var projections: [ProjectionRow]
    var returnsByHorizon: [ReturnSummary]
}

struct ProjectionRow: Hashable, Codable, Identifiable {
    let id: Int
    let year: Int
    let revenue: Double
    let operatingIncome: Double
    let afterTaxOperatingIncome: Double
    let impliedEnterpriseValue: Double
    let impliedEquityValue: Double
    let impliedPrice: Double
}

struct ReturnSummary: Hashable, Codable, Identifiable {
    let id: Int
    let horizonYears: Int
    let totalReturn: Double
    let annualizedReturn: Double
}
