import Foundation
import Combine

final class ReturnsViewModel: ObservableObject {
    @Published var metrics: [ReturnSummary] = []

    func compute(from result: ForecastResult?) {
        guard let result else {
            metrics = []
            return
        }
        metrics = result.returnsByHorizon
    }
}
