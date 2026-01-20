//
//  PriceHeaderView.swift
//  Investor Tool
//
//  Robinhood-style mini price header with sparkline and range selector
//

import SwiftUI

struct PriceHeaderView: View {
    let symbol: String
    let companyName: String?
    @Binding var selectedRange: PriceRange
    
    @State private var priceSeries: [Double] = []
    
    private var currentPrice: Double {
        MarketMock.mockCurrentPrice(symbol: symbol)
    }
    
    private var dayChange: (absolute: Double, percent: Double) {
        MarketMock.mockDayChange(symbol: symbol)
    }
    
    private var isPositive: Bool {
        dayChange.absolute >= 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            // Company name (optional)
            if let name = companyName {
                Text(name)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }
            
            // Current price + day change
            HStack(alignment: .firstTextBaseline, spacing: DSSpacing.m) {
                Text(Formatters.formatCurrency(currentPrice))
                    .font(DSTypography.displayNumberMedium)
                    .foregroundColor(DSColors.textPrimary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(String(format: "%+.2f", dayChange.absolute))
                            .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundColor(isPositive ? DSColors.positive : DSColors.negative)
                        
                        Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(isPositive ? DSColors.positive : DSColors.negative)
                    }
                    
                    Text(String(format: "%+.2f%%", dayChange.percent))
                        .font(.system(size: 14, weight: .medium, design: .rounded).monospacedDigit())
                        .foregroundColor(isPositive ? DSColors.positive : DSColors.negative)
                }
            }
            
            // Sparkline
            if !priceSeries.isEmpty {
                Sparkline(
                    points: priceSeries,
                    height: 80,
                    lineColor: isPositive ? DSColors.positive : DSColors.negative
                )
                .padding(.vertical, DSSpacing.s)
            }
            
            // Range selector
            rangeSelectorPills
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
        .onAppear {
            updatePriceSeries()
        }
        .onChange(of: selectedRange) { _, _ in
            updatePriceSeries()
        }
    }
    
    // MARK: - Range Selector
    
    private var rangeSelectorPills: some View {
        HStack(spacing: DSSpacing.s) {
            ForEach(PriceRange.allCases) { range in
                rangeButton(range)
            }
        }
    }
    
    private func rangeButton(_ range: PriceRange) -> some View {
        Button {
            HapticManager.shared.selectionChanged()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedRange = range
            }
        } label: {
            Text(range.rawValue)
                .font(.system(size: 13, weight: selectedRange == range ? .semibold : .medium))
                .foregroundColor(selectedRange == range ? DSColors.textPrimary : DSColors.textSecondary)
                .frame(minWidth: 44)
                .frame(height: 32)
                .background(selectedRange == range ? DSColors.accent.opacity(0.15) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    
    private func updatePriceSeries() {
        priceSeries = MarketMock.mockPriceSeries(symbol: symbol, range: selectedRange)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedRange: PriceRange = .oneDay
    
    return VStack(spacing: DSSpacing.l) {
        PriceHeaderView(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            selectedRange: $selectedRange
        )
        
        PriceHeaderView(
            symbol: "TSLA",
            companyName: "Tesla, Inc.",
            selectedRange: $selectedRange
        )
    }
    .padding()
    .background(DSColors.background)
}
