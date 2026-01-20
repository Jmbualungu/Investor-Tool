import Foundation
import Combine
import SwiftData

@MainActor
final class AppItemStore: ObservableObject {
    @Published private(set) var items: [AppItem] = []
    private var modelContext: ModelContext?
    private var isConfigured = false

    func configure(modelContext: ModelContext) {
        guard !isConfigured else { return }
        self.modelContext = modelContext
        isConfigured = true
        seedIfEmpty()
        refresh()
    }

    func refresh() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<AppItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            items = try modelContext.fetch(descriptor)
        } catch {
            items = []
            print("AppItemStore refresh failed:", error.localizedDescription)
        }
    }

    @discardableResult
    func addItem(title: String, input: String, output: String) -> AppItem {
        let item = AppItem(title: title, input: input, output: output)
        guard let modelContext else { return item }
        modelContext.insert(item)
        save()
        refresh()
        print("AppItemStore added item:", item.title)
        return item
    }

    func deleteItem(at offsets: IndexSet) {
        guard let modelContext else { return }
        offsets.map { items[$0] }.forEach { item in
            modelContext.delete(item)
        }
        save()
        refresh()
        print("AppItemStore deleted items at:", offsets)
    }

    func seedIfEmpty() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<AppItem>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }
        MockData.appItems.forEach { item in
            modelContext.insert(item)
        }
        save()
        print("AppItemStore seeded mock items.")
    }

    private func save() {
        do {
            try modelContext?.save()
        } catch {
            print("AppItemStore save failed:", error.localizedDescription)
        }
    }
}
