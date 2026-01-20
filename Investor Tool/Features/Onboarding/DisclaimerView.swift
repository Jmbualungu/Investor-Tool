//
//  DisclaimerView.swift
//  Investor Tool
//
//  Required financial disclaimer screen for onboarding
//  Must be accepted before proceeding to the rest of the app
//

import SwiftUI

struct DisclaimerView: View {
    @StateObject private var disclaimerManager = DisclaimerManager()
    @State private var hasAcceptedCheckbox = false
    @State private var hasScrolledToBottom = false
    
    let onAccept: () -> Void
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with icon
                header
                    .padding(.top, DSSpacing.xl)
                    .padding(.horizontal, DSSpacing.l)
                
                // Scrollable disclaimer content
                disclaimerContent
                    .padding(.top, DSSpacing.l)
                
                // Checkbox
                checkboxSection
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.top, DSSpacing.m)
                
                // Accept button
                acceptButton
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.top, DSSpacing.m)
                    .padding(.bottom, DSSpacing.xl)
                
                // Optional microcopy
                trustMicrocopy
                    .padding(.bottom, DSSpacing.m)
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: DSSpacing.m) {
            // Icon
            ZStack {
                Circle()
                    .fill(DSColors.surface)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(DSColors.border, lineWidth: 1)
                    )
                
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(DSColors.accent)
            }
            
            VStack(spacing: DSSpacing.s) {
                Text("Important Disclosure")
                    .dsTitle()
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Disclaimer Content
    
    private var disclaimerContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    // Track scroll position
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                    }
                    .frame(height: 0)
                    
                    Text(disclaimerBodyText)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Bottom marker for scroll tracking
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(DSSpacing.l)
            }
            .frame(maxHeight: 320)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                // Check if scrolled near bottom (within 100 points of content height)
                if offset < -100 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        hasScrolledToBottom = true
                    }
                }
            }
        }
        .padding(.horizontal, DSSpacing.l)
    }
    
    private var disclaimerBodyText: String {
        """
ForecastAI provides financial forecasts, simulations, and analytical tools for educational and informational purposes only.

ForecastAI does not provide investment advice, financial advice, or recommendations to buy or sell any securities. All forecasts are hypothetical, forward-looking, and based on user-defined assumptions that may not reflect real-world outcomes.

Investing involves risk, including the possible loss of principal. Past performance and simulated results are not indicative of future results.

You are solely responsible for any investment decisions you make. We recommend consulting a licensed financial professional before making financial decisions.
"""
    }
    
    // MARK: - Checkbox Section
    
    private var checkboxSection: some View {
        Button {
            HapticManager.shared.impact(style: .light)
            hasAcceptedCheckbox.toggle()
        } label: {
            HStack(alignment: .top, spacing: DSSpacing.m) {
                Image(systemName: hasAcceptedCheckbox ? "checkmark.square.fill" : "square")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(hasAcceptedCheckbox ? DSColors.accent : DSColors.textSecondary)
                
                Text("I understand and acknowledge that ForecastAI is not providing financial advice.")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Accept Button
    
    private var acceptButton: some View {
        Button {
            HapticManager.shared.impact(style: .medium)
            disclaimerManager.accept()
            onAccept()
        } label: {
            Text("Accept & Continue")
                .fontWeight(.semibold)
        }
        .primaryCTAStyle()
        .disabled(!hasAcceptedCheckbox)
        .opacity(hasAcceptedCheckbox ? 1.0 : 0.5)
    }
    
    // MARK: - Trust Microcopy
    
    private var trustMicrocopy: some View {
        Text("This helps us keep ForecastAI transparent and responsible.")
            .font(DSTypography.caption)
            .foregroundColor(DSColors.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, DSSpacing.xl)
    }
}

// MARK: - Preference Key for Scroll Tracking

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    DisclaimerView {
        print("Disclaimer accepted")
    }
}
