//
//  ValuationAssumptionsView.swift
//  Investor Tool
//
//  Valuation assumptions screen for DCF Setup Flow
//

import SwiftUI

struct ValuationAssumptionsView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @Environment(\.navigationPath) private var navigationPath
    @State private var selectedMode: AssumptionMode = .basic
    @State private var marginOfSafety: Double = 0.0
    @State private var validationTask: Task<Void, Never>?
    
    let onContinue: () -> Void
    
    enum AssumptionMode: String, CaseIterable {
        case basic = "Basic"
        case advanced = "Advanced"
    }
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Header
                    headerSection
                    
                    // Mode Selector
                    modeSelector
                    
                    // Basic Controls
                    basicControlsCard
                    
                    // Advanced Controls (if selected)
                    if selectedMode == .advanced {
                        advancedControlsCard
                    }
                    
                    // Educational Disclosures
                    educationalSection
                    
                    // Continue Button
                    continueButton
                }
                .padding(DSSpacing.l)
            }
        }
        .premiumFlowChrome(
            step: .valuationAssumptions,
            flowState: flowState,
            showBackToRevenueDrivers: true,
            onBackToRevenueDrivers: {
                if let path = navigationPath {
                    flowState.popToRevenueDrivers(path: path)
                }
            }
        )
        .navigationTitle("Valuation Assumptions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            flowState.saveValuationSnapshot()
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("Valuation Assumptions")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            
            Text("Set the assumptions that drive your intrinsic value calculation.")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Mode Selector
    
    private var modeSelector: some View {
        HStack(spacing: 0) {
            ForEach(AssumptionMode.allCases, id: \.self) { mode in
                Button {
                    HapticManager.shared.selectionChanged()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(DSTypography.subheadline)
                        .fontWeight(selectedMode == mode ? .semibold : .regular)
                        .foregroundColor(
                            selectedMode == mode
                                ? DSColors.textPrimary
                                : DSColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.buttonHeightCompact)
                        .background {
                            if selectedMode == mode {
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
    
    // MARK: - Basic Controls
    
    private var basicControlsCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            HStack {
                Text("Core Assumptions")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                if flowState.isValuationDrifted() {
                    DriftBadge()
                }
                
                Spacer()
                
                if flowState.isValuationDrifted() {
                    Button {
                        HapticManager.shared.impact(style: .light)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            flowState.revertValuationToBase()
                        }
                    } label: {
                        Text("Revert")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DSColors.accent)
                    }
                }
            }
            
            // Terminal Growth Validation
            if flowState.valuationAssumptions.terminalGrowth > flowState.valuationAssumptions.discountRate - 0.5 {
                WarningBanner(
                    title: "Terminal Growth Too High",
                    message: "Terminal growth should be at least 0.5% below the discount rate. It will be auto-adjusted.",
                    severity: .warn,
                    explanation: "If terminal growth equals or exceeds the discount rate, the DCF formula breaks down mathematically, leading to infinite or negative valuations. This constraint ensures a stable, realistic perpetuity calculation."
                )
            }
            
            VStack(spacing: DSSpacing.l) {
                sliderRow(
                    title: "Discount Rate",
                    subtitle: "Your required rate of return (WACC)",
                    value: $flowState.valuationAssumptions.discountRate,
                    range: 6...14,
                    step: 0.5,
                    format: "%.1f%%"
                )
                
                sliderRow(
                    title: "Terminal Growth",
                    subtitle: "Long-term perpetual growth rate",
                    value: $flowState.valuationAssumptions.terminalGrowth,
                    range: 0...4,
                    step: 0.5,
                    format: "%.1f%%"
                )
            }
            
            Divider()
                .background(DSColors.border)
            
            // Terminal Method Picker
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("Terminal Value Method")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                
                VStack(spacing: DSSpacing.s) {
                    ForEach(TerminalMethod.allCases) { method in
                        methodRow(method)
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
    }
    
    private func methodRow(_ method: TerminalMethod) -> some View {
        Button {
            if method == .perpetuity {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    flowState.valuationAssumptions.terminalMethod = method
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .font(DSTypography.body)
                        .foregroundColor(
                            method == .exitMultiple
                                ? DSColors.textTertiary
                                : DSColors.textPrimary
                        )
                    
                    if method == .exitMultiple {
                        Text("Coming soon")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(DSColors.textTertiary)
                    }
                }
                
                Spacer()
                
                if flowState.valuationAssumptions.terminalMethod == method {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(DSColors.accent)
                        .transition(.scale.combined(with: .opacity))
                } else if method == .perpetuity {
                    Circle()
                        .stroke(DSColors.border, lineWidth: 2)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(DSSpacing.m)
            .background(
                flowState.valuationAssumptions.terminalMethod == method
                    ? DSColors.accent.opacity(0.1)
                    : (method == .exitMultiple ? DSColors.surface2.opacity(0.5) : DSColors.surface2)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                    .stroke(
                        flowState.valuationAssumptions.terminalMethod == method
                            ? DSColors.accent
                            : DSColors.border,
                        lineWidth: flowState.valuationAssumptions.terminalMethod == method ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(method == .exitMultiple)
    }
    
    // MARK: - Advanced Controls
    
    private var advancedControlsCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DSColors.accent)
                
                Text("Advanced Options")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
            }
            
            sliderRow(
                title: "Margin of Safety",
                subtitle: "Additional discount for conservatism",
                value: $marginOfSafety,
                range: 0...30,
                step: 5.0,
                format: "%.0f%%"
            )
            
            Text("Note: Margin of safety will be applied to the final intrinsic value display.")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
                .lineSpacing(4)
        }
        .padding(DSSpacing.l)
        .background(
            LinearGradient(
                colors: [
                    DSColors.accent.opacity(0.15),
                    DSColors.accent.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.accent.opacity(0.3), lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Educational Section
    
    private var educationalSection: some View {
        VStack(spacing: DSSpacing.m) {
            disclosureRow(
                title: "What is the discount rate?",
                icon: "questionmark.circle.fill",
                content: "The discount rate (WACC) represents your required rate of return. It accounts for the risk of the investment and the time value of money. A higher rate results in a lower intrinsic value."
            )
            
            disclosureRow(
                title: "What is terminal growth?",
                icon: "questionmark.circle.fill",
                content: "Terminal growth is the perpetual rate at which the company is expected to grow beyond your forecast period. It's typically set to GDP growth rates (2-3%). Setting it too high can overvalue the company."
            )
        }
    }
    
    private func disclosureRow(title: String, icon: String, content: String) -> some View {
        DisclosureGroup {
            Text(content)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
                .padding(.top, DSSpacing.s)
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DSColors.accent)
                
                Text(title)
                    .font(DSTypography.subheadline)
                    .foregroundColor(DSColors.textPrimary)
            }
        }
        .padding(DSSpacing.m)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
        .tint(DSColors.accent)
    }
    
    // MARK: - Slider Row
    
    private func sliderRow(
        title: String,
        subtitle: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        format: String
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
                
                Text(String(format: format, value.wrappedValue))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DSColors.accent)
                    .frame(minWidth: 60, alignment: .trailing)
                    .animation(.easeInOut(duration: 0.2), value: value.wrappedValue)
            }
            
            Slider(value: value, in: range, step: step)
                .tint(DSColors.accent)
                .onChange(of: value.wrappedValue) { _, _ in
                    // Debounced validation and auto-clamp
                    validationTask?.cancel()
                    validationTask = Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(250))
                        
                        guard !Task.isCancelled else { return }
                        
                        // Auto-clamp terminal growth if it's too close to discount rate
                        let maxTerminalGrowth = flowState.valuationAssumptions.discountRate - 0.5
                        if flowState.valuationAssumptions.terminalGrowth > maxTerminalGrowth {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                flowState.valuationAssumptions.terminalGrowth = max(0, maxTerminalGrowth)
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
            Text(Copy.viewValuation)
                .fontWeight(.semibold)
        }
        .primaryCTAStyle()
        .pressableScale()
    }
}

#Preview {
    NavigationStack {
        ValuationAssumptionsView(onContinue: {})
            .environmentObject(DCFFlowState())
    }
}
