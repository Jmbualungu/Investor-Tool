import Foundation
import SwiftUI
import SwiftData
import Combine

/// ViewModel for assumptions template view
@MainActor
class AssumptionsTemplateViewModel: ObservableObject {
    @Published var selectedEntity: EntityID = .aapl
    @Published var selectedHorizon: Horizon = .fiveYear
    @Published var currentTemplate: EntityAssumptionsTemplate?
    @Published var previewResult: ForecastPreviewEngine.PreviewResult?
    @Published var showProjectDuplicationPlaceholder = false
    
    private let store: AssumptionTemplateStore
    
    init(modelContext: ModelContext) {
        self.store = AssumptionTemplateStore(modelContext: modelContext)
    }
    
    /// Load template for current entity and horizon
    func loadTemplate() {
        currentTemplate = store.getTemplate(entityID: selectedEntity, horizon: selectedHorizon)
        updatePreview()
    }
    
    /// Get items for a specific section
    func itemsForSection(_ section: AssumptionSection) -> [AssumptionItem] {
        guard let template = currentTemplate else { return [] }
        return template.items.filter { $0.section == section }
    }
    
    /// Get top importance assumptions (for key assumptions section)
    var keyAssumptions: [AssumptionItem] {
        guard let template = currentTemplate else { return [] }
        return template.items
            .filter { $0.importance >= 4 }
            .sorted { $0.importance > $1.importance }
            .prefix(6)
            .map { $0 }
    }
    
    /// Handle item update
    func handleItemUpdate() {
        store.updateItem(currentTemplate?.items.first ?? AssumptionItem(
            key: "dummy",
            title: "Dummy",
            section: .revenueDrivers,
            valueType: .slider,
            importance: 1,
            driverTag: "Revenue"
        ))
        updatePreview()
        objectWillChange.send()
    }
    
    /// Update preview calculation
    private func updatePreview() {
        guard let template = currentTemplate else {
            previewResult = nil
            return
        }
        
        previewResult = ForecastPreviewEngine.calculatePreview(template: template)
    }
    
    /// Reset template to default
    func resetTemplate() {
        store.resetTemplate(entityID: selectedEntity, horizon: selectedHorizon)
        loadTemplate()
    }
}
