//
//  PremiumFlowChrome.swift
//  Investor Tool
//
//  Premium flow UI components: progress bar, sticky header, and flow wrapper
//

import SwiftUI

// MARK: - FlowStep

enum FlowStep: Int, CaseIterable {
    case ticker = 1
    case context = 2
    case lens = 3
    case revenueDrivers = 4
    case operating = 5
    case valuationAssumptions = 6
    case valuationResults = 7
    case sensitivity = 8
    
    var index: Int { rawValue }
    
    var title: String {
        switch self {
        case .ticker: return "Ticker"
        case .context: return "Context"
        case .lens: return "Lens"
        case .revenueDrivers: return "Revenue"
        case .operating: return "Operating"
        case .valuationAssumptions: return "Valuation"
        case .valuationResults: return "Results"
        case .sensitivity: return "Sensitivity"
        }
    }
    
    static var totalSteps: Int { 8 }
    
    var canNavigateBackToRevenue: Bool {
        switch self {
        case .operating, .valuationAssumptions, .valuationResults, .sensitivity:
            return true
        default:
            return false
        }
    }
}

// MARK: - PremiumProgressBar

struct PremiumProgressBar: View {
    let currentStep: FlowStep
    
    private var progress: Double {
        Double(currentStep.index) / Double(FlowStep.totalSteps)
    }
    
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            // Step label
            Text("Step \(currentStep.index) of \(FlowStep.totalSteps)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DSColors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(DSColors.surface2)
                        .frame(height: 4)
                    
                    // Progress fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [DSColors.accent, DSColors.accent.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - StickyMiniHeader

struct StickyMiniHeader: View {
    let tickerSymbol: String?
    let tickerName: String?
    let horizonLabel: String?
    let stepTitle: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header content
            HStack(spacing: DSSpacing.m) {
                // Left: Ticker info
                if let symbol = tickerSymbol {
                    HStack(spacing: DSSpacing.xs) {
                        Text(symbol)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        if let name = tickerName {
                            Text(name)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(DSColors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                } else {
                    Text("DCF Setup")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                }
                
                Spacer()
                
                // Right: Horizon pill
                if let horizon = horizonLabel {
                    Text(horizon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(DSColors.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(DSColors.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
            }
            .padding(.horizontal, DSSpacing.l)
            .padding(.top, DSSpacing.m)
            .padding(.bottom, DSSpacing.xs)
            
            // Step title
            Text(stepTitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DSColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DSSpacing.l)
                .padding(.bottom, DSSpacing.m)
            
            // Divider
            Divider()
                .background(DSColors.border.opacity(0.5))
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - PremiumFlowChrome

struct PremiumFlowChrome<Content: View>: View {
    let step: FlowStep
    let flowState: DCFFlowState
    let showBackToRevenueDrivers: Bool
    let onBackToRevenueDrivers: (() -> Void)?
    let content: Content
    
    init(
        step: FlowStep,
        flowState: DCFFlowState,
        showBackToRevenueDrivers: Bool = false,
        onBackToRevenueDrivers: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.step = step
        self.flowState = flowState
        self.showBackToRevenueDrivers = showBackToRevenueDrivers
        self.onBackToRevenueDrivers = onBackToRevenueDrivers
        self.content = content()
    }
    
    private var tickerSymbol: String? {
        flowState.selectedTicker?.symbol
    }
    
    private var tickerName: String? {
        flowState.selectedTicker?.name
    }
    
    private var horizonLabel: String? {
        step.index >= FlowStep.lens.index ? flowState.investmentLens.horizon.displayName : nil
    }
    
    private var shouldShowBackButton: Bool {
        showBackToRevenueDrivers && step.canNavigateBackToRevenue && step != .revenueDrivers
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky header
            StickyMiniHeader(
                tickerSymbol: tickerSymbol,
                tickerName: tickerName,
                horizonLabel: horizonLabel,
                stepTitle: step.title
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
            
            // Progress bar
            VStack(spacing: DSSpacing.s) {
                PremiumProgressBar(currentStep: step)
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.top, DSSpacing.m)
                
                // "Back to Revenue Drivers" button
                if shouldShowBackButton, let onBack = onBackToRevenueDrivers {
                    Button {
                        HapticManager.shared.impact(style: .light)
                        onBack()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 11, weight: .semibold))
                            
                            Text("Back to Revenue Drivers")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(DSColors.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DSColors.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DSSpacing.l)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, DSSpacing.s)
            .background(DSColors.background)
            
            Divider()
                .background(DSColors.border.opacity(0.3))
            
            // Main content
            content
        }
        .animation(.easeInOut(duration: 0.3), value: shouldShowBackButton)
        .animation(.easeInOut(duration: 0.3), value: step)
    }
}

// MARK: - View Extension for easy application

extension View {
    func premiumFlowChrome(
        step: FlowStep,
        flowState: DCFFlowState,
        showBackToRevenueDrivers: Bool = false,
        onBackToRevenueDrivers: (() -> Void)? = nil
    ) -> some View {
        PremiumFlowChrome(
            step: step,
            flowState: flowState,
            showBackToRevenueDrivers: showBackToRevenueDrivers,
            onBackToRevenueDrivers: onBackToRevenueDrivers
        ) {
            self
        }
    }
}
