import Foundation

enum ForecastEngine {
    static func forecast(
        ticker: Ticker,
        assumptions: ForecastAssumptions,
        horizons: [Int]
    ) -> ForecastResult {
        let maxYear = max(10, horizons.max() ?? 10)
        let shares = max(assumptions.sharesOutstanding, 1e-6)
        let currentPrice = max(assumptions.currentPrice, 1e-6)

        let projections = (0...maxYear).map { year -> ProjectionRow in
            let revenue = assumptions.currentRevenue * pow(1 + assumptions.revenueCagr, Double(year))
            let operatingIncome = revenue * assumptions.operatingMargin
            let afterTaxOI = operatingIncome * (1 - assumptions.taxRate)
            let enterpriseValue = revenue * assumptions.exitMultiple
            let equityValue = enterpriseValue - assumptions.netDebt
            let impliedPrice = equityValue / shares
            return ProjectionRow(
                id: year,
                year: year,
                revenue: revenue,
                operatingIncome: operatingIncome,
                afterTaxOperatingIncome: afterTaxOI,
                impliedEnterpriseValue: enterpriseValue,
                impliedEquityValue: equityValue,
                impliedPrice: impliedPrice
            )
        }

        let returnsByHorizon = horizons
            .sorted()
            .map { horizon -> ReturnSummary in
                let row = projections.first { $0.year == horizon } ?? projections.last!
                let price = max(row.impliedPrice, 0)
                let totalReturn = (price / currentPrice) - 1
                let annualizedReturn = pow(price / currentPrice, 1 / Double(max(horizon, 1))) - 1
                return ReturnSummary(
                    id: horizon,
                    horizonYears: horizon,
                    totalReturn: totalReturn,
                    annualizedReturn: annualizedReturn
                )
            }

        let terminalRow = projections.last!
        let fairValue = terminalRow.impliedPrice
        let upsidePercent = (fairValue / currentPrice) - 1

        return ForecastResult(
            fairValue: fairValue,
            currentPrice: assumptions.currentPrice,
            upsidePercent: upsidePercent,
            projections: projections,
            returnsByHorizon: returnsByHorizon
        )
    }
}
