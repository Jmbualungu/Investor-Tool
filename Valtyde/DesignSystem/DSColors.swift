import SwiftUI

enum DSColors {
    // MARK: - Valtyde Brand System v1.1 (fixed dark navy theme)

    /// Primary background — deep navy
    static let background = Color(hex: "0A0F1F")

    /// Elevated surface — cards, sheets
    static let surface = Color(hex: "0E1426")

    /// Secondary surface — nested cards, inputs, raised/hover
    static let surface2 = Color(hex: "131C33")

    /// Tertiary surface — deepest raised layer
    static let surface3 = Color(hex: "1A2440")

    // MARK: - Dividers & Borders

    /// Standard border and divider color
    static let border = Color(hex: "1E2740")

    /// Subtle divider (softer line)
    static let divider = Color(hex: "161E33")

    // MARK: - Text Colors

    /// Primary text — off-white
    static let textPrimary = Color(hex: "F6F8FC")

    /// Secondary text — muted ("dim")
    static let textSecondary = Color(hex: "8A97B5")

    /// Tertiary text — subtle labels/metadata ("faint")
    static let textTertiary = Color(hex: "5A6685")

    // MARK: - Accent & Brand (intelligence = blue/cyan)

    /// Primary accent — electric blue
    static let accent = Color(hex: "125BFF")

    /// Data/highlight glow — bright cyan
    static let cyan = Color(hex: "00E0FF")

    /// Soft sky glow — secondary accent
    static let sky = Color(hex: "7FD8FF")

    /// Accent glow for shadows (cyan)
    static let accentGlow = Color(hex: "00E0FF").opacity(0.30)

    // MARK: - Semantic Colors (value verdict only — green=under, red=over)

    /// Positive / undervalued / margin-of-safety
    static let positive = Color(hex: "2FE0A0")

    /// Negative / overvalued / downside
    static let negative = Color(hex: "FF5E6C")

    /// Success (alias for positive)
    static let success = positive

    /// Danger (alias for negative)
    static let danger = negative

    /// Warning — caution / fragile assumptions
    static let warning = Color(hex: "E8B04A")
    
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
