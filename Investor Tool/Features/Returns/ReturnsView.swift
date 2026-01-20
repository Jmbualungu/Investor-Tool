import SwiftUI

struct ReturnsView: View {
    @ObservedObject var viewModel: ReturnsViewModel
    @ObservedObject var forecastViewModel: ForecastViewModel
    let onShowSensitivity: () -> Void

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Returns Results
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            Text("Projected Returns")
                                .dsTitle()
                            
                            if !viewModel.metrics.isEmpty {
                                ForEach(viewModel.metrics) { metric in
                                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                                        Text("\(metric.horizonYears)-Year Horizon")
                                            .dsCaption()
                                            .padding(.top, DSSpacing.xs)
                                        
                                        DSMetricRow(
                                            label: "Total Return",
                                            value: Formatters.percent(metric.totalReturn)
                                        )
                                        DSMetricRow(
                                            label: "Annualized",
                                            value: Formatters.percent(metric.annualizedReturn)
                                        )
                                    }
                                    
                                    if metric.id != viewModel.metrics.last?.id {
                                        Divider()
                                            .background(DSColors.border)
                                            .padding(.vertical, DSSpacing.xs)
                                    }
                                }
                            } else {
                                Text("Run a forecast to see expected returns")
                                    .dsCaption()
                            }
                        }
                    }

                    // Compute Button
                    DSPillButton(
                        title: "Compute Returns",
                        style: .primary,
                        icon: "percent"
                    ) {
                        viewModel.compute(from: forecastViewModel.result)
                    }

                    // View Sensitivity Button
                    DSPillButton(
                        title: "View Sensitivity",
                        style: .secondary
                    ) {
                        onShowSensitivity()
                    }
                }
                .padding(DSSpacing.l)
            }
        }
        .navigationTitle("Returns")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ReturnsView(
            viewModel: ReturnsViewModel(),
            forecastViewModel: ForecastViewModel(),
            onShowSensitivity: {}
        )
    }
}
