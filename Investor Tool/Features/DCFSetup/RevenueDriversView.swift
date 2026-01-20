//
//  RevenueDriversView.swift
//  Investor Tool
//
//  Revenue drivers configuration screen for DCF Setup Flow
//

import SwiftUI

struct RevenueDriversView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    @State private var selectedPreset: PresetScenario? = .consensus
    
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xl) {
                        // Top-line Revenue Card
                        revenueIndexCard
                        
                        // Preset Toggles
                        presetToggles
                        
                        // Revenue Drivers
                        driversSection
                    }
                    .padding(DSSpacing.l)
                    .padding(.bottom, DSSpacing.xl)
                }
                
                // Bottom CTA Bar
                bottomBar
            }
        }
        .premiumFlowChrome(
            step: .revenueDrivers,
            flowState: flowState
        )
        .navigationTitle("Revenue Drivers")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Apply consensus preset on first appearance
            if selectedPreset == .consensus {
                flowState.applyPreset(.consensus)
            }
        }
    }
    
    // MARK: - Revenue Index Card
    
    private var revenueIndexCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Top-line Revenue (Indexed)")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(String(format: "%.0f", flowState.derivedTopLineRevenue))
                .font(DSTypography.displayNumberMedium)
                .foregroundColor(DSColors.textPrimary)
                .animation(Motion.emphasize, value: flowState.derivedTopLineRevenue)
            
            Text("Updates live as you adjust drivers below")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
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
    }
    
    // MARK: - Preset Toggles
    
    private var presetToggles: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Quick Presets")
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s) {
                    ForEach(PresetScenario.allCases, id: \.self) { preset in
                        presetPill(preset)
                    }
                }
            }
        }
    }
    
    private func presetPill(_ preset: PresetScenario) -> some View {
        Button {
            HapticManager.shared.impact(style: .light)
            Motion.withAnimation(Motion.emphasize) {
                selectedPreset = preset
                flowState.applyPreset(preset)
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
        .pressableScale()
    }
    
    // MARK: - Drivers Section
    
    private var driversSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Text("Adjust Drivers")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                if flowState.isAnyRevenueDriverDrifted() {
                    DriftBadge()
                }
                
                Spacer()
                
                if flowState.isAnyRevenueDriverDrifted() {
                    Button {
                        HapticManager.shared.impact(style: .light)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            flowState.revertRevenueDriversToBase()
                        }
                    } label: {
                        Text("Revert")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DSColors.accent)
                    }
                }
            }
            
            ForEach(flowState.revenueDrivers.indices, id: \.self) { index in
                driverCard(at: index)
            }
        }
    }
    
    private func driverCard(at index: Int) -> some View {
        let driver = flowState.revenueDrivers[index]
        let isDrifted = flowState.isRevenueDriverDrifted(driverID: driver.id)
        
        return VStack(alignment: .leading, spacing: DSSpacing.l) {
            // Title and Subtitle
            HStack(alignment: .top, spacing: DSSpacing.s) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(driver.title)
                        .font(DSTypography.headline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text(driver.subtitle)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
                
                Spacer(minLength: DSSpacing.m)
                
                if isDrifted {
                    DSInlineBadge.edited()
                }
            }
            
            // Value Display (Large)
            HStack {
                Spacer()
                Text(driver.unit.format(driver.value))
                    .font(.system(size: 28, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundColor(DSColors.accent)
                    .animation(.easeInOut(duration: 0.2), value: driver.value)
            }
            
            // Slider
            VStack(spacing: DSSpacing.s) {
                Slider(
                    value: Binding(
                        get: { driver.value },
                        set: { newValue in
                            updateDriver(at: index, with: newValue)
                        }
                    ),
                    in: driver.min...driver.max,
                    step: driver.step
                )
                .tint(DSColors.accent)
                
                // Min/Max Labels
                HStack {
                    Text(driver.unit.format(driver.min))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DSColors.textTertiary)
                    
                    Spacer()
                    
                    Text(driver.unit.format(driver.max))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DSColors.textTertiary)
                }
            }
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                .stroke(isDrifted ? DSColors.accent.opacity(0.3) : DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        DSBottomBar {
            DSBottomBarPrimaryButton("Operating Assumptions", icon: "arrow.right") {
                onContinue()
            }
        } secondary: {
            DSBottomBarSecondaryButton("Reset to defaults", icon: "arrow.counterclockwise") {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    selectedPreset = .consensus
                    flowState.applyPreset(.consensus)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateDriver(at index: Int, with newValue: Double) {
        let driver = flowState.revenueDrivers[index]
        flowState.revenueDrivers[index] = RevenueDriver(
            id: driver.id,
            title: driver.title,
            subtitle: driver.subtitle,
            unit: driver.unit,
            value: newValue,
            min: driver.min,
            max: driver.max,
            step: driver.step,
            impactsRevenue: driver.impactsRevenue
        )
        
        // Mark that user has made custom changes
        if selectedPreset != .base {
            selectedPreset = .base
            flowState.saveBaseSnapshot()
        }
    }
}

#Preview {
    NavigationStack {
        RevenueDriversView(onContinue: {})
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
