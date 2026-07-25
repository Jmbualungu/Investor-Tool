import Foundation
import Combine

enum AppTab: Hashable {
    case home
    case browse
    case history
    case settings
}

final class TabSelectionStore: ObservableObject {
    @Published var selectedTab: AppTab = .home
}
