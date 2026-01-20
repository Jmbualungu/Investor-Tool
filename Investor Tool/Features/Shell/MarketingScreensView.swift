//
//  MarketingScreensView.swift
//  Investor Tool
//
//  Screenshot-ready marketing screens for App Store and promotional materials
//

import SwiftUI

struct MarketingScreensView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentSlide = 0
    
    private let totalSlides = 5
    
    var body: some View {
        NavigationStack {
            ZStack {
                AbstractBackground()
                    .ignoresSafeArea()
                
                TabView(selection: $currentSlide) {
                    slide1
                        .tag(0)
                    
                    slide2
                        .tag(1)
                    
                    slide3
                        .tag(2)
                    
                    slide4
                        .tag(3)
                    
                    slide5
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .navigationTitle("Preview Screens")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Slide 1: Hero
    
    private var slide1: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {
            Spacer()
            
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                // Hero headline
                Text(Copy.forecastWithClarity)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)
                    .lineSpacing(4)
                
                Text("Build data-driven valuations with transparent DCF modeling. See what drives the numbers.")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DSColors.textSecondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Mock UI snippet: Mini value card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Intrinsic Value")
                            .font(DS.Typography.caption())
                            .foregroundColor(DSColors.textSecondary)
                        
                        Text("$185.50")
                            .font(DS.Typography.monoNumber(32))
                            .foregroundColor(DSColors.accent)
                    }
                    
                    Spacer()
                    
                    // Mini sparkline
                    Sparkline(
                        points: [150, 165, 175, 180, 185, 190],
                        height: 40
                    )
                    .frame(width: 100)
                }
                .padding(DS.Spacing.lg)
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
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.lg, style: .continuous)
                        .stroke(DSColors.accent.opacity(0.3), lineWidth: 1.5)
                )
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xxl)
    }
    
    // MARK: - Slide 2: Assumptions
    
    private var slide2: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {
            Spacer()
            
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                Text(Copy.assumptionsYouControl)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)
                
                Text("Fine-tune revenue growth, margins, and discount rates with intuitive sliders.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DSColors.textSecondary)
                    .lineSpacing(4)
                
                // Mock slider UI
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Revenue Growth")
                            .font(DS.Typography.headline())
                            .foregroundColor(DSColors.textPrimary)
                        
                        Text("Annual growth rate")
                            .font(DS.Typography.caption())
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    HStack {
                        Spacer()
                        Text("12.5%")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(DSColors.accent)
                    }
                    
                    // Mock slider (non-interactive for screenshot)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(DSColors.surface2)
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(DSColors.accent)
                                .frame(width: geo.size.width * 0.625, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(DS.Spacing.lg)
                .background(DSColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .stroke(DSColors.border, lineWidth: 1)
                )
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xxl)
    }
    
    // MARK: - Slide 3: Scenario Compare
    
    private var slide3: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {
            Spacer()
            
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                Text(Copy.scenarioCompare)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)
                
                Text("Compare Bear, Base, and Bull scenarios side-by-side.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DSColors.textSecondary)
                    .lineSpacing(4)
                
                // Mock scenario grid
                HStack(spacing: DS.Spacing.md) {
                    scenarioMiniCard(title: "Bear", value: "$142", upside: "-8.2%", color: .blue)
                    scenarioMiniCard(title: "Base", value: "$165", upside: "+15.0%", color: DSColors.accent)
                    scenarioMiniCard(title: "Bull", value: "$198", upside: "+38.5%", color: .orange)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xxl)
    }
    
    private func scenarioMiniCard(title: String, value: String, upside: String, color: Color) -> some View {
        VStack(spacing: DS.Spacing.sm) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DSColors.textSecondary)
            
            Divider()
                .background(DSColors.border)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Text(upside)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Mini sparkline mock
            Sparkline(
                points: title == "Bear" ? [155, 150, 145, 142, 140, 142] :
                        title == "Base" ? [150, 155, 160, 162, 165, 168] :
                        [150, 165, 180, 190, 195, 198],
                height: 20
            )
            .opacity(0.6)
        }
        .frame(maxWidth: .infinity)
        .padding(DS.Spacing.md)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Slide 4: Sensitivity
    
    private var slide4: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xl) {
            Spacer()
            
            VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                Text(Copy.sensitivityAtAGlance)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)
                
                Text("Test how changes in key assumptions affect your valuation.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DSColors.textSecondary)
                    .lineSpacing(4)
                
                // Mock sensitivity table
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Adjustment")
                            .font(DS.Typography.caption())
                            .foregroundColor(DSColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Value")
                            .font(DS.Typography.caption())
                            .foregroundColor(DSColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(DS.Spacing.md)
                    .background(DSColors.surface2)
                    
                    Divider().background(DSColors.border)
                    
                    sensitivityMockRow(label: "-10%", value: "$148", isBase: false)
                    Divider().background(DSColors.border)
                    sensitivityMockRow(label: "Base", value: "$165", isBase: true)
                    Divider().background(DSColors.border)
                    sensitivityMockRow(label: "+10%", value: "$182", isBase: false)
                }
                .background(DSColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                        .stroke(DSColors.border, lineWidth: 1)
                )
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xxl)
    }
    
    private func sensitivityMockRow(label: String, value: String, isBase: Bool) -> some View {
        HStack {
            Text(label)
                .font(isBase ? DS.Typography.body(.semibold) : DS.Typography.body())
                .foregroundColor(isBase ? DSColors.accent : DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(value)
                .font(isBase ? DS.Typography.body(.semibold) : DS.Typography.body())
                .foregroundColor(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(DS.Spacing.md)
        .background(isBase ? DSColors.accent.opacity(0.1) : Color.clear)
    }
    
    // MARK: - Slide 5: Trust & Disclaimer
    
    private var slide5: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Spacer()
            
            VStack(spacing: DS.Spacing.xl) {
                // Icon
                ZStack {
                    Circle()
                        .fill(DSColors.accent.opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(DSColors.accent)
                }
                
                VStack(spacing: DS.Spacing.lg) {
                    Text("Transparent. Educational. Yours.")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(DSColors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: DS.Spacing.md) {
                        trustRow(icon: "eye.slash.fill", text: "No tracking, no ads")
                        trustRow(icon: "book.fill", text: "Educational purposes only")
                        trustRow(icon: "shield.fill", text: "Your data stays on device")
                    }
                    
                    Text(Copy.notFinancialAdvice)
                        .font(DS.Typography.caption(.medium))
                        .foregroundColor(DSColors.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, DS.Spacing.md)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.xxl)
    }
    
    private func trustRow(icon: String, text: String) -> some View {
        HStack(spacing: DS.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DSColors.accent)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DSColors.surface.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm, style: .continuous))
    }
}

#Preview {
    MarketingScreensView()
}
