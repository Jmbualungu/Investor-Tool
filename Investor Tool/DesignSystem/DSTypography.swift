import SwiftUI

enum DSTypography {
    static let title = Font.title2.weight(.bold)
    static let title3 = Font.title3.weight(.semibold)
    static let headline = Font.headline.weight(.semibold)
    static let body = Font.body
    static let subheadline = Font.subheadline
    static let caption = Font.caption
    static let button = Font.headline
}

// View modifier extensions for easy application
extension View {
    func dsTitle() -> some View {
        self
            .font(DSTypography.title)
            .foregroundColor(DSColors.textPrimary)
    }
    
    func dsHeadline() -> some View {
        self
            .font(DSTypography.headline)
            .foregroundColor(DSColors.textPrimary)
    }
    
    func dsBody() -> some View {
        self
            .font(DSTypography.body)
            .foregroundColor(DSColors.textPrimary)
    }
    
    func dsCaption() -> some View {
        self
            .font(DSTypography.caption)
            .foregroundColor(DSColors.textSecondary)
    }
    
    func dsSubheadline() -> some View {
        self
            .font(DSTypography.subheadline)
            .foregroundColor(DSColors.textSecondary)
    }
}
