import SwiftUI

/// Horizon selector component - isolated for easy replacement with sliding bar later
struct HorizonSelectorView: View {
    @Binding var selectedHorizon: Horizon
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Time Horizon")
                .dsCaption()
                .foregroundColor(DSColors.textSecondary)
            
            Picker("Horizon", selection: $selectedHorizon) {
                ForEach(Horizon.allCases) { horizon in
                    Text(horizon.rawValue).tag(horizon)
                }
            }
            .pickerStyle(.segmented)
            .tint(DSColors.accent)
            
            Text(selectedHorizon.description)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
                .padding(.top, DSSpacing.xxs)
        }
    }
}

#Preview {
    @Previewable @State var horizon: Horizon = .fiveYear
    
    return VStack {
        HorizonSelectorView(selectedHorizon: $horizon)
            .padding()
    }
    .background(DSColors.background)
}
