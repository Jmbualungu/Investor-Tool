//
//  ButtonStyles.swift
//  Investor Tool
//
//  Premium button styles for consistent CTA appearance
//

import SwiftUI

// MARK: - Primary CTA Button Style

struct PrimaryCTAButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.body)
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeightStandard)
            .background(
                isEnabled
                    ? DSColors.accent
                    : DSColors.accent.opacity(0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .shadow(
                color: isEnabled && !configuration.isPressed
                    ? DSColors.accent.opacity(0.3)
                    : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Secondary CTA Button Style

struct SecondaryCTAButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.body)
            .fontWeight(.semibold)
            .foregroundColor(
                isEnabled
                    ? DSColors.textPrimary
                    : DSColors.textTertiary
            )
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeightStandard)
            .background(
                isEnabled
                    ? DSColors.surface
                    : DSColors.surface.opacity(0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                    .stroke(
                        isEnabled
                            ? DSColors.border
                            : DSColors.border.opacity(0.5),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Tertiary (Ghost) Button Style

struct TertiaryCTAButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DSTypography.body)
            .fontWeight(.medium)
            .foregroundColor(
                isEnabled
                    ? DSColors.accent
                    : DSColors.accent.opacity(0.5)
            )
            .padding(.horizontal, DSSpacing.m)
            .frame(height: DSSpacing.buttonHeightCompact)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func primaryCTAStyle() -> some View {
        self.buttonStyle(PrimaryCTAButtonStyle())
    }
    
    func secondaryCTAStyle() -> some View {
        self.buttonStyle(SecondaryCTAButtonStyle())
    }
    
    func tertiaryCTAStyle() -> some View {
        self.buttonStyle(TertiaryCTAButtonStyle())
    }
}
