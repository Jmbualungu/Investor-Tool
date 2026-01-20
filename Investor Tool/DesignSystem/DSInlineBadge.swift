//
//  DSInlineBadge.swift
//  Investor Tool
//
//  Small pill badges for compact inline information
//

import SwiftUI

struct DSInlineBadge: View {
    let text: String
    let style: Style
    
    enum Style {
        case accent
        case neutral
        case positive
        case negative
        case warning
        
        var backgroundColor: Color {
            switch self {
            case .accent:
                return DSColors.accent.opacity(0.15)
            case .neutral:
                return DSColors.surface2
            case .positive:
                return DSColors.positive.opacity(0.15)
            case .negative:
                return DSColors.negative.opacity(0.15)
            case .warning:
                return Color.orange.opacity(0.15)
            }
        }
        
        var textColor: Color {
            switch self {
            case .accent:
                return DSColors.accent
            case .neutral:
                return DSColors.textSecondary
            case .positive:
                return DSColors.positive
            case .negative:
                return DSColors.negative
            case .warning:
                return Color.orange
            }
        }
    }
    
    init(_ text: String, style: Style = .neutral) {
        self.text = text
        self.style = style
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(style.textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

// MARK: - Convenience Initializers

extension DSInlineBadge {
    static func horizon(_ text: String) -> DSInlineBadge {
        DSInlineBadge(text, style: .accent)
    }
    
    static func scenario(_ text: String) -> DSInlineBadge {
        DSInlineBadge(text, style: .neutral)
    }
    
    static func edited() -> DSInlineBadge {
        DSInlineBadge("Edited", style: .warning)
    }
    
    static func comingSoon() -> DSInlineBadge {
        DSInlineBadge("Coming soon", style: .neutral)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DSSpacing.m) {
        HStack(spacing: DSSpacing.s) {
            DSInlineBadge("5Y", style: .accent)
            DSInlineBadge("Base", style: .neutral)
            DSInlineBadge.edited()
            DSInlineBadge.comingSoon()
        }
        
        HStack(spacing: DSSpacing.s) {
            DSInlineBadge("+24.5%", style: .positive)
            DSInlineBadge("-12.3%", style: .negative)
            DSInlineBadge("Warning", style: .warning)
        }
    }
    .padding()
    .background(DSColors.background)
}
