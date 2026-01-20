//
//  FirstLaunchOnboardingView.swift
//  Investor Tool
//
//  First-run onboarding experience
//

import SwiftUI

struct FirstLaunchOnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("marketingMode") private var marketingMode = false
    @State private var currentPage = 0
    @State private var titleLongPressStartTime: Date?
    let onComplete: () -> Void
    
    private let totalPages = 3
    
    var body: some View {
        ZStack {
            // Background - must not intercept gestures
            AbstractBackground()
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            VStack(spacing: 0) {
                // Top bar with Skip button
                HStack {
                    Spacer()
                    
                    Button {
                        HapticManager.shared.impact(style: .light)
                        completeOnboarding()
                    } label: {
                        Text("Skip")
                            .font(DSTypography.body)
                            .fontWeight(.semibold)
                            .foregroundColor(DSColors.accent)
                    }
                    .padding(.trailing, DSSpacing.l)
                    .padding(.top, DSSpacing.m)
                }
                
                // TabView with pages
                TabView(selection: $currentPage) {
                    page1
                        .tag(0)
                    
                    page2
                        .tag(1)
                    
                    page3
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(Motion.screenTransition, value: currentPage)
                
                // Premium progress dots
                OnboardingProgressDots(currentIndex: currentPage, total: totalPages)
                    .padding(.vertical, DSSpacing.l)
                
                // Bottom controls (Back + Next/Start)
                VStack(spacing: DSSpacing.s) {
                    // Micro hint on page 2
                    if currentPage == 1 {
                        Text("You can adjust assumptions anytime.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(DSColors.textTertiary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    HStack(spacing: DSSpacing.m) {
                        // Back button
                        if currentPage > 0 {
                            Button {
                                HapticManager.shared.impact(style: .light)
                                Motion.withAnimation(Motion.screenTransition) {
                                    currentPage -= 1
                                }
                            } label: {
                                HStack(spacing: DSSpacing.s) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Back")
                                }
                                .fontWeight(.semibold)
                            }
                            .secondaryCTAStyle()
                            .pressableScale()
                            .transition(.opacity.combined(with: .move(edge: .leading)))
                        }
                        
                        // Next or Start button
                        if currentPage == totalPages - 1 {
                            Button {
                                HapticManager.shared.impact(style: .medium)
                                completeOnboarding()
                            } label: {
                                Text("Start")
                                    .fontWeight(.semibold)
                            }
                            .primaryCTAStyle()
                            .shimmerOverlay(enabled: true)
                            .pressableScale()
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        } else {
                            Button {
                                HapticManager.shared.impact(style: .light)
                                Motion.withAnimation(Motion.screenTransition) {
                                    currentPage += 1
                                }
                            } label: {
                                HStack(spacing: DSSpacing.s) {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .fontWeight(.semibold)
                            }
                            .primaryCTAStyle()
                            .shimmerOverlay(enabled: true)
                            .pressableScale()
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.l)
                .padding(.bottom, DSSpacing.xl)
            }
        }
    }
    
    private var page1: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xl) {
            Spacer()
            
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                // Icon
                ZStack {
                    Circle()
                        .fill(DSColors.accent.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(DSColors.accent)
                }
                
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    // Parallax title
                    ParallaxTitle(
                        title: "Build a Forecast",
                        subtitle: nil,
                        pageIndex: currentPage
                    )
                    
                    Text("Understand value, not just price.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text("This tool helps you explore how assumptions drive valuation using a transparent DCF model.")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Preview card (simple)
                ResultsPreviewCard(variant: .simple)
                
                // Quote card
                QuoteCard(quote: InvestorQuotes.onboarding[0])
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DSSpacing.xl)
    }
    
    private var page2: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xl) {
            Spacer()
            
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                // Parallax title
                ParallaxTitle(
                    title: "Control the Drivers",
                    subtitle: "Change assumptions and see valuation update instantly.",
                    pageIndex: currentPage
                )
                
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    howItWorksRow(
                        icon: "arrow.up.forward.circle.fill",
                        title: "Revenue Growth",
                        description: "Set growth rates and runway"
                    )
                    
                    howItWorksRow(
                        icon: "slider.horizontal.3",
                        title: "Operating Margins",
                        description: "Adjust profitability assumptions"
                    )
                    
                    howItWorksRow(
                        icon: "chart.bar.doc.horizontal.fill",
                        title: "Valuation Multiples",
                        description: "Control discount rate and exit"
                    )
                }
                
                // Quote card
                QuoteCard(quote: InvestorQuotes.onboarding[1])
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DSSpacing.xl)
    }
    
    private var page3: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xl) {
            Spacer()
            
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                // Parallax title
                ParallaxTitle(
                    title: "See the Range",
                    subtitle: "Explore scenarios and understand what matters most.",
                    pageIndex: currentPage
                )
                .onLongPressGesture(minimumDuration: 2.0) {
                    // Toggle marketing mode on long press (hidden developer feature)
                    HapticManager.shared.impact(style: .medium)
                    marketingMode.toggle()
                }
                
                // Preview card (full variant with scenarios)
                ResultsPreviewCard(variant: .full)
                
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    featureHighlight(
                        icon: "arrow.triangle.branch",
                        title: "Bear, Base, and Bull scenarios",
                        description: "Switch instantly between cases"
                    )
                    
                    featureHighlight(
                        icon: "tablecells",
                        title: "Sensitivity analysis",
                        description: "See how assumptions drive valuation"
                    )
                    
                    featureHighlight(
                        icon: "square.and.arrow.up",
                        title: "Save and share (coming soon)",
                        description: "Export your forecasts"
                    )
                }
                
                // Quote card
                QuoteCard(quote: InvestorQuotes.onboarding[2])
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DSSpacing.xl)
    }
    
    private func howItWorksRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.m) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DSColors.surface)
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(DSColors.border, lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DSColors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                Text(description)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func featureHighlight(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .center, spacing: DSSpacing.m) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(DSColors.accent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                Text(description)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func completeOnboarding() {
        Motion.withAnimation(Motion.appear) {
            hasSeenOnboarding = true
        }
        onComplete()
    }
}

#Preview {
    FirstLaunchOnboardingView(onComplete: {})
}
