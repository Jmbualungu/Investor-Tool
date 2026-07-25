import SwiftUI

struct SensitivityView: View {
    @ObservedObject var viewModel: SensitivityViewModel
    @ObservedObject var assumptionsViewModel: AssumptionsViewModel
    let onDone: () -> Void

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Run Sensitivity Button
                    DSPillButton(
                        title: "Run Sensitivity Analysis",
                        style: .primary,
                        icon: "square.grid.3x3"
                    ) {
                        viewModel.runSensitivity(assumptions: assumptionsViewModel.assumptions)
                    }

                    // Sensitivity Results
                    if let result = viewModel.result {
                        DSGlassCard {
                            VStack(alignment: .leading, spacing: DSSpacing.m) {
                                Text("Annualized Returns (5y)")
                                    .dsTitle()

                                ScrollView(.horizontal, showsIndicators: false) {
                                    let columnCount = result.multipleValues.count + 1
                                    let columns = Array(repeating: GridItem(.fixed(84), spacing: 8), count: columnCount)
                                    LazyVGrid(columns: columns, spacing: 8) {
                                        Text("")
                                            .font(DSTypography.caption)
                                        ForEach(result.multipleValues, id: \.self) { multiple in
                                            Text(String(format: "%.1fx", multiple))
                                                .font(DSTypography.caption)
                                                .foregroundColor(DSColors.textSecondary)
                                        }

                                        ForEach(Array(result.cagrValues.enumerated()), id: \.offset) { rowIndex, cagr in
                                            Text(Formatters.percent(cagr))
                                                .font(DSTypography.caption)
                                                .foregroundColor(DSColors.textSecondary)
                                            ForEach(Array(result.grid[rowIndex].enumerated()), id: \.offset) { _, value in
                                                Text(Formatters.percent(value))
                                                    .font(DSTypography.caption)
                                                    .frame(width: 84, height: 44)
                                                    .background(DSColors.surface)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                            .stroke(DSColors.border, lineWidth: 0.5)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.vertical, DSSpacing.xs)
                                }
                            }
                        }
                    } else {
                        DSGlassCard {
                            Text("Run sensitivity to generate a range of outcomes")
                                .dsCaption()
                        }
                    }

                    // Done Button
                    DSPillButton(
                        title: "Done",
                        style: .primary
                    ) {
                        onDone()
                    }
                }
                .padding(DSSpacing.l)
            }
        }
        .navigationTitle("Sensitivity")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        SensitivityView(
            viewModel: SensitivityViewModel(),
            assumptionsViewModel: AssumptionsViewModel(),
            onDone: {}
        )
    }
}
