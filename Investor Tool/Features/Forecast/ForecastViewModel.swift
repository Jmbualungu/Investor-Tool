import Foundation
import Combine

final class ForecastViewModel: ObservableObject {
    @Published var result: ForecastResult?

    func runForecast(ticker: Ticker, assumptions: ForecastAssumptions, horizons: [Int]) {
        result = ForecastEngine.forecast(ticker: ticker, assumptions: assumptions, horizons: horizons)
    }
}
