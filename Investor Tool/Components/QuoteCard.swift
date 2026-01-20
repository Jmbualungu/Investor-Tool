//
//  QuoteCard.swift
//  Investor Tool
//
//  Tasteful quote display for investor wisdom
//

import SwiftUI

struct QuoteCard: View {
    let quote: InvestorQuote
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack(alignment: .top, spacing: DSSpacing.s) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DSColors.accent.opacity(0.5))
                
                VStack(alignment: .leading, spacing: DSSpacing.s) {
                    Text(quote.text)
                        .font(DSTypography.body)
                        .fontWeight(.medium)
                        .foregroundColor(DSColors.textPrimary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("— \(quote.author)")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                }
            }
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    QuoteCard(quote: InvestorQuotes.onboarding[0])
        .padding()
        .background(DSColors.background)
}
