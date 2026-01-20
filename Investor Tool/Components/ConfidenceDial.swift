//
//  ConfidenceDial.swift
//  Investor Tool
//
//  Premium confidence/aggressiveness score visualization
//

import SwiftUI

struct ConfidenceDial: View {
    let score: Double // 0-100
    let label: String
    let targetStyle: DCFInvestmentStyle
    let targetScore: Double
    let isAligned: Bool
    
    private var progress: Double {
        score / 100.0
    }
    
    private var dialColor: Color {
        if score <= 33 {
            return .blue
        } else if score <= 66 {
            return DSColors.accent
        } else {
            return .orange
        }
    }
    
    var body: some View {
        VStack(spacing: DSSpacing.m) {
            // Circular gauge
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        DSColors.surface2,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                dialColor.opacity(0.6),
                                dialColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
                
                // Center content
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", score))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                }
            }
            
            // Microcopy
            Text("Based on current assumptions")
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textTertiary)
            
            // Lens target info
            VStack(spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.xs) {
                    Text("Lens target:")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                    
                    Text(targetStyle.displayName)
                        .font(DSTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(DSColors.accent)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: isAligned ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isAligned ? .green : .orange)
                    
                    Text(isAligned ? "Aligned" : "High drift")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isAligned ? .green : .orange)
                }
            }
            .padding(DSSpacing.s)
            .background(DSColors.surface2)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
}

// MARK: - Mini Version

struct ConfidenceDialMini: View {
    let score: Double // 0-100
    let label: String
    
    private var progress: Double {
        score / 100.0
    }
    
    private var dialColor: Color {
        if score <= 33 {
            return .blue
        } else if score <= 66 {
            return DSColors.accent
        } else {
            return .orange
        }
    }
    
    var body: some View {
        HStack(spacing: DSSpacing.m) {
            // Mini circular gauge
            ZStack {
                Circle()
                    .stroke(
                        DSColors.surface2,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        dialColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.0f", score))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DSColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Confidence")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
            }
            
            Spacer()
        }
        .padding(DSSpacing.m)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    }
}

#Preview("Full Dial") {
    VStack(spacing: 20) {
        ConfidenceDial(
            score: 45,
            label: "Balanced",
            targetStyle: .base,
            targetScore: 50,
            isAligned: true
        )
        
        ConfidenceDial(
            score: 78,
            label: "Aggressive",
            targetStyle: .conservative,
            targetScore: 25,
            isAligned: false
        )
    }
    .padding()
    .background(DSColors.background)
}

#Preview("Mini Dial") {
    VStack(spacing: 12) {
        ConfidenceDialMini(score: 45, label: "Balanced")
        ConfidenceDialMini(score: 28, label: "Conservative")
        ConfidenceDialMini(score: 72, label: "Aggressive")
    }
    .padding()
    .background(DSColors.background)
}
