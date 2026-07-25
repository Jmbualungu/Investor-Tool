import SwiftUI

struct AssumptionsView: View {
    @ObservedObject var viewModel: AssumptionsViewModel
    let ticker: Ticker?
    let horizonYears: Int
    let onContinue: () -> Void
    @State private var currentPriceText: String = ""
    @State private var currentRevenueText: String = ""
    @State private var revenueCagrText: String = ""
    @State private var operatingMarginText: String = ""
    @State private var taxRateText: String = ""
    @State private var sharesOutstandingText: String = ""
    @State private var netDebtText: String = ""
    @State private var exitMultipleText: String = ""
    @State private var discountRateText: String = ""

    private var horizonBinding: Binding<Int> {
        Binding(
            get: { viewModel.assumptions.horizonYears },
            set: { viewModel.assumptions.horizonYears = $0 }
        )
    }

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Ticker Display
                    if let ticker {
                        DSGlassCard {
                            Text("Ticker")
                                .dsCaption()
                            TickerPill(symbol: ticker.symbol, name: ticker.name)
                        }
                    }

                    // Assumptions Form
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            Text("Valuation Assumptions")
                                .dsTitle()
                            
                            LabeledTextField(
                                title: "Current Price",
                                placeholder: "e.g. 100",
                                text: $currentPriceText,
                                helpText: "Enter a positive number."
                            ) { text in
                                guard let value = Double(text) else { return false }
                                return value > 0
                            }
                            
                            LabeledTextField(
                                title: "Current Revenue",
                                placeholder: "e.g. 1000",
                                text: $currentRevenueText,
                                helpText: "Enter a positive number."
                            ) { text in
                                guard let value = Double(text) else { return false }
                                return value > 0
                            }
                            
                            LabeledTextField(
                                title: "Revenue CAGR (decimal)",
                                placeholder: "e.g. 0.08",
                                text: $revenueCagrText,
                                helpText: "Use decimal form, e.g. 0.08 for 8%."
                            ) { text in
                                guard let value = Double(text) else { return false }
                                return Validators.isValidGrowthRate(value)
                            }
                            
                            LabeledTextField(
                                title: "Operating Margin (decimal)",
                                placeholder: "e.g. 0.22",
                                text: $operatingMarginText,
                                helpText: "Use decimal form, e.g. 0.22 for 22%."
                            ) { text in
                                guard let value = Double(text) else { return false }
                                return Validators.isValidMargin(value)
                            }
                            
                            LabeledTextField(
                                title: "Tax Rate (decimal)",
                                placeholder: "e.g. 0.21",
                                text: $taxRateText,
                                helpText: "Use decimal form, e.g. 0.21 for 21%."
                            ) { text in
                                guard let value = Double(text) else { return false }
                                return value >= 0 && value <= 0.6
                            }
                            
                            LabeledTextField(
                                title: "Shares Outstanding",
                                placeholder: "e.g. 1000",
                                text: $sharesOutstandingText,
                                helpText: "Enter a positive number."
                            ) { text in
                                guard let value = Double(text) else { return false }
                                return value > 0
                            }
                            
                            LabeledTextField(
                                title: "Net Debt",
                                placeholder: "e.g. -50",
                                text: $netDebtText,
                                helpText: "Can be negative."
                            ) { text in
                                Double(text) != nil
                            }
                            
                            LabeledTextField(
                                title: "Exit Multiple (EV/Revenue)",
                                placeholder: "e.g. 4.0",
                                text: $exitMultipleText,
                                helpText: "Use a positive multiple."
                            ) { text in
                                guard let value = Double(text) else { return false }
                                return value > 0
                            }
                            
                            LabeledTextField(
                                title: "Discount Rate (optional)",
                                placeholder: "e.g. 0.10",
                                text: $discountRateText,
                                helpText: "Optional for later use."
                            ) { text in
                                text.isEmpty || Double(text) != nil
                            }

                            Stepper(value: horizonBinding, in: 1...15) {
                                HStack {
                                    Text("Horizon Years")
                                        .font(DSTypography.subheadline)
                                        .foregroundColor(DSColors.textSecondary)
                                    Spacer()
                                    Text("\(horizonBinding.wrappedValue)")
                                        .font(DSTypography.headline)
                                        .foregroundColor(DSColors.textPrimary)
                                }
                            }
                            .tint(DSColors.accent)
                        }
                    }

                    // Generate Button
                    DSPillButton(
                        title: "Generate Forecast",
                        style: .primary,
                        icon: "chart.line.uptrend.xyaxis"
                    ) {
                        onContinue()
                    }
                }
                .padding(DSSpacing.l)
            }
        }
        .navigationTitle("Assumptions")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.ticker = ticker
            viewModel.assumptions.horizonYears = horizonYears
            currentPriceText = Formatters.number(viewModel.assumptions.currentPrice)
            currentRevenueText = Formatters.number(viewModel.assumptions.currentRevenue)
            revenueCagrText = Formatters.number(viewModel.assumptions.revenueCagr)
            operatingMarginText = Formatters.number(viewModel.assumptions.operatingMargin)
            taxRateText = Formatters.number(viewModel.assumptions.taxRate)
            sharesOutstandingText = Formatters.number(viewModel.assumptions.sharesOutstanding)
            netDebtText = Formatters.number(viewModel.assumptions.netDebt)
            exitMultipleText = Formatters.number(viewModel.assumptions.exitMultiple)
            discountRateText = viewModel.assumptions.discountRate.map(Formatters.number) ?? ""
        }
        .onChange(of: currentPriceText) { newValue in
            if let value = Double(newValue), value > 0 {
                viewModel.assumptions.currentPrice = value
            }
        }
        .onChange(of: currentRevenueText) { newValue in
            if let value = Double(newValue), value > 0 {
                viewModel.assumptions.currentRevenue = value
            }
        }
        .onChange(of: revenueCagrText) { newValue in
            if let value = Double(newValue), Validators.isValidGrowthRate(value) {
                viewModel.assumptions.revenueCagr = value
            }
        }
        .onChange(of: operatingMarginText) { newValue in
            if let value = Double(newValue), Validators.isValidMargin(value) {
                viewModel.assumptions.operatingMargin = value
            }
        }
        .onChange(of: taxRateText) { newValue in
            if let value = Double(newValue), value >= 0, value <= 0.6 {
                viewModel.assumptions.taxRate = value
            }
        }
        .onChange(of: sharesOutstandingText) { newValue in
            if let value = Double(newValue), value > 0 {
                viewModel.assumptions.sharesOutstanding = value
            }
        }
        .onChange(of: netDebtText) { newValue in
            if let value = Double(newValue) {
                viewModel.assumptions.netDebt = value
            }
        }
        .onChange(of: exitMultipleText) { newValue in
            if let value = Double(newValue), value > 0 {
                viewModel.assumptions.exitMultiple = value
            }
        }
        .onChange(of: discountRateText) { newValue in
            if let value = Double(newValue) {
                viewModel.assumptions.discountRate = value
            } else if newValue.isEmpty {
                viewModel.assumptions.discountRate = nil
            }
        }
    }
}

#Preview {
    NavigationStack {
        AssumptionsView(viewModel: AssumptionsViewModel(), ticker: MockData.tickers.first, horizonYears: 5, onContinue: {})
    }
}
