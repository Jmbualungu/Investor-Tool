import SwiftUI
import SwiftData

/// Main view for browsing and editing assumption templates
struct AssumptionsTemplateView: View {
    @StateObject private var viewModel: AssumptionsTemplateViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: AssumptionsTemplateViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Entity Picker
                    entityPicker
                    
                    // Horizon Selector
                    HorizonSelectorView(selectedHorizon: $viewModel.selectedHorizon)
                        .padding(.horizontal, DSSpacing.l)
                        .onChange(of: viewModel.selectedHorizon) { _ in
                            viewModel.loadTemplate()
                        }
                    
                    // Key Assumptions (top importance)
                    if !viewModel.keyAssumptions.isEmpty {
                        keyAssumptionsSection
                    }
                    
                    // All Sections (collapsible)
                    ForEach(AssumptionSection.allCases, id: \.self) { section in
                        if !viewModel.itemsForSection(section).isEmpty {
                            SectionView(
                                section: section,
                                items: viewModel.itemsForSection(section),
                                onUpdate: viewModel.handleItemUpdate
                            )
                        }
                    }
                    
                    // Preview Impact
                    if let preview = viewModel.previewResult {
                        previewImpactSection(preview: preview)
                    }
                    
                    // Actions
                    actionsSection
                }
                .padding(.vertical, DSSpacing.l)
            }
        }
        .navigationTitle("Assumptions Template")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadTemplate()
        }
    }
    
    // MARK: - Entity Picker
    
    private var entityPicker: some View {
        DSGlassCard {
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("Entity")
                    .dsCaption()
                    .foregroundColor(DSColors.textSecondary)
                
                Menu {
                    ForEach(EntityID.allCases) { entity in
                        Button {
                            viewModel.selectedEntity = entity
                            viewModel.loadTemplate()
                        } label: {
                            HStack {
                                Text(entity.displayName)
                                if viewModel.selectedEntity == entity {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedEntity.displayName)
                            .font(DSTypography.headline)
                            .foregroundColor(DSColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(DSColors.textSecondary)
                    }
                    .padding(DSSpacing.m)
                    .background(DSColors.surfaceSecondary)
                    .cornerRadius(DSSpacing.m)
                }
            }
        }
        .padding(.horizontal, DSSpacing.l)
    }
    
    // MARK: - Key Assumptions Section
    
    private var keyAssumptionsSection: some View {
        DSGlassCard {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(DSColors.accent)
                    
                    Text("Key Assumptions")
                        .dsTitle()
                }
                
                Text("Most important drivers for this horizon")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                
                VStack(spacing: DSSpacing.s) {
                    ForEach(viewModel.keyAssumptions) { item in
                        AssumptionRowView(item: item, onUpdate: viewModel.handleItemUpdate)
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.l)
    }
    
    // MARK: - Preview Impact Section
    
    private func previewImpactSection(preview: ForecastPreviewEngine.PreviewResult) -> some View {
        DSGlassCard {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(DSColors.accent)
                    
                    Text("Preview Impact")
                        .dsTitle()
                }
                
                Text("Illustrative outcomes from current assumptions")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                
                VStack(spacing: DSSpacing.s) {
                    PreviewMetricRow(
                        label: "Revenue Index",
                        value: String(format: "%.0f", preview.revenueIndex),
                        subtitle: "Starting at 100"
                    )
                    
                    PreviewMetricRow(
                        label: "FCF Margin Estimate",
                        value: String(format: "%.1f%%", preview.fcfMarginEstimate),
                        subtitle: "Operating margin × conversion"
                    )
                    
                    PreviewMetricRow(
                        label: "FCF Index",
                        value: String(format: "%.0f", preview.fcfIndex),
                        subtitle: "Starting at 100"
                    )
                    
                    PreviewMetricRow(
                        label: "Share Count Change",
                        value: String(format: "%+.1f%%", preview.shareCountChange),
                        subtitle: "Net buybacks - dilution"
                    )
                    
                    Divider()
                        .background(DSColors.textTertiary.opacity(0.3))
                    
                    PreviewMetricRow(
                        label: "Implied Price (Illustrative)",
                        value: String(format: "$%.2f", preview.impliedSharePrice),
                        subtitle: nil,
                        isHighlighted: true
                    )
                    
                    PreviewMetricRow(
                        label: "Implied Total Return",
                        value: String(format: "%+.1f%%", preview.impliedTotalReturn),
                        subtitle: "Over \(viewModel.selectedHorizon.years) year\(viewModel.selectedHorizon.years > 1 ? "s" : "")",
                        isHighlighted: true
                    )
                    
                    if !preview.keyDrivers.isEmpty {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("Key drivers impacting return:")
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textSecondary)
                            
                            ForEach(preview.keyDrivers, id: \.self) { driver in
                                Text("• \(driver)")
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColors.textPrimary)
                            }
                        }
                        .padding(.top, DSSpacing.xs)
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.l)
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(spacing: DSSpacing.m) {
            DSPillButton(
                title: "Reset to Template",
                style: .secondary,
                icon: "arrow.counterclockwise"
            ) {
                viewModel.resetTemplate()
            }
            
            DSPillButton(
                title: "Duplicate Template to Project",
                style: .primary,
                icon: "doc.on.doc"
            ) {
                // Placeholder for future project integration
                viewModel.showProjectDuplicationPlaceholder = true
            }
        }
        .padding(.horizontal, DSSpacing.l)
        .alert("Coming Soon", isPresented: $viewModel.showProjectDuplicationPlaceholder) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Template duplication to projects will be available when ticker-based projects are implemented.")
        }
    }
}

// MARK: - Section View

struct SectionView: View {
    let section: AssumptionSection
    let items: [AssumptionItem]
    let onUpdate: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            // Section Header
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(section.displayName)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
                .padding(DSSpacing.m)
                .background(DSColors.surfaceSecondary)
                .cornerRadius(DSSpacing.m)
            }
            
            // Section Items
            if isExpanded {
                VStack(spacing: DSSpacing.s) {
                    ForEach(items) { item in
                        AssumptionRowView(item: item, onUpdate: onUpdate)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, DSSpacing.l)
    }
}

// MARK: - Preview Metric Row

struct PreviewMetricRow: View {
    let label: String
    let value: String
    let subtitle: String?
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(label)
                    .font(isHighlighted ? DSTypography.subheadline : DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                
                if let subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
            }
            
            Spacer()
            
            Text(value)
                .font(isHighlighted ? DSTypography.title3 : DSTypography.headline)
                .foregroundColor(isHighlighted ? DSColors.accent : DSColors.textPrimary)
                .monospacedDigit()
        }
        .padding(DSSpacing.m)
        .background(isHighlighted ? DSColors.accent.opacity(0.1) : DSColors.surfaceSecondary)
        .cornerRadius(DSSpacing.m)
    }
}

#Preview {
    NavigationStack {
        AssumptionsTemplateView(modelContext: ModelContext(try! ModelContainer(for: EntityAssumptionsTemplate.self, AssumptionItem.self)))
    }
}
