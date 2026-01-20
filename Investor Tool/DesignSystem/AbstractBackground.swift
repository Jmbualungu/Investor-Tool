//
//  AbstractBackground.swift
//  Investor Tool
//
//  Subtle abstract background for visual depth without images
//

import SwiftUI

struct AbstractBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Base color
            DSColors.background
            
            // Subtle abstract shapes
            GeometryReader { geometry in
                // Top-leading blob
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DSColors.accent.opacity(colorScheme == .dark ? 0.05 : 0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 250
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: -150, y: -100)
                
                // Bottom-trailing blob
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.gray.opacity(colorScheme == .dark ? 0.03 : 0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(
                        x: geometry.size.width - 100,
                        y: geometry.size.height - 150
                    )
                
                // Middle accent
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DSColors.accent.opacity(colorScheme == .dark ? 0.04 : 0.06),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 250, height: 250)
                    .offset(
                        x: geometry.size.width * 0.6,
                        y: geometry.size.height * 0.3
                    )
            }
        }
    }
}

#Preview("Light Mode") {
    AbstractBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    AbstractBackground()
        .preferredColorScheme(.dark)
}
