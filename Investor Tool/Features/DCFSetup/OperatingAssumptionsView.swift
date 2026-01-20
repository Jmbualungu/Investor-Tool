//
//  OperatingAssumptionsView.swift
//  Investor Tool
//
//  Operating assumptions screen for DCF Setup Flow
//

import SwiftUI

struct OperatingAssumptionsView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @Environment(\.navigationPath) private var navigationPath
    @State private var selectedPreset: PresetScenario = .base
    @State private var validationTask: Task<Void, Never>?
    
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Summary Card
                    summaryCard
                    
                    // Preset Pills
                    presetSection
                    
                    // Margins Section
                    marginsSection
                    
                    // Reinvestment Section
                    reinvestmentSection
                    
                    // Continue Button
                    continueButton
                }
                .padding(DSSpacing.l)
            }
        }
        .premiumFlowChrome(
            step: .operating,
            flowState: flowState,
            showBackToRevenueDrivers: true,
            onBackToRevenueDrivers: {
                if let path = navigationPath {
                    flowState.popToRevenueDrivers(path: path)
                }
            }
        )
        .navigationTitle("Operating Assumptions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            flowState.saveOperatingSnapshot()
        }
    }
    
    // MARK: - Summary Card
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Operating Profile")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            HStack(spacing: DSSpacing.l) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Revenue Index")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text(String(format: "%.0f", flowState.derivedTopLineRevenue))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("FCF Margin")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text(String(format: "%.1f%%", fcfMargin))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(DSColors.accent)
                }
            }
            
            Divider()
                .background(DSColors.border)
            
            HStack {
                Text("FCF Index")
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColors.textSecondary)
                
                Spacer()
                
                Text(String(format: "%.1f", flowState.derivedFreeCashFlowIndex))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DSColors.accent)
            }
            
            Text("Controls profitability & reinvestment")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    DSColors.accent.opacity(0.2),
                    DSColors.accent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                .stroke(DSColors.accent.opacity(0.4), lineWidth: 1.5)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: flowState.derivedFreeCashFlowIndex)
    }
    
    private var fcfMargin: Double {
        let operating = flowState.operatingAssumptions
        return max(0, operating.operatingMargin * (1.0 - operating.taxRate / 100.0) - operating.capexPercent - operating.workingCapitalPercent)
    }
    
    // MARK: - Preset Section
    
    private var presetSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Quick Presets")
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s) {
                    presetPill(.bear)
                    presetPill(.base)
                    presetPill(.bull)
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedPreset = .base
                            flowState.resetOperatingToDefaults()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Reset")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(DSColors.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(DSColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                                .stroke(DSColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func presetPill(_ preset: PresetScenario) -> some View {
        Button {
            HapticManager.shared.impact(style: .light)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedPreset = preset
                flowState.applyOperatingPreset(preset)
            }
        } label: {
            Text(preset.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selectedPreset == preset ? .black : DSColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedPreset == preset ? DSColors.accent : DSColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                        .stroke(selectedPreset == preset ? Color.clear : DSColors.border, lineWidth: 1)
                )
                .shadow(
                    color: selectedPreset == preset ? DSColors.accent.opacity(0.3) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Margins Section
    
    private var marginsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Text("Margins")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                if flowState.isOperatingDrifted() {
                    DriftBadge()
                }
                
                Spacer()
                
                if flowState.isOperatingDrifted() {
                    Button {
                        HapticManager.shared.impact(style: .light)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            flowState.revertOperatingToBase()
                        }
                    } label: {
                        Text("Revert")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DSColors.accent)
                    }
                }
            }
            
            // Operating Margin > Gross Margin Validation
            if flowState.operatingAssumptions.operatingMargin > flowState.operatingAssumptions.grossMargin {
                WarningBanner(
                    title: "Operating Margin Exceeds Gross Margin",
                    message: "Operating margin cannot exceed gross margin. It will be auto-adjusted.",
                    severity: .warn,
                    explanation: "Operating margin represents profit after all operating expenses, which by definition cannot exceed gross margin (profit after direct costs only)."
                )
            }
            
            // Negative FCF Warning
            if fcfMargin < 0 {
                WarningBanner(
                    title: "Negative Free Cash Flow",
                    message: "Your reinvestment assumptions imply negative free cash flow.",
                    severity: .info,
                    explanation: "High capital expenditure and working capital requirements can temporarily result in negative FCF. This is common for high-growth companies, but consider whether this is sustainable long-term."
                )
            }
            
            VStack(spacing: DSSpacing.m) {
                sliderRow(
                    title: "Gross Margin",
                    subtitle: "Revenue after direct costs",
                    value: $flowState.operatingAssumptions.grossMargin,
                    range: 20...80,
                    step: 1.0
                )
                
                sliderRow(
                    title: "Operating Margin",
                    subtitle: "Profit after all operating expenses",
                    value: $flowState.operatingAssumptions.operatingMargin,
                    range: 5...50,
                    step: 1.0
                )
            }
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Reinvestment Section
    
    private var reinvestmentSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Reinvestment & Taxes")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            VStack(spacing: DSSpacing.m) {
                sliderRow(
                    title: "CapEx % of Revenue",
                    subtitle: "Capital expenditures for growth",
                    value: $flowState.operatingAssumptions.capexPercent,
                    range: 0...15,
                    step: 0.5
                )
                
                sliderRow(
                    title: "Working Capital % of Revenue",
                    subtitle: "Cash tied up in operations",
                    value: $flowState.operatingAssumptions.workingCapitalPercent,
                    range: -2...5,
                    step: 0.5
                )
                
                sliderRow(
                    title: "Tax Rate",
                    subtitle: "Effective corporate tax rate",
                    value: $flowState.operatingAssumptions.taxRate,
                    range: 10...35,
                    step: 1.0
                )
            }
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Slider Row
    
    private func sliderRow(
        title: String,
        subtitle: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text(subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
                
                Spacer()
                
                Text(String(format: "%.1f%%", value.wrappedValue))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DSColors.accent)
                    .frame(minWidth: 60, alignment: .trailing)
                    .animation(.easeInOut(duration: 0.2), value: value.wrappedValue)
            }
            
            Slider(value: value, in: range, step: step)
                .tint(DSColors.accent)
                .onChange(of: value.wrappedValue) { _, _ in
                    selectedPreset = .base
                    
                    // Debounced validation and auto-clamp
                    validationTask?.cancel()
                    validationTask = Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(250))
                        
                        guard !Task.isCancelled else { return }
                        
                        // Auto-clamp operating margin if it exceeds gross margin
                        if flowState.operatingAssumptions.operatingMargin > flowState.operatingAssumptions.grossMargin {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                flowState.operatingAssumptions.operatingMargin = flowState.operatingAssumptions.grossMargin
                            }
                            HapticManager.shared.impact(style: .light)
                        }
                    }
                }
        }
        .padding(DSSpacing.m)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        Button {
            HapticManager.shared.impact(style: .light)
            onContinue()
        } label: {
            Text(Copy.continueToValuation)
                .fontWeight(.semibold)
        }
        .primaryCTAStyle()
        .pressableScale()
    }
}

#Preview {
    NavigationStack {
        OperatingAssumptionsView(onContinue: {})
            .environmentObject({
                let state = DCFFlowState()
                state.selectedTicker = DCFTicker(
                    symbol: "AAPL",
                    name: "Apple Inc.",
                    sector: "Technology",
                    industry: "Consumer Electronics",
                    marketCapTier: .large,
                    businessModel: .platform,
                    blurb: "Test"
                )
                state.generateRevenueDrivers()
                return state
            }())
    }
}
