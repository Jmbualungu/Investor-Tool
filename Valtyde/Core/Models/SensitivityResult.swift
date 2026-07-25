import Foundation

struct SensitivityResult: Hashable, Codable {
    var grid: [[Double]]
    var cagrValues: [Double]
    var multipleValues: [Double]
}
