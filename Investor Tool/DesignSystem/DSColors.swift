import SwiftUI

enum DSColors {
    // Dark theme background colors
    static let background = Color(red: 0.05, green: 0.06, blue: 0.08)
    static let surface = Color(red: 0.11, green: 0.12, blue: 0.15)
    static let surface2 = Color(red: 0.15, green: 0.16, blue: 0.19)
    
    // Glass effect colors
    static let glassOverlay = Color.white.opacity(0.08)
    static let border = Color.white.opacity(0.12)
    
    // Text colors
    static let textPrimary = Color(white: 0.95)
    static let textSecondary = Color(white: 0.6)
    static let textTertiary = Color(white: 0.45)
    
    // Accent colors
    static let accent = Color(red: 0.98, green: 0.54, blue: 0.14)
    static let accentGlow = Color(red: 0.98, green: 0.54, blue: 0.14).opacity(0.28)
    static let accentPurple = Color(red: 0.56, green: 0.38, blue: 0.98)
    static let accentPurpleGlow = Color(red: 0.56, green: 0.38, blue: 0.98).opacity(0.28)
    static let positive = Color(red: 0.20, green: 0.80, blue: 0.45)
    static let negative = Color(red: 0.96, green: 0.30, blue: 0.35)
    
    // Semantic colors
    static let success = positive
    static let danger = negative
    
    // Legacy support (deprecated but kept for compatibility)
    static let primary = accent
    static let secondaryText = textSecondary
    static let separator = border
    static let cardBackground = surface
    static let fieldBackground = surface2
    static let surfaceSecondary = surface2
}
