//
//  SummaryCardView.swift
//  Investor Tool
//
//  Shareable summary card preview for DCF analysis
//

import SwiftUI

struct SummaryCardView: View {
    let ticker: DCFTicker
    let horizon: DCFHorizon
    let outputs: DCFOutputs
    let confidenceLabel: String
    let topDrivers: [RevenueDriver]
    let operating: OperatingAssumptions
    let valuation: ValuationAssumptions
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Card content
                cardContent
                    .padding(DSSpacing.xl)
                    .background(DSColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                            .stroke(DSColors.border, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    .padding(DSSpacing.l)
                
                // Footer note
                Text("This summary can be saved or shared in a future update.")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.bottom, DSSpacing.l)
            }
        }
        .background(DSColors.background)
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            // Header
            header
            
            Divider()
                .background(DSColors.border)
            
            // Key Metrics
            keyMetrics
            
            Divider()
                .background(DSColors.border)
            
            // Confidence
            confidenceSection
            
            Divider()
                .background(DSColors.border)
            
            // Top Drivers
            topDriversSection
            
            Divider()
                .background(DSColors.border)
            
            // Key Assumptions
            keyAssumptionsSection
            
            // Timestamp
            Spacer(minLength: DSSpacing.m)
            
            Text("Generated \(Date(), formatter: summaryDateFormatter)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DSColors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack {
                Text(ticker.symbol)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
                
                Spacer()
                
                Text(horizon.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DSColors.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DSColors.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            
            Text(ticker.name)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
        }
    }
    
    private var keyMetrics: some View {
        VStack(spacing: DSSpacing.m) {
            Text("Valuation Summary")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Intrinsic Value
            metricRow(
                label: "Intrinsic Value",
                value: String(format: "$%.2f", outputs.intrinsicValue),
                isHighlighted: true
            )
            
            // Current Price
            metricRow(
                label: "Current Price",
                value: String(format: "$%.2f", ticker.currentPrice ?? 0),
                isHighlighted: false
            )
            
            // Upside
            HStack {
                Text("Upside")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                
                Spacer()
                
                Text(String(format: "%+.1f%%", outputs.upsidePercent))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(outputs.upsidePercent >= 0 ? .green : .red)
            }
            
            // CAGR
            metricRow(
                label: "Implied CAGR",
                value: String(format: "%+.1f%%", outputs.cagrPercent),
                isHighlighted: false
            )
        }
    }
    
    private var confidenceSection: some View {
        VStack(spacing: DSSpacing.s) {
            Text("Confidence Profile")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Aggressiveness")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                
                Spacer()
                
                Text(confidenceLabel)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DSColors.accent)
            }
        }
    }
    
    private var topDriversSection: some View {
        VStack(spacing: DSSpacing.s) {
            Text("Top 3 Drivers")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(topDrivers.prefix(3)) { driver in
                HStack {
                    Text(driver.title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Spacer()
                    
                    Text(driver.unit.format(driver.value))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DSColors.textPrimary)
                }
            }
        }
    }
    
    private var keyAssumptionsSection: some View {
        VStack(spacing: DSSpacing.s) {
            Text("Key Assumptions")
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            assumptionRow(
                label: "Operating Margin",
                value: String(format: "%.1f%%", operating.operatingMargin)
            )
            
            assumptionRow(
                label: "Discount Rate",
                value: String(format: "%.1f%%", valuation.discountRate)
            )
            
            assumptionRow(
                label: "Terminal Growth",
                value: String(format: "%.1f%%", valuation.terminalGrowth)
            )
        }
    }
    
    private func metricRow(label: String, value: String, isHighlighted: Bool) -> some View {
        HStack {
            Text(label)
                .font(isHighlighted ? DSTypography.headline : DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: isHighlighted ? 24 : 18, weight: isHighlighted ? .bold : .semibold))
                .foregroundColor(isHighlighted ? DSColors.accent : DSColors.textPrimary)
        }
    }
    
    private func assumptionRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(DSColors.textPrimary)
        }
    }
    
    private var summaryDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    let mockTicker = DCFTicker(
        symbol: "AAPL",
        name: "Apple Inc.",
        sector: "Technology",
        industry: "Consumer Electronics",
        marketCapTier: .large,
        businessModel: .platform,
        blurb: "Test",
        currentPrice: 185.50
    )
    
    let mockOutputs = DCFOutputs(
        revenueIndex: 142.5,
        fcfMargin: 0.18,
        fcfIndex: 25.65,
        intrinsicValue: 242.80,
        upsidePercent: 30.8,
        cagrPercent: 5.5,
        terminalSharePercent: 65.0
    )
    
    let mockDrivers = [
        RevenueDriver(
            title: "Revenue Growth",
            subtitle: "Year-over-year growth rate",
            unit: .percent,
            value: 8.5,
            min: 0,
            max: 20,
            step: 0.5
        ),
        RevenueDriver(
            title: "Market Share",
            subtitle: "Total addressable market penetration",
            unit: .percent,
            value: 15.2,
            min: 5,
            max: 30,
            step: 0.1
        ),
        RevenueDriver(
            title: "Price Multiple",
            subtitle: "Average selling price multiplier",
            unit: .multiple,
            value: 1.12,
            min: 0.8,
            max: 1.5,
            step: 0.01
        )
    ]
    
    return NavigationStack {
        SummaryCardView(
            ticker: mockTicker,
            horizon: .fiveYear,
            outputs: mockOutputs,
            confidenceLabel: "Balanced",
            topDrivers: mockDrivers,
            operating: OperatingAssumptions(),
            valuation: ValuationAssumptions()
        )
        .navigationTitle("Summary Card")
        .navigationBarTitleDisplayMode(.inline)
    }
}
