import SwiftUI

/// Row view for displaying and editing an assumption with slider-first UI
struct AssumptionRowView: View {
    @Bindable var item: AssumptionItem
    var onUpdate: () -> Void
    
    @State private var textValue: String = ""
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            // Title and subtitle
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                HStack {
                    Text(item.title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                    
                    // Importance indicator
                    if item.importance >= 4 {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(DSColors.accent)
                    }
                    
                    // Details button
                    Button {
                        showingDetails = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
                
                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
            }
            
            // Value editor
            if item.usesSlider, let min = item.sliderMin, let max = item.sliderMax {
                sliderEditor(min: min, max: max)
            } else if item.valueType == .enumChoice {
                enumEditor()
            } else {
                textEditor()
            }
        }
        .padding(DSSpacing.m)
        .background(DSColors.surfaceSecondary)
        .cornerRadius(DSSpacing.m)
        .onAppear {
            if let value = item.baseValueDouble {
                textValue = String(format: "%.2f", value)
            } else {
                textValue = item.baseValueString ?? ""
            }
        }
        .sheet(isPresented: $showingDetails) {
            AssumptionDetailView(item: item)
        }
    }
    
    // MARK: - Slider Editor
    
    @ViewBuilder
    private func sliderEditor(min: Double, max: Double) -> some View {
        VStack(spacing: DSSpacing.xs) {
            HStack {
                Slider(
                    value: Binding(
                        get: { item.baseValueDouble ?? min },
                        set: { newValue in
                            item.baseValueDouble = newValue
                            onUpdate()
                        }
                    ),
                    in: min...max,
                    step: item.sliderStep ?? 1.0
                )
                .tint(DSColors.accent)
                
                // Value display
                Text(formatSliderValue(item.baseValueDouble ?? min))
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                    .frame(minWidth: 60, alignment: .trailing)
                    .monospacedDigit()
            }
            
            // Min/Max labels
            HStack {
                Text(formatSliderValue(min))
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textTertiary)
                
                Spacer()
                
                Text(formatSliderValue(max))
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textTertiary)
            }
        }
    }
    
    private func formatSliderValue(_ value: Double) -> String {
        let formatted: String
        if abs(value) >= 1000 {
            formatted = String(format: "%.0f", value)
        } else if abs(value) >= 100 {
            formatted = String(format: "%.1f", value)
        } else {
            formatted = String(format: "%.2f", value)
        }
        
        if let unit = item.sliderUnitLabel {
            return "\(formatted)\(unit)"
        }
        return formatted
    }
    
    // MARK: - Enum Editor
    
    @ViewBuilder
    private func enumEditor() -> some View {
        let options = parseEnumOptions()
        
        Picker("Value", selection: Binding(
            get: { item.baseValueString ?? options.first ?? "" },
            set: { newValue in
                item.baseValueString = newValue
                onUpdate()
            }
        )) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .tint(DSColors.accent)
    }
    
    private func parseEnumOptions() -> [String] {
        guard let notes = item.notes else {
            return ["Low", "Medium", "High"]
        }
        
        // Parse "Options: Low, Medium, High" format
        if let optionsRange = notes.range(of: "Options: "),
           let optionsString = notes[optionsRange.upperBound...].split(separator: "\n").first {
            return optionsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }
        
        return ["Low", "Medium", "High"]
    }
    
    // MARK: - Text Editor
    
    @ViewBuilder
    private func textEditor() -> some View {
        TextField("Value", text: $textValue)
            .textFieldStyle(.roundedBorder)
            .keyboardType(item.valueType == .currency || item.valueType == .percent ? .decimalPad : .default)
            .onChange(of: textValue) { newValue in
                if let doubleValue = Double(newValue) {
                    item.baseValueDouble = doubleValue
                    onUpdate()
                } else if !newValue.isEmpty {
                    item.baseValueString = newValue
                    onUpdate()
                }
            }
    }
}

// MARK: - Assumption Detail View

struct AssumptionDetailView: View {
    @Bindable var item: AssumptionItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Basic info
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        Text("Details")
                            .dsTitle()
                        
                        DetailRow(label: "Key", value: item.key)
                        DetailRow(label: "Section", value: item.section.displayName)
                        DetailRow(label: "Driver Tag", value: item.driverTag)
                        DetailRow(label: "Importance", value: "\(item.importance) / 5")
                    }
                    
                    // Affects
                    if !item.affects.isEmpty {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("Affects")
                                .dsSubheadline()
                            
                            ForEach(item.affects, id: \.self) { effect in
                                Text("• \(effect)")
                                    .font(DSTypography.body)
                                    .foregroundColor(DSColors.textSecondary)
                            }
                        }
                    }
                    
                    // Notes
                    if let notes = item.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("Notes")
                                .dsSubheadline()
                            
                            Text(notes)
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                    
                    // Scenario values (if available)
                    if item.bullValueDouble != nil || item.bearValueDouble != nil {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("Scenario Values")
                                .dsSubheadline()
                            
                            if let bull = item.bullValueDouble {
                                DetailRow(label: "Bull Case", value: String(format: "%.2f", bull))
                            }
                            
                            if let bear = item.bearValueDouble {
                                DetailRow(label: "Bear Case", value: String(format: "%.2f", bear))
                            }
                        }
                    }
                }
                .padding(DSSpacing.l)
            }
            .background(DSColors.background)
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(DSColors.accent)
                }
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
        }
        .padding(DSSpacing.s)
        .background(DSColors.surfaceSecondary)
        .cornerRadius(DSSpacing.xs)
    }
}

#Preview {
    let item = AssumptionItem(
        key: "revenue_growth",
        title: "Revenue Growth",
        subtitle: "Annual revenue growth rate",
        section: .revenueDrivers,
        valueType: .percent,
        baseValueDouble: 8.0,
        usesSlider: true,
        sliderMin: -10.0,
        sliderMax: 30.0,
        sliderStep: 0.5,
        sliderUnitLabel: "%",
        importance: 5,
        driverTag: "Revenue",
        affects: ["Revenue", "FCF", "Valuation"]
    )
    
    return AssumptionRowView(item: item, onUpdate: {})
        .padding()
        .background(DSColors.background)
}
