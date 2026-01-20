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
            AbstractBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? DSColors.accent : DSColors.textTertiary.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(Motion.emphasize, value: currentPage)
                    }
                }
                .padding(.vertical, DSSpacing.l)
                
                // CTA Button
                if currentPage == totalPages - 1 {
                    Button {
                        completeOnboarding()
                    } label: {
                        Text(Copy.startForecasting)
                            .fontWeight(.semibold)
                    }
                    .primaryCTAStyle()
                    .pressableScale()
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.bottom, DSSpacing.xl)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Button {
                        Motion.withAnimation(Motion.screenTransition) {
                            currentPage += 1
                        }
                    } label: {
                        Text(Copy.continueCTA)
                            .fontWeight(.semibold)
                    }
                    .secondaryCTAStyle()
                    .pressableScale()
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.bottom, DSSpacing.xl)
                }
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
                    Text("Build a Forecast")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text("Understand value, not just price.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text("This tool helps you explore how assumptions drive valuation using a transparent DCF model.")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
                Text("How it works")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    howItWorksRow(
                        icon: "building.2",
                        title: "Choose a company",
                        description: "Pick any ticker to analyze"
                    )
                    
                    howItWorksRow(
                        icon: "slider.horizontal.3",
                        title: "Shape assumptions",
                        description: "Adjust growth, margins, and risk"
                    )
                    
                    howItWorksRow(
                        icon: "chart.bar.doc.horizontal",
                        title: "See valuation & sensitivity",
                        description: "Understand what drives the numbers"
                    )
                }
                
                Text("No financial advice. Just structured thinking.")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textTertiary)
                    .padding(.top, DSSpacing.m)
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
                Text("You're in control")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                    .onLongPressGesture(minimumDuration: 2.0) {
                        // Toggle marketing mode on long press (hidden developer feature)
                        HapticManager.shared.impact(style: .medium)
                        marketingMode.toggle()
                        AppLogger.log("Marketing mode toggled: \(marketingMode)", category: .userAction)
                    }
                
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    featureHighlight(
                        icon: "slider.horizontal.2.square",
                        title: "Assumption sliders",
                        description: "Fine-tune every input to match your view"
                    )
                    
                    featureHighlight(
                        icon: "arrow.triangle.branch",
                        title: "Scenarios",
                        description: "Compare Bear, Base, and Bull cases instantly"
                    )
                    
                    featureHighlight(
                        icon: "tablecells",
                        title: "Sensitivity analysis",
                        description: "See how changes affect valuation"
                    )
                }
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
