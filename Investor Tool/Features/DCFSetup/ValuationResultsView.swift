//
//  ValuationResultsView.swift
//  Investor Tool
//
//  Valuation results screen for DCF Setup Flow
//

import SwiftUI

struct ValuationResultsView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @Environment(\.navigationPath) private var navigationPath
    @State private var showComingSoonSheet = false
    @State private var comingSoonFeature = "Save"
    @State private var showChangesSheet = false
    @State private var showScenarioSheet = false
    @State private var showSummaryCardSheet = false
    @State private var showScenarioToast = false
    @State private var selectedPriceRange: PriceRange = .oneDay
    
    let onShowSensitivity: () -> Void
    
    // Computed scenario outputs (pure, don't mutate state)
    private var scenarioOutputs: [ScenarioPreset: DCFOutputs] {
        let baseInputs = flowState.getBaseInputs()
        
        var outputs: [ScenarioPreset: DCFOutputs] = [:]
        for preset in ScenarioPreset.allCases {
            let scenarioInputs = DCFEngine.scenarioInputs(from: baseInputs, preset: preset)
            outputs[preset] = DCFEngine.evaluateDCF(scenarioInputs)
        }
        
        return outputs
    }
    
    // Current outputs
    private var currentOutputs: DCFOutputs {
        let inputs = flowState.getCurrentInputs()
        return DCFEngine.evaluateDCF(inputs)
    }
    
    // Aggressiveness score and confidence
    private var aggressivenessScore: Double {
        let inputs = flowState.getCurrentInputs()
        return DCFEngine.calculateAggressivenessScore(inputs: inputs)
    }
    
    private var confidenceInfo: (label: String, isAligned: Bool, targetScore: Double) {
        DCFEngine.confidenceLabel(
            score: aggressivenessScore,
            targetStyle: flowState.investmentLens.style
        )
    }
    
    // Sparkline data
    private var revenueSparklineData: [Double] {
        let inputs = flowState.getCurrentInputs()
        return DCFEngine.generateSparklineData(for: .revenue, inputs: inputs)
    }
    
    private var intrinsicSparklineData: [Double] {
        let inputs = flowState.getCurrentInputs()
        return DCFEngine.generateSparklineData(for: .intrinsic, inputs: inputs)
    }
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xl) {
                        // Mini Price Header (Robinhood-style)
                        if let ticker = flowState.selectedTicker {
                            PriceHeaderView(
                                symbol: ticker.symbol,
                                companyName: ticker.name,
                                selectedRange: $selectedPriceRange
                            )
                        }
                        
                        // Quick Jump Bar
                        quickJumpBar
                        
                        // Hero Card with Sparkline
                        heroCard
                        
                        // Confidence Dial
                        confidenceDial
                        
                        // Scenario Compare
                        scenarioCompareCard
                        
                        // Forecast Name Placeholder
                        forecastNamePlaceholder
                        
                        // Breakdown Card
                        breakdownCard
                        
                        // Assumption Snapshot
                        assumptionSnapshotCard
                        
                        // Financial Disclaimer
                        disclaimerFooter
                    }
                    .padding(DSSpacing.l)
                    .padding(.bottom, DSSpacing.xl)
                }
                
                // Bottom CTA Bar
                bottomBar
            }
        }
        .toast(isPresented: $showScenarioToast, message: "Scenario applied")
        .premiumFlowChrome(
            step: .valuationResults,
            flowState: flowState,
            showBackToRevenueDrivers: true,
            onBackToRevenueDrivers: {
                if let path = navigationPath {
                    flowState.popToRevenueDrivers(path: path)
                }
            }
        )
        .navigationTitle("Valuation")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Forecast Name Placeholder
    
    private var forecastNamePlaceholder: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Forecast Name (coming soon)")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
            
            HStack {
                Text("\(flowState.selectedTicker?.symbol ?? "—") • Base Case • \(flowState.investmentLens.horizon.displayName)")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                
                Spacer()
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DSColors.textTertiary)
            }
            .padding(DSSpacing.m)
            .background(DSColors.surface2.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Quick Jump Bar
    
    private var quickJumpBar: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("Quick Jump")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s) {
                    jumpButton(title: "Revenue", icon: "chart.line.uptrend.xyaxis") {
                        if let path = navigationPath {
                            flowState.popToRevenueDrivers(path: path)
                        }
                    }
                    
                    jumpButton(title: "Operating", icon: "gearshape.fill") {
                        if let path = navigationPath {
                            flowState.popToOperatingAssumptions(path: path)
                        }
                    }
                    
                    jumpButton(title: "Valuation", icon: "dollarsign.circle.fill") {
                        if let path = navigationPath {
                            flowState.popToValuationAssumptions(path: path)
                        }
                    }
                    
                    jumpButton(title: "Sensitivity", icon: "slider.horizontal.3") {
                        onShowSensitivity()
                    }
                }
            }
        }
    }
    
    private func jumpButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.shared.impact(style: .light)
            action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(DSColors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .pressableScale()
    }
    
    // MARK: - Hero Card
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            Text("Intrinsic Value")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text("$\(flowState.derivedIntrinsicValue, specifier: "%.2f")")
                .font(DSTypography.displayNumber)
                .foregroundColor(DSColors.textPrimary)
                .animation(Motion.emphasize, value: flowState.derivedIntrinsicValue)
            
            // Intrinsic Value Sparkline
            VStack(alignment: .leading, spacing: 6) {
                Text("Projected Trend")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DSColors.textTertiary)
                
                Sparkline(points: intrinsicSparklineData, height: 32)
            }
            
            Divider()
                .background(DSColors.divider)
            
            // Current Price & Upside
            HStack(spacing: DSSpacing.xl) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Price")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text("$\(flowState.baselineCurrentPrice, specifier: "%.2f")")
                        .font(DSTypography.displayNumberSmall)
                        .foregroundColor(DSColors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Upside")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    HStack(spacing: 6) {
                        Text(String(format: "%+.1f%%", flowState.derivedUpsidePercent))
                            .font(DSTypography.displayNumberSmall)
                            .foregroundColor(flowState.derivedUpsidePercent >= 0 ? DSColors.positive : DSColors.negative)
                        
                        DSInlineBadge(
                            flowState.derivedUpsidePercent >= 0 ? "↑" : "↓",
                            style: flowState.derivedUpsidePercent >= 0 ? .positive : .negative
                        )
                    }
                }
            }
            
            Divider()
                .background(DSColors.divider)
            
            // Implied CAGR
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Implied CAGR (\(flowState.investmentLens.horizon.displayName))")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text(String(format: "%+.1f%%", flowState.derivedCAGR))
                        .font(.system(size: 24, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundColor(DSColors.accent)
                }
                
                Spacer()
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    DSColors.accent.opacity(0.12),
                    DSColors.accent.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusXLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusXLarge, style: .continuous)
                .stroke(DSColors.accent.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: DSColors.accentGlow.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Confidence Dial
    
    private var confidenceDial: some View {
        ConfidenceDial(
            score: aggressivenessScore,
            label: confidenceInfo.label,
            targetStyle: flowState.investmentLens.style,
            targetScore: confidenceInfo.targetScore,
            isAligned: confidenceInfo.isAligned
        )
    }
    
    // MARK: - Scenario Compare Card
    
    private var scenarioCompareCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Text("Scenario Compare")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                Spacer()
                
                Button {
                    HapticManager.shared.impact(style: .light)
                    showScenarioSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Apply")
                            .font(.system(size: 13, weight: .semibold))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(DSColors.accent)
                }
            }
            
            // Three columns: Bear | Base | Bull
            HStack(spacing: DSSpacing.m) {
                ForEach(ScenarioPreset.allCases, id: \.self) { preset in
                    if let outputs = scenarioOutputs[preset] {
                        scenarioColumn(preset: preset, outputs: outputs)
                    }
                }
            }
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
        .sheet(isPresented: $showScenarioSheet) {
            scenarioApplySheet
        }
    }
    
    private func scenarioColumn(preset: ScenarioPreset, outputs: DCFOutputs) -> some View {
        VStack(alignment: .center, spacing: DSSpacing.s) {
            // Preset name
            Text(preset.displayName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DSColors.textSecondary)
            
            Divider()
                .background(DSColors.border)
            
            // Intrinsic (bold)
            VStack(spacing: 2) {
                Text("$\(outputs.intrinsicValue, specifier: "%.0f")")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Text("Intrinsic")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DSColors.textTertiary)
            }
            
            // Upside %
            VStack(spacing: 2) {
                Text(String(format: "%+.1f%%", outputs.upsidePercent))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(outputs.upsidePercent >= 0 ? .green : .red)
                
                Text("Upside")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DSColors.textTertiary)
            }
            
            // CAGR %
            VStack(spacing: 2) {
                Text(String(format: "%+.1f%%", outputs.cagrPercent))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DSColors.accent)
                
                Text("CAGR")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(DSColors.textTertiary)
            }
            
            // Tiny sparkline (optional)
            let baseInputs = flowState.getBaseInputs()
            let scenarioInputs = DCFEngine.scenarioInputs(from: baseInputs, preset: preset)
            let sparklineData = DCFEngine.generateSparklineData(for: .intrinsic, inputs: scenarioInputs)
            
            Sparkline(points: sparklineData, height: 20)
                .opacity(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(DSSpacing.m)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    }
    
    private var scenarioApplySheet: some View {
        NavigationStack {
            ZStack {
                DSColors.background
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Header
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        Text("Apply Scenario")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        Text("Select a scenario to apply to your live assumptions. This will update all inputs and trigger drift indicators.")
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.top, DSSpacing.l)
                    
                    // Scenario options
                    VStack(spacing: DSSpacing.m) {
                        ForEach(ScenarioPreset.allCases, id: \.self) { preset in
                            scenarioApplyButton(preset: preset)
                        }
                    }
                    .padding(.horizontal, DSSpacing.l)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showScenarioSheet = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
    }
    
    private func scenarioApplyButton(preset: ScenarioPreset) -> some View {
        Button {
            HapticManager.shared.impact(style: .medium)
            Motion.withAnimation(Motion.emphasize) {
                flowState.applyScenario(preset)
            }
            showScenarioSheet = false
            
            // Show toast after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showScenarioToast = true
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.displayName)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    if let outputs = scenarioOutputs[preset] {
                        Text("Intrinsic: $\(outputs.intrinsicValue, specifier: "%.0f") • Upside: \(String(format: "%+.1f%%", outputs.upsidePercent))")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DSColors.accent)
            }
            .padding(DSSpacing.l)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Breakdown Card
    
    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Valuation Breakdown")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            VStack(spacing: DSSpacing.m) {
                breakdownRow(
                    label: "PV of Forecast Period",
                    value: flowState.derivedIntrinsicValue * 0.35,
                    isHighlighted: false
                )
                
                breakdownRow(
                    label: "PV of Terminal Value",
                    value: flowState.derivedIntrinsicValue * 0.65,
                    isHighlighted: false
                )
                
                Divider()
                    .background(DSColors.border)
                
                breakdownRow(
                    label: "Total Intrinsic Value",
                    value: flowState.derivedIntrinsicValue,
                    isHighlighted: true
                )
            }
            
            // Terminal Share Callout
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DSColors.accent)
                
                Text("Terminal value represents ~65% of total value")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }
            .padding(DSSpacing.m)
            .background(DSColors.accent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    private func breakdownRow(label: String, value: Double, isHighlighted: Bool) -> some View {
        HStack {
            Text(label)
                .font(isHighlighted ? DSTypography.headline : DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
            
            Text("$\(value, specifier: "%.2f")")
                .font(.system(size: isHighlighted ? 20 : 18, weight: isHighlighted ? .bold : .semibold))
                .foregroundColor(isHighlighted ? DSColors.accent : DSColors.textPrimary)
        }
        .padding(DSSpacing.m)
        .background(isHighlighted ? DSColors.accent.opacity(0.1) : DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    }
    
    // MARK: - Assumption Snapshot Card
    
    private var assumptionSnapshotCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    Divider()
                        .background(DSColors.border)
                    
                    // Revenue Drivers
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        Text("Revenue Drivers")
                            .font(DSTypography.subheadline)
                            .foregroundColor(DSColors.accent)
                        
                        ForEach(flowState.revenueDrivers.prefix(3)) { driver in
                            HStack {
                                Text(driver.title)
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColors.textSecondary)
                                
                                Spacer()
                                
                                Text(driver.unit.format(driver.value))
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColors.textPrimary)
                            }
                        }
                        
                        if flowState.revenueDrivers.count > 3 {
                            Text("+ \(flowState.revenueDrivers.count - 3) more drivers")
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textTertiary)
                        }
                    }
                    
                    Divider()
                        .background(DSColors.border)
                    
                    // Operating Assumptions
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        Text("Operating Assumptions")
                            .font(DSTypography.subheadline)
                            .foregroundColor(DSColors.accent)
                        
                        assumptionRow(label: "Operating Margin", value: String(format: "%.1f%%", flowState.operatingAssumptions.operatingMargin))
                        assumptionRow(label: "Tax Rate", value: String(format: "%.1f%%", flowState.operatingAssumptions.taxRate))
                        assumptionRow(label: "CapEx %", value: String(format: "%.1f%%", flowState.operatingAssumptions.capexPercent))
                    }
                    
                    Divider()
                        .background(DSColors.border)
                    
                    // Valuation Assumptions
                    VStack(alignment: .leading, spacing: DSSpacing.s) {
                        Text("Valuation Assumptions")
                            .font(DSTypography.subheadline)
                            .foregroundColor(DSColors.accent)
                        
                        assumptionRow(label: "Discount Rate", value: String(format: "%.1f%%", flowState.valuationAssumptions.discountRate))
                        assumptionRow(label: "Terminal Growth", value: String(format: "%.1f%%", flowState.valuationAssumptions.terminalGrowth))
                        assumptionRow(label: "Method", value: flowState.valuationAssumptions.terminalMethod.rawValue)
                    }
                }
                .padding([.horizontal, .bottom], DSSpacing.m)
                .transition(.opacity.combined(with: .move(edge: .top)))
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DSColors.accent)
                    
                    Text("Assumption Snapshot")
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                }
                .padding(DSSpacing.m)
                .contentShape(Rectangle())
            }
        }
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
        .tint(DSColors.accent)
    }
    
    private func assumptionRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textPrimary)
        }
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        DSBottomBar {
            DSBottomBarPrimaryButton("Sensitivity Analysis", icon: "arrow.right") {
                onShowSensitivity()
            }
        } secondary: {
            VStack(spacing: DSSpacing.m) {
                // Changes Button (only visible when drifted)
                if flowState.hasAnyDrift() {
                    DSBottomBarSecondaryButton("View Changes", icon: "list.bullet.rectangle") {
                        showChangesSheet = true
                    }
                }
                
                // Preview Summary Card Button
                Button {
                    HapticManager.shared.impact(style: .light)
                    showSummaryCardSheet = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text.image")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Preview Summary Card")
                            .fontWeight(.semibold)
                    }
                }
                .secondaryCTAStyle()
                .pressableScale()
                
                // Action Bar: Save & Share
                HStack(spacing: DSSpacing.m) {
                    // Save Button (Disabled)
                    Button {
                        comingSoonFeature = "Save"
                        showComingSoonSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .semibold))
                            
                            Text("Save")
                                .font(DSTypography.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(DSColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.buttonHeightCompact)
                        .background(DSColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                                .stroke(DSColors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Share Button (Disabled)
                    Button {
                        comingSoonFeature = "Share"
                        showComingSoonSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12, weight: .semibold))
                            
                            Text("Share")
                                .font(DSTypography.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(DSColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.buttonHeightCompact)
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
        .sheet(isPresented: $showComingSoonSheet) {
            ComingSoonSheet(feature: comingSoonFeature)
        }
        .sheet(isPresented: $showChangesSheet) {
            ChangeSummarySheet(onRevertAll: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    flowState.revertAllToBase()
                }
            })
            .environmentObject(flowState)
        }
        .sheet(isPresented: $showSummaryCardSheet) {
            if let ticker = flowState.selectedTicker {
                SummaryCardView(
                    ticker: ticker,
                    horizon: flowState.investmentLens.horizon,
                    outputs: currentOutputs,
                    confidenceLabel: confidenceInfo.label,
                    topDrivers: Array(flowState.revenueDrivers.prefix(3)),
                    operating: flowState.operatingAssumptions,
                    valuation: flowState.valuationAssumptions
                )
            }
        }
    }
    
    // MARK: - Disclaimer Footer
    
    private var disclaimerFooter: some View {
        Text(Copy.educationalPurposes)
            .font(.system(size: 11))
            .foregroundColor(DSColors.textTertiary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, DSSpacing.m)
    }
}

#Preview {
    NavigationStack {
        ValuationResultsView(onShowSensitivity: {})
            .environmentObject({
                let state = DCFFlowState()
                state.selectedTicker = DCFTicker(
                    symbol: "AAPL",
                    name: "Apple Inc.",
                    sector: "Technology",
                    industry: "Consumer Electronics",
                    marketCapTier: .large,
                    businessModel: .platform,
                    blurb: "Test",
                    currentPrice: 185.50
                )
                state.generateRevenueDrivers()
                return state
            }())
    }
}
