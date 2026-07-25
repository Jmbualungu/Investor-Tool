import SwiftUI

// MARK: - Legacy DesignTokens (for backward compatibility)

enum DesignTokens {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }

    enum Fonts {
        static let title = Font.title2.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let caption = Font.caption
    }

    enum Colors {
        static let primary = Color.accentColor
        static let background = Color(.systemBackground)
        static let card = Color(.secondarySystemBackground)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
    }
}

// MARK: - Unified Design System (DS)

/// Unified Design System namespace for consistent spacing, typography, and layout
enum DS {
    /// Spacing scale (HIG-like)
    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 18
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    /// Corner radius scale
    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 22
    }
    
    /// Typography system with semantic sizes
    enum Typography {
        /// Large title (28pt, semibold, rounded)
        static func title(_ weight: Font.Weight = .semibold) -> Font {
            .system(size: 28, weight: weight, design: .rounded)
        }
        
        /// Headline (18pt, semibold, rounded)
        static func headline(_ weight: Font.Weight = .semibold) -> Font {
            .system(size: 18, weight: weight, design: .rounded)
        }
        
        /// Body text (16pt, regular, rounded)
        static func body(_ weight: Font.Weight = .regular) -> Font {
            .system(size: 16, weight: weight, design: .rounded)
        }
        
        /// Caption (12pt, regular, rounded)
        static func caption(_ weight: Font.Weight = .regular) -> Font {
            .system(size: 12, weight: weight, design: .rounded)
        }
        
        /// Monospaced numbers for financial data
        static func monoNumber(_ size: CGFloat = 22, _ weight: Font.Weight = .semibold) -> Font {
            .system(size: size, weight: weight, design: .monospaced)
        }
    }
}
