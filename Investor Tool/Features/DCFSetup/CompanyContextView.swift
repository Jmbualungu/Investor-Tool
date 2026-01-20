//
//  CompanyContextView.swift
//  Investor Tool
//
//  Company context screen for DCF Setup Flow
//  Upgraded: Comprehensive Robinhood-like UI with mock data provider
//

import SwiftUI

struct CompanyContextView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    let ticker: DCFTicker
    let onContinue: () -> Void
    
    // Provider for fetching context data
    private let provider: CompanyContextProviding
    
    // State
    @State private var loadingState: LoadingState = .loading
    @State private var contextModel: CompanyContextModel?
    @State private var errorMessage: String?
    
    enum LoadingState {
        case loading
        case loaded
        case error
    }
    
    init(
        ticker: DCFTicker,
        onContinue: @escaping () -> Void,
        provider: CompanyContextProviding = MockCompanyContextProvider()
    ) {
        self.ticker = ticker
        self.onContinue = onContinue
        self.provider = provider
    }
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                contentView
                
                // Bottom CTA Bar
                if loadingState == .loaded {
                    bottomBar
                }
            }
        }
        .premiumFlowChrome(
            step: .context,
            flowState: flowState
        )
        .navigationTitle("Company Context")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadContext()
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
        switch loadingState {
        case .loading:
            loadingView
        case .loaded:
            if let model = contextModel {
                contextScrollView(model: model)
            }
        case .error:
            errorView
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: DSSpacing.l) {
            ProgressView()
                .controlSize(.large)
            
            Text("Loading company context...")
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: DSSpacing.l) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(DSColors.warning)
            
            Text("Failed to load context")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            if let error = errorMessage {
                Text(error)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.xl)
            }
            
            Button {
                Task { await loadContext() }
            } label: {
                Text("Retry")
                    .font(DSTypography.button)
                    .foregroundColor(.white)
                    .frame(width: 120, height: 44)
                    .background(DSColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
            }
            .padding(.top, DSSpacing.m)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.xl)
    }
    
    private func contextScrollView(model: CompanyContextModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                // 1. Snapshot Hero Card
                snapshotHeroCard(model: model)
                
                // 2. Heat Map Card
                heatMapCard(model: model)
                
                // 3. Revenue & Value Drivers
                revenueDriversCard(model: model)
                
                // 4. Competitive Landscape
                competitiveLandscapeCard(model: model)
                
                // 5. Risk & Sensitivity Flags
                risksCard(model: model)
                
                // 6. "How to think about this company"
                framingCard(model: model)
            }
            .padding(DSSpacing.l)
            .padding(.bottom, 100) // Extra padding for bottom bar
        }
    }
    
    // MARK: - Load Context
    
    private func loadContext() async {
        loadingState = .loading
        errorMessage = nil
        
        do {
            let model = try await provider.fetchCompanyContext(ticker: ticker.symbol)
            await MainActor.run {
                contextModel = model
                loadingState = .loaded
            }
        } catch let error as CompanyContextError {
            await MainActor.run {
                errorMessage = error.localizedDescription
                loadingState = .error
            }
        } catch {
            await MainActor.run {
                errorMessage = "An unexpected error occurred"
                loadingState = .error
            }
        }
    }
    
    // MARK: - 1. Snapshot Hero Card
    
    private func snapshotHeroCard(model: CompanyContextModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            // Ticker and Company Name
            VStack(alignment: .leading, spacing: 6) {
                Text(model.ticker)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)
                
                Text(model.companyName)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
            }
            
            // Price and Day Change
            HStack(alignment: .firstTextBaseline, spacing: DSSpacing.m) {
                Text(model.snapshot.formattedPrice)
                    .font(DSTypography.displayNumberSmall)
                    .foregroundColor(DSColors.textPrimary)
                
                HStack(spacing: 4) {
                    Text(model.snapshot.formattedDayChange)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(model.snapshot.isPositiveChange ? DSColors.positive : DSColors.negative)
                    
                    Text(model.snapshot.formattedDayChangePct)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(model.snapshot.isPositiveChange ? DSColors.positive : DSColors.negative)
                }
            }
            
            // Market Cap and Lifecycle
            HStack(spacing: DSSpacing.s) {
                DSInlineBadge(model.snapshot.formattedMarketCap, style: .accent)
                DSInlineBadge(model.snapshot.lifecycle, style: .neutral)
            }
            
            Divider()
                .background(DSColors.divider)
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s) {
                    ForEach(model.tags, id: \.self) { tag in
                        DSChip(text: tag)
                    }
                }
            }
            
            // Description
            Text(model.snapshot.description)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
            
            // Geography and Business Model
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                metadataRow(label: "Geography", value: model.snapshot.geography)
                metadataRow(label: "Business Model", value: model.snapshot.businessModel)
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusXLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusXLarge, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - 2. Heat Map Card
    
    private func heatMapCard(model: CompanyContextModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            Text("At a glance")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            HeatMapView(model: model.heatMap)
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - 3. Revenue & Value Drivers
    
    private func revenueDriversCard(model: CompanyContextModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            Text("Revenue & value drivers")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            VStack(spacing: DSSpacing.m) {
                ForEach(model.revenueDrivers) { driver in
                    driverRow(driver: driver)
                }
            }
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    private func driverRow(driver: DriverModel) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.m) {
            VStack(alignment: .leading, spacing: 4) {
                Text(driver.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DSColors.textPrimary)
                
                Text(driver.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(DSColors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            sensitivityBadge(sensitivity: driver.sensitivity)
        }
        .padding(DSSpacing.m)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusSmall, style: .continuous))
    }
    
    private func sensitivityBadge(sensitivity: String) -> some View {
        let style: DSInlineBadge.Style = {
            if sensitivity.contains("High") {
                return .negative
            } else if sensitivity.contains("Med") {
                return .warning
            } else {
                return .neutral
            }
        }()
        
        return DSInlineBadge(sensitivity, style: style)
    }
    
    // MARK: - 4. Competitive Landscape
    
    private func competitiveLandscapeCard(model: CompanyContextModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            Text("Competitive landscape")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.m) {
                    ForEach(model.competitors) { competitor in
                        competitorChip(competitor: competitor)
                    }
                }
            }
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    private func competitorChip(competitor: CompetitorModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text(competitor.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
            
            Text(competitor.relativeScale)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DSColors.textSecondary)
            
            if let note = competitor.note {
                Text(note)
                    .font(.system(size: 11))
                    .foregroundColor(DSColors.textTertiary)
                    .lineLimit(2)
            }
        }
        .padding(DSSpacing.m)
        .frame(width: 160, alignment: .leading)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 0.5)
        )
    }
    
    // MARK: - 5. Risks Card
    
    private func risksCard(model: CompanyContextModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            Text("Risk & sensitivity flags")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            VStack(spacing: DSSpacing.m) {
                ForEach(model.risks) { risk in
                    riskRow(risk: risk)
                }
            }
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    private func riskRow(risk: RiskModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack {
                Text(risk.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                
                Spacer()
                
                impactBadge(impact: risk.impact)
            }
            
            Text(risk.detail)
                .font(.system(size: 14))
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(3)
        }
        .padding(DSSpacing.m)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusSmall, style: .continuous))
    }
    
    private func impactBadge(impact: String) -> some View {
        let style: DSInlineBadge.Style = {
            if impact.contains("High") {
                return .negative
            } else if impact.contains("Med") {
                return .warning
            } else {
                return .neutral
            }
        }()
        
        return DSInlineBadge(impact, style: style)
    }
    
    // MARK: - 6. Framing Card
    
    private func framingCard(model: CompanyContextModel) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DSColors.accent)
                
                Text("How to think about this company")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
            }
            
            Text(model.framing)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(5)
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                DSColors.surface
                DSColors.accent.opacity(0.05)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.accent.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        DSBottomBar {
            DSBottomBarPrimaryButton("Set Investment Lens", icon: "arrow.right") {
                HapticManager.shared.impact(style: .light)
                onContinue()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func metadataRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DSColors.textTertiary)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(DSColors.textSecondary)
                .lineLimit(2)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CompanyContextView(
            ticker: DCFTicker(
                symbol: "AAPL",
                name: "Apple Inc.",
                sector: "Technology",
                industry: "Consumer Electronics",
                marketCapTier: .large,
                businessModel: .platform,
                blurb: "Designs and manufactures consumer electronics, software, and services. Known for iPhone, Mac, and services ecosystem.",
                currentPrice: 185.50
            ),
            onContinue: {}
        )
        .environmentObject(DCFFlowState())
    }
}
