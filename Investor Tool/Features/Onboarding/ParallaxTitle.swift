//
//  ParallaxTitle.swift
//  Investor Tool
//
//  Subtle parallax effect for onboarding titles
//

import SwiftUI

struct ParallaxTitle: View {
    let title: String
    let subtitle: String?
    let pageIndex: Int
    
    @State private var animateIn = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(DSColors.textPrimary)
                .offset(x: titleOffset)
                .opacity(titleOpacity)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                    .lineSpacing(4)
                    .offset(x: subtitleOffset)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            triggerAnimation()
        }
        .onChange(of: pageIndex) { _ in
            // Replay animation on page change
            animateIn = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                triggerAnimation()
            }
        }
    }
    
    private var titleOffset: CGFloat {
        guard !Motion.isReduceMotionEnabled else { return 0 }
        return animateIn ? 0 : (pageIndex % 2 == 0 ? -4 : 4)
    }
    
    private var subtitleOffset: CGFloat {
        guard !Motion.isReduceMotionEnabled else { return 0 }
        return animateIn ? 0 : (pageIndex % 2 == 0 ? -2 : 2)
    }
    
    private var titleOpacity: Double {
        guard !Motion.isReduceMotionEnabled else { return 1.0 }
        return animateIn ? 1.0 : 0.92
    }
    
    private var subtitleOpacity: Double {
        guard !Motion.isReduceMotionEnabled else { return 1.0 }
        return animateIn ? 1.0 : 0.88
    }
    
    private func triggerAnimation() {
        if Motion.isReduceMotionEnabled {
            animateIn = true
        } else {
            withAnimation(.easeOut(duration: 0.35)) {
                animateIn = true
            }
        }
    }
}
