import SwiftUI

enum DSColors {
    // MARK: - Background Colors (Semantic, adapts to light/dark mode)
    
    /// Primary background - deep, calm dark in dark mode
    static let background = Color(.systemBackground)
    
    /// Elevated surface - cards, sheets
    static let surface = Color(.secondarySystemBackground)
    
    /// Secondary surface - nested cards, inputs
    static let surface2 = Color(.tertiarySystemBackground)
    
    // MARK: - Dividers & Borders
    
    /// Standard border and divider color
    static let border = Color(.separator)
    
    /// Subtle divider (lighter opacity)
    static let divider = Color(.separator).opacity(0.6)
    
    // MARK: - Text Colors (Semantic)
    
    /// Primary text color
    static let textPrimary = Color(.label)
    
    /// Secondary text color
    static let textSecondary = Color(.secondaryLabel)
    
    /// Tertiary text color (hints, placeholders)
    static let textTertiary = Color(.tertiaryLabel)
    
    // MARK: - Accent & Brand
    
    /// Primary accent color - uses app accent from Assets
    static let accent = Color.accentColor
    
    /// Accent glow for shadows
    static let accentGlow = Color.accentColor.opacity(0.3)
    
    // MARK: - Semantic Colors
    
    /// Positive/success color (green)
    static let positive = Color.green
    
    /// Negative/error color (red)
    static let negative = Color.red
    
    /// Success (alias for positive)
    static let success = positive
    
    /// Danger (alias for negative)
    static let danger = negative
    
    /// Warning color
    static let warning = Color.orange
    
    // MARK: - Legacy Support (deprecated but kept for compatibility)
    
    @available(*, deprecated, renamed: "accent")
    static let primary = accent
    
    @available(*, deprecated, renamed: "textSecondary")
    static let secondaryText = textSecondary
    
    @available(*, deprecated, renamed: "border")
    static let separator = border
    
    @available(*, deprecated, renamed: "surface")
    static let cardBackground = surface
    
    @available(*, deprecated, renamed: "surface2")
    static let fieldBackground = surface2
    
    @available(*, deprecated, renamed: "surface2")
    static let surfaceSecondary = surface2
    
    @available(*, deprecated, message: "Use .ultraThinMaterial instead")
    static let glassOverlay = Color.white.opacity(0.08)
    
    @available(*, deprecated, message: "Use Color.accentColor for purple accent")
    static let accentPurple = Color(red: 0.56, green: 0.38, blue: 0.98)
    
    @available(*, deprecated, message: "Use accentGlow instead")
    static let accentPurpleGlow = Color(red: 0.56, green: 0.38, blue: 0.98).opacity(0.28)
}
