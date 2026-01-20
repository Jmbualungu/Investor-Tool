//
//  SensitivityAnalysisView.swift
//  Investor Tool
//
//  Sensitivity analysis screen for DCF Setup Flow
//

import SwiftUI

struct SensitivityAnalysisView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.navigationPath) private var navigationPath
    @State private var analysisMode: AnalysisMode = .oneDimensional
    @State private var selectedVariable: SensitivityVariable = .revenueDriver
    @State private var gridXVariable: GridVariable = .discountRate
    @State private var gridYVariable: GridVariable = .operatingMargin
    
    enum AnalysisMode: String, CaseIterable {
        case oneDimensional = "1D"
        case twoDimensionalGrid = "2D Grid"
    }
    
    enum SensitivityVariable: String, CaseIterable, Identifiable {
        case revenueDriver = "Revenue Driver"
        case operatingMargin = "Operating Margin"
        case discountRate = "Discount Rate"
        case terminalGrowth = "Terminal Growth"
        
        var id: String { rawValue }
    }
    
    enum GridVariable: String, CaseIterable, Identifiable {
        case discountRate = "Discount Rate"
        case operatingMargin = "Operating Margin"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xl) {
                        // Header
                        headerSection
                        
                        // Mode Selector
                        modeSelector
                        
                        // Content based on mode
                        if analysisMode == .oneDimensional {
                            oneDimensionalContent
                        } else {
                            twoDimensionalContent
                        }
                        
                        // Disclaimer
                        disclaimerFooter
                    }
                    .padding(DSSpacing.l)
                    .padding(.bottom, DSSpacing.xl)
                }
                
                // Bottom CTA Bar
                bottomBar
            }
        }
        .premiumFlowChrome(
            step: .sensitivity,
            flowState: flowState,
            showBackToRevenueDrivers: true,
            onBackToRevenueDrivers: {
                if let path = navigationPath {
                    flowState.popToRevenueDrivers(path: path)
                }
            }
        )
        .navigationTitle("Sensitivity")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("Sensitivity Analysis")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            
            Text("See how changes in key assumptions affect your valuation.")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Mode Selector
    
    private var modeSelector: some View {
        HStack(spacing: 0) {
            ForEach(AnalysisMode.allCases, id: \.self) { mode in
                Button {
                    HapticManager.shared.selectionChanged()
                    Motion.withAnimation(Motion.emphasize) {
                        analysisMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(DSTypography.subheadline)
                        .fontWeight(analysisMode == mode ? .semibold : .regular)
                        .foregroundColor(
                            analysisMode == mode
                                ? DSColors.textPrimary
                                : DSColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.buttonHeightCompact)
                        .background {
                            if analysisMode == mode {
                                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                                    .fill(DSColors.accent)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - 1D Content
    
    private var oneDimensionalContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            // Variable Picker
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("Select Variable")
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColors.textSecondary)
                
                variableSelectorGrid
            }
            
            // 1D Results Table
            oneDimensionalTable
        }
    }
    
    private var variableSelectorGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DSSpacing.s),
                GridItem(.flexible(), spacing: DSSpacing.s)
            ],
            spacing: DSSpacing.s
        ) {
            ForEach(SensitivityVariable.allCases) { variable in
                VariableSelectorChip(
                    variable: variable,
                    isSelected: selectedVariable == variable
                ) {
                    HapticManager.shared.selectionChanged()
                    Motion.withAnimation(Motion.emphasize) {
                        selectedVariable = variable
                    }
                }
            }
        }
    }
    
    private var oneDimensionalTable: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Scenario Analysis")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            VStack(spacing: 0) {
                // Header Row
                HStack {
                    Text("Adjustment")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Intrinsic Value")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text("Upside")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(DSSpacing.m)
                .background(DSColors.surface2)
                
                Divider()
                    .background(DSColors.border)
                
                // Data Rows
                ForEach([-20.0, -10.0, 0.0, 10.0, 20.0], id: \.self) { adjustment in
                    sensitivityRow(adjustment: adjustment)
                    
                    if adjustment != 20.0 {
                        Divider()
                            .background(DSColors.border)
                    }
                }
            }
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
        }
    }
    
    private func sensitivityRow(adjustment: Double) -> some View {
        let result = calculateOneDimensional(variable: selectedVariable, adjustment: adjustment)
        let isBase = adjustment == 0.0
        
        return HStack {
            Text(adjustmentLabel(adjustment))
                .font(isBase ? DSTypography.body.weight(.semibold) : DSTypography.body)
                .foregroundColor(isBase ? DSColors.accent : DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("$\(result.intrinsicValue, specifier: "%.2f")")
                .font(isBase ? DSTypography.body.weight(.semibold) : DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            Text(String(format: "%+.1f%%", result.upside))
                .font(isBase ? DSTypography.body.weight(.semibold) : DSTypography.body)
                .foregroundColor(result.upside >= 0 ? DSColors.accent : .red)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(DSSpacing.m)
        .background(isBase ? DSColors.accent.opacity(0.1) : Color.clear)
    }
    
    private func adjustmentLabel(_ adjustment: Double) -> String {
        if adjustment == 0.0 {
            return "Base Case"
        } else if selectedVariable == .discountRate || selectedVariable == .terminalGrowth {
            // For rates, use point adjustments
            let points = adjustment / 10.0 // Convert percentage to points
            return String(format: "%+.1f pts", points)
        } else {
            // For percentages
            return String(format: "%+.0f%%", adjustment)
        }
    }
    
    // MARK: - 2D Content
    
    private var twoDimensionalContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            // Variable Pickers
            HStack(spacing: DSSpacing.m) {
                VStack(alignment: .leading, spacing: DSSpacing.s) {
                    Text("X-Axis")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Picker("X-Axis", selection: $gridXVariable) {
                        ForEach(GridVariable.allCases) { variable in
                            Text(variable.rawValue).tag(variable)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(DSColors.accent)
                }
                
                VStack(alignment: .leading, spacing: DSSpacing.s) {
                    Text("Y-Axis")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Picker("Y-Axis", selection: $gridYVariable) {
                        ForEach(GridVariable.allCases) { variable in
                            Text(variable.rawValue).tag(variable)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(DSColors.accent)
                }
            }
            
            // 2D Grid
            twoDimensionalGrid
        }
    }
    
    private var twoDimensionalGrid: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Intrinsic Value Grid")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Header with X values
                    HStack(spacing: 0) {
                        // Top-left corner cell
                        Text("")
                            .font(DSTypography.caption)
                            .frame(width: 80, height: 40)
                            .background(DSColors.surface2)
                        
                        // X-axis labels
                        ForEach([-2.0, -1.0, 0.0, 1.0, 2.0], id: \.self) { xAdj in
                            Text(gridAxisLabel(xAdj, for: gridXVariable))
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textSecondary)
                                .frame(width: 80, height: 40)
                                .background(DSColors.surface2)
                        }
                    }
                    
                    Divider()
                        .background(DSColors.border)
                    
                    // Grid rows
                    ForEach([-2.0, -1.0, 0.0, 1.0, 2.0], id: \.self) { yAdj in
                        HStack(spacing: 0) {
                            // Y-axis label
                            Text(gridAxisLabel(yAdj, for: gridYVariable))
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textSecondary)
                                .frame(width: 80, height: 50)
                                .background(DSColors.surface2)
                            
                            // Grid cells
                            ForEach([-2.0, -1.0, 0.0, 1.0, 2.0], id: \.self) { xAdj in
                                let value = calculateTwoDimensional(
                                    xVariable: gridXVariable,
                                    xAdjustment: xAdj,
                                    yVariable: gridYVariable,
                                    yAdjustment: yAdj
                                )
                                let isBase = xAdj == 0.0 && yAdj == 0.0
                                
                                Text("$\(value, specifier: "%.0f")")
                                    .font(isBase ? DSTypography.caption.weight(.bold) : DSTypography.caption)
                                    .foregroundColor(isBase ? DSColors.accent : DSColors.textPrimary)
                                    .frame(width: 80, height: 50)
                                    .background(isBase ? DSColors.accent.opacity(0.15) : DSColors.surface)
                                    .overlay(
                                        Rectangle()
                                            .stroke(DSColors.border, lineWidth: 0.5)
                                    )
                            }
                        }
                        
                        if yAdj != 2.0 {
                            Divider()
                                .background(DSColors.border)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                        .stroke(DSColors.border, lineWidth: 1)
                )
            }
        }
    }
    
    private func gridAxisLabel(_ adjustment: Double, for variable: GridVariable) -> String {
        if adjustment == 0.0 {
            return "Base"
        }
        
        switch variable {
        case .discountRate:
            let baseValue = flowState.valuationAssumptions.discountRate
            return String(format: "%.1f%%", baseValue + adjustment)
        case .operatingMargin:
            let baseValue = flowState.operatingAssumptions.operatingMargin
            return String(format: "%.0f%%", baseValue + adjustment * 2) // Scale for visibility
        }
    }
    
    // MARK: - Calculations
    
    private func calculateOneDimensional(variable: SensitivityVariable, adjustment: Double) -> (intrinsicValue: Double, upside: Double) {
        // Calculate adjusted values without mutating state
        var adjustedRevenueIndex = flowState.derivedTopLineRevenue
        var adjustedOperating = flowState.operatingAssumptions
        var adjustedValuation = flowState.valuationAssumptions
        
        switch variable {
        case .revenueDriver:
            // Adjust revenue index proportionally
            adjustedRevenueIndex = flowState.derivedTopLineRevenue * (1.0 + adjustment / 100.0)
        case .operatingMargin:
            adjustedOperating.operatingMargin = flowState.operatingAssumptions.operatingMargin * (1.0 + adjustment / 100.0)
        case .discountRate:
            let points = adjustment / 10.0
            adjustedValuation.discountRate = flowState.valuationAssumptions.discountRate + points
        case .terminalGrowth:
            let points = adjustment / 10.0
            adjustedValuation.terminalGrowth = flowState.valuationAssumptions.terminalGrowth + points
        }
        
        // Calculate intrinsic value with adjusted parameters
        let intrinsic = calculateIntrinsicValue(
            revenueIndex: adjustedRevenueIndex,
            operating: adjustedOperating,
            valuation: adjustedValuation
        )
        
        let current = flowState.baselineCurrentPrice
        let upside = ((intrinsic - current) / current) * 100.0
        
        return (intrinsic, upside)
    }
    
    private func calculateTwoDimensional(
        xVariable: GridVariable,
        xAdjustment: Double,
        yVariable: GridVariable,
        yAdjustment: Double
    ) -> Double {
        var adjustedOperating = flowState.operatingAssumptions
        var adjustedValuation = flowState.valuationAssumptions
        
        // Apply X adjustment
        switch xVariable {
        case .discountRate:
            adjustedValuation.discountRate = flowState.valuationAssumptions.discountRate + xAdjustment
        case .operatingMargin:
            adjustedOperating.operatingMargin = flowState.operatingAssumptions.operatingMargin + (xAdjustment * 2)
        }
        
        // Apply Y adjustment
        switch yVariable {
        case .discountRate:
            adjustedValuation.discountRate = flowState.valuationAssumptions.discountRate + yAdjustment
        case .operatingMargin:
            adjustedOperating.operatingMargin = flowState.operatingAssumptions.operatingMargin + (yAdjustment * 2)
        }
        
        return calculateIntrinsicValue(
            revenueIndex: flowState.derivedTopLineRevenue,
            operating: adjustedOperating,
            valuation: adjustedValuation
        )
    }
    
    private func calculateIntrinsicValue(
        revenueIndex: Double,
        operating: OperatingAssumptions,
        valuation: ValuationAssumptions
    ) -> Double {
        // Calculate FCF index
        var fcfMarginApprox = max(0, operating.operatingMargin * (1.0 - operating.taxRate / 100.0) - operating.capexPercent - operating.workingCapitalPercent) / 100.0
        fcfMarginApprox = min(max(fcfMarginApprox, 0.0), 0.35)
        let fcfIndex = min(max(revenueIndex * fcfMarginApprox, 0.0), 120.0)
        
        // Calculate intrinsic value
        let baseScale = 1.2
        let pvFactor = 1.0 / max(0.01, valuation.discountRate / 100.0)
        let terminalFactor = 1.0 / max(0.01, (valuation.discountRate - valuation.terminalGrowth) / 100.0)
        
        let forecastPV = fcfIndex * baseScale * 0.9 * pvFactor
        let terminalPV = fcfIndex * baseScale * 0.6 * terminalFactor
        let intrinsic = forecastPV + terminalPV
        
        return min(max(intrinsic, 20.0), 800.0)
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        DSBottomBar {
            DSBottomBarPrimaryButton("Back to Valuation", icon: "arrow.left") {
                dismiss()
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

// MARK: - Variable Selector Chip

private struct VariableSelectorChip: View {
    let variable: SensitivityAnalysisView.SensitivityVariable
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(variable.rawValue)
                .font(DSTypography.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(
                    isSelected
                        ? DSColors.textPrimary
                        : DSColors.textSecondary
                )
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, DSSpacing.s)
                .padding(.vertical, DSSpacing.xs)
                .background(
                    isSelected
                        ? DSColors.accent
                        : DSColors.surface2
                )
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                        .stroke(
                            isSelected ? Color.clear : DSColors.border,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SensitivityAnalysisView()
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
