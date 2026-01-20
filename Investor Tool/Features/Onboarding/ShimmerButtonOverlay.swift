//
//  ShimmerButtonOverlay.swift
//  Investor Tool
//
//  Subtle shine highlight for premium CTAs
//

import SwiftUI

struct ShimmerButtonOverlay: ViewModifier {
    let enabled: Bool
    
    @State private var phase: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if enabled && !Motion.isReduceMotionEnabled {
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.12),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.3)
                        .rotationEffect(.degrees(20))
                        .offset(x: phase * geometry.size.width)
                        .allowsHitTesting(false)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
                    .allowsHitTesting(false)
                    .onAppear {
                        // Initial delay, then one shimmer pass
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 1.2)) {
                                phase = 1.0
                            }
                        }
                    }
                }
            }
    }
}

extension View {
    func shimmerOverlay(enabled: Bool = true) -> some View {
        modifier(ShimmerButtonOverlay(enabled: enabled))
    }
}
