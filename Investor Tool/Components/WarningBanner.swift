//
//  WarningBanner.swift
//  Investor Tool
//
//  Premium feature: Inline validation warnings for guardrails
//

import SwiftUI

enum WarningSeverity {
    case info
    case warn
    
    var color: Color {
        switch self {
        case .info: return .blue
        case .warn: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warn: return "exclamationmark.triangle.fill"
        }
    }
}

struct WarningBanner: View {
    let title: String
    let message: String
    let severity: WarningSeverity
    let explanation: String?
    
    @State private var isExpanded = false
    
    init(
        title: String,
        message: String,
        severity: WarningSeverity = .warn,
        explanation: String? = nil
    ) {
        self.title = title
        self.message = message
        self.severity = severity
        self.explanation = explanation
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack(alignment: .top, spacing: DSSpacing.s) {
                Image(systemName: severity.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(severity.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DSTypography.subheadline)
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text(message)
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.textSecondary)
                        .lineSpacing(2)
                }
                
                Spacer()
            }
            
            if let explanation = explanation {
                DisclosureGroup(
                    isExpanded: $isExpanded,
                    content: {
                        Text(explanation)
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, DSSpacing.xs)
                    },
                    label: {
                        Text("Why does this matter?")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(severity.color)
                    }
                )
                .tint(severity.color)
            }
        }
        .padding(DSSpacing.m)
        .background(severity.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(severity.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        WarningBanner(
            title: "Terminal Growth Too High",
            message: "Terminal growth should be lower than the discount rate by at least 0.5%.",
            severity: .warn,
            explanation: "If terminal growth equals or exceeds the discount rate, the DCF formula breaks down mathematically, leading to infinite or negative valuations. This constraint ensures a stable, realistic perpetuity calculation."
        )
        
        WarningBanner(
            title: "Operating Margin Exceeds Gross Margin",
            message: "Operating margin has been adjusted to match gross margin.",
            severity: .warn,
            explanation: "Operating margin represents profit after all operating expenses, which by definition cannot exceed gross margin (profit after direct costs only)."
        )
        
        WarningBanner(
            title: "Negative Free Cash Flow",
            message: "Your reinvestment assumptions imply negative free cash flow.",
            severity: .info,
            explanation: "High capital expenditure and working capital requirements can temporarily result in negative FCF. This is common for high-growth companies, but consider whether this is sustainable long-term."
        )
    }
    .padding()
}
