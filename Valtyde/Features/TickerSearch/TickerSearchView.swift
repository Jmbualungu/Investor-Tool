import SwiftUI

struct TickerSearchView: View {
    @ObservedObject var viewModel: TickerSearchViewModel
    let onContinue: (Ticker, Int) -> Void
    @AppStorage("marketingMode") private var marketingMode = false
    @State private var showHorizon = false
    @State private var selectedHorizon: Int?
    @State private var showMarketingScreens = false
    @FocusState private var isSearchFocused: Bool
    @Namespace private var horizonAnimation

    private let horizonAnchor = "horizon"
    private let horizons = [1, 3, 5, 10]
    
    var body: some View {
        ZStack {
            AbstractBackground()
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.l) {
                        searchPill

                        if shouldShowResults {
                            resultsSection
                        }

                        Color.clear
                            .frame(height: 1)
                            .id(horizonAnchor)

                        if showHorizon {
                            horizonSection
                                .transition(.opacity)
                        }
                    }
                    .padding(DSSpacing.l)
                }
                .onChange(of: viewModel.selectedTicker?.id) { _, newValue in
                    selectedHorizon = nil
                    guard newValue != nil else {
                        Motion.withAnimation(Motion.screenTransition) {
                            showHorizon = false
                        }
                        return
                    }

                    isSearchFocused = false
                    Motion.withAnimation(Motion.screenTransition) {
                        showHorizon = true
                    }
                    DispatchQueue.main.async {
                        Motion.withAnimation(Motion.screenTransition) {
                            proxy.scrollTo(horizonAnchor, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationTitle("Ticker")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if marketingMode {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMarketingScreens = true
                        AppLogger.log("Marketing screens opened", category: .userAction)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Preview")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(DSColors.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showMarketingScreens) {
            MarketingScreensView()
        }
        .onChange(of: viewModel.query) { _ in
            if viewModel.selectedTicker != nil {
                viewModel.selectedTicker = nil
            }
        }
    }

    private var shouldShowResults: Bool {
        !viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSearchFocused
    }

    private var searchPill: some View {
        HStack(spacing: DSSpacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DSColors.textSecondary)

            TextField("Type in ticker here", text: $viewModel.query)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .focused($isSearchFocused)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DSSpacing.l)
        .frame(height: DSSpacing.buttonHeightStandard)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !viewModel.topResults.isEmpty {
                resultsList(viewModel.topResults)
            }

            if !viewModel.moreResults.isEmpty {
                Divider()
                    .background(DSColors.border)
                    .padding(.vertical, DSSpacing.s)
                resultsList(viewModel.moreResults)
            }
        }
    }

    private func resultsList(_ results: [Ticker]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(results) { ticker in
                Button {
                    viewModel.selectedTicker = ticker
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ticker.symbol)
                                .font(DSTypography.headline)
                                .foregroundColor(DSColors.textPrimary)
                            Text(ticker.name)
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, DSSpacing.m)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if ticker.id != results.last?.id {
                    Divider()
                        .background(DSColors.border)
                }
            }
        }
    }

    private var horizonSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Time Horizon")
                .dsTitle()

            HStack(spacing: 0) {
                ForEach(horizons, id: \.self) { horizon in
                    Button {
                        Motion.withAnimation(Motion.valueChange) {
                            selectedHorizon = horizon
                        }
                    } label: {
                        Text("\(horizon)Y")
                            .font(DSTypography.subheadline)
                            .fontWeight(selectedHorizon == horizon ? .semibold : .regular)
                            .foregroundColor(selectedHorizon == horizon ? DSColors.textPrimary : DSColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: DSSpacing.buttonHeightCompact)
                            .background {
                                if selectedHorizon == horizon {
                                    RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                                        .fill(DSColors.accent)
                                        .matchedGeometryEffect(id: "horizonHighlight", in: horizonAnimation)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )

                if let selectedHorizon, let selectedTicker = viewModel.selectedTicker {
                Button {
                    AppLogger.log("Ticker selected: \(selectedTicker.symbol), Horizon: \(selectedHorizon)Y", category: .userAction)
                    onContinue(selectedTicker, selectedHorizon)
                } label: {
                    Text(Copy.continueCTA)
                        .fontWeight(.semibold)
                }
                .primaryCTAStyle()
                .pressableScale()
            }
        }
    }
}

#Preview {
    NavigationStack {
        TickerSearchView(viewModel: TickerSearchViewModel(), onContinue: { _, _ in })
    }
}
