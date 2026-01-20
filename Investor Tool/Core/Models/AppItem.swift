import Foundation
import SwiftData

@Model
final class AppItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var input: String
    var output: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        input: String,
        output: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.input = input
        self.output = output
        self.createdAt = createdAt
    }
}
