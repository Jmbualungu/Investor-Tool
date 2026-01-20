import Foundation
import Combine

final class SensitivityViewModel: ObservableObject {
    @Published var result: SensitivityResult?

    func runSensitivity(assumptions: ForecastAssumptions) {
        result = SensitivityEngine.analyze(assumptions: assumptions)
    }
}
