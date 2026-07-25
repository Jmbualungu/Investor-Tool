import SwiftUI

// MARK: - Glow Modifier
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: 0, y: 0)
    }
}

extension View {
    func dsGlow(color: Color = DSColors.accentGlow, radius: CGFloat = 8) -> some View {
        self.modifier(GlowModifier(color: color, radius: radius))
    }
}

// MARK: - Card Padding Modifier
struct CardPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(DSSpacing.l)
    }
}

extension View {
    func dsCardPadding() -> some View {
        self.modifier(CardPaddingModifier())
    }
}

// MARK: - Glass Background Modifier
struct GlassBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    }
}

extension View {
    func dsGlassBackground() -> some View {
        self.modifier(GlassBackgroundModifier())
    }
}
