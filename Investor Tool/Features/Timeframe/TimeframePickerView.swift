import SwiftUI

struct TimeframePickerView: View {
    @ObservedObject var viewModel: TimeframePickerViewModel
    let ticker: Ticker?
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                // Selected Ticker Card
                DSGlassCard {
                    Text("Selected Ticker")
                        .dsCaption()
                    
                    if let ticker {
                        TickerPill(symbol: ticker.symbol, name: ticker.name)
                    } else {
                        Text("No ticker selected")
                            .dsBody()
                    }
                }
                
                // Timeframe Selection Card
                DSGlassCard {
                    Text("Select Timeframe")
                        .dsTitle()
                    
                    Text("Choose your forecast horizon")
                        .dsCaption()
                        .padding(.bottom, DSSpacing.s)
                    
                    DSSegmentedPill(
                        labels: viewModel.horizons,
                        selectedIndex: $viewModel.selectedHorizonIndex
                    )
                }
                
                // Sensitivity Toggle Card
                DSGlassCard {
                    Toggle(isOn: $viewModel.showSensitivity) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Show Sensitivity Analysis")
                                .dsHeadline()
                            Text("Analyze how assumptions impact results")
                                .dsCaption()
                        }
                    }
                    .tint(DSColors.accent)
                }
                
                // Continue Button
                DSPillButton(
                    title: "Continue to Assumptions",
                    style: .primary
                ) {
                    onContinue()
                }
                .padding(.top, DSSpacing.m)
            }
            .padding(DSSpacing.l)
        }
        .background(DSColors.background)
        .navigationTitle("Timeframe")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        TimeframePickerView(
            viewModel: TimeframePickerViewModel(),
            ticker: Ticker(symbol: "AAPL", name: "Apple Inc."),
            onContinue: {}
        )
    }
}
