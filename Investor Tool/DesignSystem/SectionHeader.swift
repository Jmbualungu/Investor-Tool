//
//  SectionHeader.swift
//  Investor Tool
//
//  Reusable section header component for consistent styling
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let icon: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.s) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DSColors.accent)
                }
                
                Text(title)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Divider Section Header (with divider above)

struct DividerSectionHeader: View {
    let title: String
    let subtitle: String?
    
    init(
        title: String,
        subtitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Divider()
                .background(DSColors.border)
            
            SectionHeader(title: title, subtitle: subtitle)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.l) {
        SectionHeader(
            title: "Revenue Drivers",
            subtitle: "Adjust the key assumptions that drive your forecast",
            icon: "chart.line.uptrend.xyaxis"
        )
        
        DividerSectionHeader(
            title: "Operating Assumptions",
            subtitle: "Configure profitability and reinvestment rates"
        )
    }
    .padding()
    .background(DSColors.background)
}
