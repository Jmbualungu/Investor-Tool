import SwiftUI

enum DSColors {
    // MARK: - Valtyde Brand System v1.1 (fixed dark navy theme)

    /// Primary background — deep navy
    static let background = Color(hex: "0A0F1F")

    /// Elevated surface — cards, sheets
    static let surface = Color(hex: "0E162B")

    /// Secondary surface — nested cards, inputs, raised/hover
    static let surface2 = Color(hex: "121C35")

    // MARK: - Dividers & Borders

    /// Standard border and divider color
    static let border = Color(hex: "22345F")

    /// Subtle divider (lighter opacity)
    static let divider = Color(hex: "22345F").opacity(0.6)

    // MARK: - Text Colors

    /// Primary text — off-white
    static let textPrimary = Color(hex: "F6F8FC")

    /// Secondary text — muted
    static let textSecondary = Color(hex: "AAB6D3")

    /// Tertiary text — subtle labels/metadata
    static let textTertiary = Color(hex: "6F7EA3")

    // MARK: - Accent & Brand (intelligence = blue/cyan)

    /// Primary accent — electric blue
    static let accent = Color(hex: "125BFF")

    /// Data/highlight glow — bright cyan
    static let cyan = Color(hex: "00EDFF")

    /// Soft sky glow — secondary accent
    static let sky = Color(hex: "7FD8FF")

    /// Accent glow for shadows (cyan)
    static let accentGlow = Color(hex: "00EDFF").opacity(0.28)

    // MARK: - Semantic Colors (financial meaning only)

    /// Positive / undervalued / margin-of-safety
    static let positive = Color(hex: "22C55E")

    /// Negative / overvalued / downside
    static let negative = Color(hex: "FB7185")

    /// Success (alias for positive)
    static let success = positive

    /// Danger (alias for negative)
    static let danger = negative

    /// Warning — caution / fragile assumptions
    static let warning = Color(hex: "FBBF24")
    
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
