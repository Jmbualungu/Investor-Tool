//
//  CompanyContextView.swift
//  Investor Tool
//
//  Company context screen for DCF Setup Flow
//

import SwiftUI

struct CompanyContextView: View {
    @EnvironmentObject private var flowState: DCFFlowState
    let ticker: DCFTicker
    let onContinue: () -> Void
    
    @State private var showWhyThisMatters = false
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.xl) {
                        // Header Card
                        headerCard
                        
                        // About Section
                        aboutSection
                        
                        // Why This Matters
                        whyThisMattersSection
                    }
                    .padding(DSSpacing.l)
                    .padding(.bottom, DSSpacing.xl)
                }
                
                // Bottom CTA Bar
                bottomBar
            }
        }
        .premiumFlowChrome(
            step: .context,
            flowState: flowState
        )
        .navigationTitle("Company Context")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            // Symbol and Name
            VStack(alignment: .leading, spacing: 6) {
                Text(ticker.symbol)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(DSColors.textPrimary)
                
                Text(ticker.name)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
            }
            
            // Price if available
            if let price = ticker.currentPrice {
                Text("$\(price, specifier: "%.2f")")
                    .font(DSTypography.displayNumberSmall)
                    .foregroundColor(DSColors.textPrimary)
            }
            
            Divider()
                .background(DSColors.divider)
            
            // Metadata Pills
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                HStack(spacing: DSSpacing.s) {
                    DSInlineBadge(ticker.sector, style: .neutral)
                    DSInlineBadge(ticker.industry, style: .neutral)
                }
                
                HStack(spacing: DSSpacing.s) {
                    DSInlineBadge(ticker.marketCapTier.displayName, style: .accent)
                    DSInlineBadge(ticker.businessModel.displayName, style: .accent)
                }
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusXLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusXLarge, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("About")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            
            Text(ticker.blurb)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
                .lineSpacing(4)
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Why This Matters Section
    
    private var whyThisMattersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showWhyThisMatters.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DSColors.accent)
                    
                    Text("Why this matters")
                        .font(DSTypography.subheadline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DSColors.textSecondary)
                        .rotationEffect(.degrees(showWhyThisMatters ? 180 : 0))
                }
                .padding(DSSpacing.m)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if showWhyThisMatters {
                VStack(alignment: .leading, spacing: DSSpacing.s) {
                    Divider()
                        .background(DSColors.border)
                    
                    Text("Your assumptions will be pre-filled based on \(ticker.sector) sector trends and the \(ticker.businessModel.displayName) business model.")
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                        .lineSpacing(4)
                    
                    Text("This helps you start with realistic baseline assumptions that you can adjust to reflect your unique investment thesis.")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textTertiary)
                        .lineSpacing(4)
                        .padding(.top, DSSpacing.xs)
                }
                .padding([.horizontal, .bottom], DSSpacing.m)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        DSBottomBar {
            DSBottomBarPrimaryButton("Set Investment Lens", icon: "arrow.right") {
                onContinue()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        CompanyContextView(
            ticker: DCFTicker(
                symbol: "AAPL",
                name: "Apple Inc.",
                sector: "Technology",
                industry: "Consumer Electronics",
                marketCapTier: .large,
                businessModel: .platform,
                blurb: "Designs and manufactures consumer electronics, software, and services. Known for iPhone, Mac, and services ecosystem.",
                currentPrice: 185.50
            ),
            onContinue: {}
        )
    }
}
