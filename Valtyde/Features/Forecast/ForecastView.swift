import SwiftUI

struct ForecastView: View {
    @ObservedObject var viewModel: ForecastViewModel
    @ObservedObject var assumptionsViewModel: AssumptionsViewModel
    let onShowReturns: () -> Void
    let onShowSensitivity: () -> Void

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Inputs Summary
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            Text("Inputs")
                                .dsHeadline()
                            
                            DSMetricRow(
                                label: "Current Price",
                                value: Formatters.currency(assumptionsViewModel.assumptions.currentPrice)
                            )
                            DSMetricRow(
                                label: "Revenue Growth",
                                value: Formatters.percent(assumptionsViewModel.assumptions.revenueCagr)
                            )
                        }
                    }

                    // Run Forecast Button
                    DSPillButton(
                        title: "Run Forecast",
                        style: .primary,
                        icon: "play.fill"
                    ) {
                        let ticker = assumptionsViewModel.ticker ?? Ticker(symbol: "TBD", name: "Selected Ticker")
                        viewModel.runForecast(
                            ticker: ticker,
                            assumptions: assumptionsViewModel.assumptions,
                            horizons: [1, 3, 5, 10]
                        )
                    }

                    // Forecast Results
                    if let result = viewModel.result {
                        DSGlassCard {
                            VStack(alignment: .leading, spacing: DSSpacing.m) {
                                Text("Forecast Summary")
                                    .dsTitle()
                                
                                DSMetricRow(
                                    label: "Implied Price (Y10)",
                                    value: Formatters.currency(result.fairValue)
                                )
                                DSMetricRow(
                                    label: "Upside vs Current",
                                    value: Formatters.percent(result.upsidePercent)
                                )
                            }
                        }
                        
                        DSGlassCard {
                            VStack(alignment: .leading, spacing: DSSpacing.m) {
                                Text("Yearly Projections")
                                    .dsHeadline()
                                
                                ForEach(result.projections) { projection in
                                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                                        Text("Year \(projection.year)")
                                            .dsCaption()
                                            .padding(.top, DSSpacing.xs)
                                        
                                        DSMetricRow(label: "Revenue", value: Formatters.currency(projection.revenue))
                                        DSMetricRow(label: "Operating Income", value: Formatters.currency(projection.operatingIncome))
                                        DSMetricRow(label: "After-Tax OI", value: Formatters.currency(projection.afterTaxOperatingIncome))
                                        DSMetricRow(label: "Enterprise Value", value: Formatters.currency(projection.impliedEnterpriseValue))
                                        DSMetricRow(label: "Equity Value", value: Formatters.currency(projection.impliedEquityValue))
                                        DSMetricRow(label: "Implied Price", value: Formatters.currency(projection.impliedPrice))
                                    }
                                    
                                    if projection.id != result.projections.last?.id {
                                        Divider()
                                            .background(DSColors.border)
                                            .padding(.vertical, DSSpacing.xs)
                                    }
                                }
                            }
                        }
                    } else {
                        DSGlassCard {
                            Text("Run the forecast to generate a fair value range")
                                .dsCaption()
                        }
                    }

                    // Action Buttons
                    DSPillButton(
                        title: "View Returns",
                        style: .secondary
                    ) {
                        onShowReturns()
                    }

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
        .navigationTitle("Forecast")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ForecastView(
            viewModel: ForecastViewModel(),
            assumptionsViewModel: AssumptionsViewModel(),
            onShowReturns: {},
            onShowSensitivity: {}
        )
    }
}
