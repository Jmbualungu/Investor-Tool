import Foundation
import Combine

final class TimeframePickerViewModel: ObservableObject {
    @Published var selectedHorizonIndex: Int = 0
    @Published var showSensitivity: Bool = false
    
    let horizons = ["1Y", "3Y", "5Y", "10Y"]
    
    var selectedYears: Int {
        switch selectedHorizonIndex {
        case 0: return 1
        case 1: return 3
        case 2: return 5
        case 3: return 10
        default: return 5
        }
    }
    
    func reset() {
        selectedHorizonIndex = 0
        showSensitivity = false
    }
}
