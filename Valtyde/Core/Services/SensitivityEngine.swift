import Foundation

enum SensitivityEngine {
    static func analyze(assumptions: ForecastAssumptions, horizonYears: Int = 5) -> SensitivityResult {
        let cagrOffsets: [Double] = [-0.02, -0.01, 0, 0.01, 0.02]
        let multipleOffsets: [Double] = [-2, -1, 0, 1, 2]

        let cagrValues = cagrOffsets.map { assumptions.revenueCagr + $0 }
        let multipleValues = multipleOffsets.map { assumptions.exitMultiple + $0 }

        let grid = cagrValues.map { cagr in
            multipleValues.map { multiple in
                let input = ForecastAssumptions(
                    currentPrice: assumptions.currentPrice,
                    currentRevenue: assumptions.currentRevenue,
                    revenueCagr: cagr,
                    operatingMargin: assumptions.operatingMargin,
                    taxRate: assumptions.taxRate,
                    sharesOutstanding: assumptions.sharesOutstanding,
                    netDebt: assumptions.netDebt,
                    exitMultiple: max(multiple, 0.1),
                    horizonYears: horizonYears,
                    discountRate: assumptions.discountRate
                )

                let result = ForecastEngine.forecast(
                    ticker: Ticker(symbol: "SENSE", name: "Sensitivity"),
                    assumptions: input,
                    horizons: [horizonYears]
                )
                return result.returnsByHorizon.first?.annualizedReturn ?? 0
            }
        }

        return SensitivityResult(
            grid: grid,
            cagrValues: cagrValues,
            multipleValues: multipleValues
        )
    }
}
