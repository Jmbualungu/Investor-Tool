import Foundation
import Combine

final class AssumptionsViewModel: ObservableObject {
    @Published var assumptions: ForecastAssumptions = .default
    @Published var ticker: Ticker?
}
