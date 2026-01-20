import Foundation

enum Validators {
    static func isValidGrowthRate(_ value: Double) -> Bool {
        value >= -0.5 && value <= 1.0
    }

    static func isValidMargin(_ value: Double) -> Bool {
        value >= 0 && value <= 0.8
    }

    static func isValidHorizon(_ value: Int) -> Bool {
        value >= 1 && value <= 30
    }
}
