//
//  ResultsPreviewCard.swift
//  Investor Tool
//
//  Mini results preview card for onboarding "What you'll build"
//

import SwiftUI

struct ResultsPreviewCard: View {
    let variant: Variant
    
    enum Variant {
        case simple    // Page 1: Just intrinsic value + upside + sparkline
        case full      // Page 3: Adds scenario strip + confidence
    }
    
    // Mock data for preview
    private let mockPriceData: [Double] = [152, 158, 163, 159, 165, 168]
    
    var body: some View {
        DSGlassCard {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                // Header with ticker and horizon
                HStack(spacing: DSSpacing.s) {
                    DSInlineBadge("AAPL", style: .accent)
                    DSInlineBadge("5Y", style: .neutral)
                    
                    Spacer()
                    
                    Text("What you'll build")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DSColors.textTertiary)
                }
                
                // Main metric: Intrinsic Value
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Intrinsic Value")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: DSSpacing.s) {
                        Text("$168")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        DSInlineBadge("+10.5%", style: .positive)
                    }
                }
                
                // Sparkline
                Sparkline(points: mockPriceData, height: 28, lineColor: DSColors.accent)
                    .padding(.vertical, DSSpacing.xs)
                
                // Scenario strip (full variant only)
                if variant == .full {
                    VStack(spacing: DSSpacing.s) {
                        // Scenario pills
                        HStack(spacing: DSSpacing.xs) {
                            scenarioPill("Bear", value: "$142", isActive: false)
                            scenarioPill("Base", value: "$168", isActive: true)
                            scenarioPill("Bull", value: "$195", isActive: false)
                        }
                        
                        // Confidence indicator
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "gauge.with.dots.needle.33percent")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(DSColors.textSecondary)
                            
                            Text("Confidence: Balanced")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(DSColors.textSecondary)
                        }
                    }
                }
            }
        }
        .opacity(0.95) // Subtle transparency to indicate it's a preview
    }
    
    private func scenarioPill(_ label: String, value: String, isActive: Bool) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isActive ? .white : DSColors.textSecondary)
            
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isActive ? .white : DSColors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(isActive ? DSColors.accent : DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isActive ? DSColors.accent : DSColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: DSSpacing.xl) {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Simple Variant (Page 1)")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            
            ResultsPreviewCard(variant: .simple)
        }
        
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Full Variant (Page 3)")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            
            ResultsPreviewCard(variant: .full)
        }
    }
    .padding()
    .background(DSColors.background)
}
