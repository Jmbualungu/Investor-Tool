//
//  InvestmentLensView.swift
//  Investor Tool
//
//  Investment lens selection screen for DCF Setup Flow
//

import SwiftUI

struct InvestmentLensView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    let onContinue: () -> Void
    
    @Namespace private var horizonAnimation
    @Namespace private var styleAnimation
    @Namespace private var objectiveAnimation
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xl) {
                        // Title and Microcopy
                        headerSection
                        
                        // Horizon Selector
                        sectionCard(title: "Time Horizon") {
                            horizonSelector
                        }
                        
                        // Style Selector
                        sectionCard(title: "Investment Style") {
                            styleSelector
                        }
                        
                        // Objective Selector
                        sectionCard(title: "Investment Objective") {
                            objectiveSelector
                        }
                        
                        // Preview Card
                        previewCard
                    }
                    .padding(DSSpacing.l)
                    .padding(.bottom, DSSpacing.xl)
                }
                
                // Bottom CTA Bar
                bottomBar
            }
        }
        .premiumFlowChrome(
            step: .lens,
            flowState: flowState
        )
        .navigationTitle("Investment Lens")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("Investment Lens")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            
            Text("Choose the lens that shapes your forecast assumptions.")
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Horizon Selector
    
    private var horizonSelector: some View {
        HStack(spacing: 0) {
            ForEach(DCFHorizon.allCases, id: \.self) { horizon in
                Button {
                    HapticManager.shared.selectionChanged()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        flowState.investmentLens.horizon = horizon
                    }
                } label: {
                    Text(horizon.displayName)
                        .font(DSTypography.subheadline)
                        .fontWeight(flowState.investmentLens.horizon == horizon ? .semibold : .regular)
                        .foregroundColor(
                            flowState.investmentLens.horizon == horizon
                                ? DSColors.textPrimary
                                : DSColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.buttonHeightCompact)
                        .background {
                            if flowState.investmentLens.horizon == horizon {
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
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Style Selector
    
    private var styleSelector: some View {
        HStack(spacing: 0) {
            ForEach(DCFInvestmentStyle.allCases, id: \.self) { style in
                Button {
                    HapticManager.shared.selectionChanged()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        flowState.investmentLens.style = style
                    }
                } label: {
                    Text(style.displayName)
                        .font(DSTypography.subheadline)
                        .fontWeight(flowState.investmentLens.style == style ? .semibold : .regular)
                        .foregroundColor(
                            flowState.investmentLens.style == style
                                ? DSColors.textPrimary
                                : DSColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.buttonHeightCompact)
                        .background {
                            if flowState.investmentLens.style == style {
                                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                                    .fill(DSColors.accent)
                                    .matchedGeometryEffect(id: "styleHighlight", in: styleAnimation)
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
    
    // MARK: - Objective Selector
    
    private var objectiveSelector: some View {
        VStack(spacing: DSSpacing.s) {
            ForEach(DCFInvestmentObjective.allCases, id: \.self) { objective in
                Button {
                    HapticManager.shared.selectionChanged()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        flowState.investmentLens.objective = objective
                    }
                } label: {
                    HStack {
                        Text(objective.displayName)
                            .font(DSTypography.body)
                            .fontWeight(flowState.investmentLens.objective == objective ? .semibold : .regular)
                            .foregroundColor(DSColors.textPrimary)
                        
                        Spacer()
                        
                        if flowState.investmentLens.objective == objective {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(DSColors.accent)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Circle()
                                .stroke(DSColors.border, lineWidth: 2)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(DSSpacing.m)
                    .background(
                        flowState.investmentLens.objective == objective
                            ? DSColors.accent.opacity(0.1)
                            : DSColors.surface2
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                            .stroke(
                                flowState.investmentLens.objective == objective
                                    ? DSColors.accent
                                    : DSColors.border,
                                lineWidth: flowState.investmentLens.objective == objective ? 2 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Preview Card
    
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack {
                Image(systemName: "eye.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DSColors.accent)
                
                Text("Preview")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
            }
            
            Text(flowState.investmentLens.previewText)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
                .animation(.easeInOut(duration: 0.3), value: flowState.investmentLens.previewText)
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        DSBottomBar {
            DSBottomBarPrimaryButton("Revenue Drivers", icon: "arrow.right") {
                onContinue()
            }
        }
    }
    
    // MARK: - Section Card Helper
    
    private func sectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text(title)
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            content()
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        InvestmentLensView(onContinue: {})
            .environmentObject(DCFFlowState())
    }
}
