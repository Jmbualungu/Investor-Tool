//
//  LaunchScreenView.swift
//  Investor Tool
//
//  SwiftUI-based launch screen for preview and documentation
//  Note: Actual launch screen uses LaunchScreen.storyboard
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    DSColors.background,
                    DSColors.surface.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: DS.Spacing.xl) {
                // App icon glyph
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DSColors.accent.opacity(0.3),
                                    DSColors.accent.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(DSColors.accent)
                }
                
                VStack(spacing: DS.Spacing.sm) {
                    Text("Augur")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text(Copy.dataDrivenForecasting)
                        .font(DS.Typography.body(.medium))
                        .foregroundColor(DSColors.textSecondary)
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
