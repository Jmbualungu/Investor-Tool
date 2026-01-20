//
//  OnboardingProgressDots.swift
//  Investor Tool
//
//  Premium Robinhood-style animated progress dots
//

import SwiftUI

struct OnboardingProgressDots: View {
    let currentIndex: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.primary : Color.primary.opacity(0.25))
                    .frame(
                        width: index == currentIndex ? 24 : 8,
                        height: 8
                    )
                    .animation(
                        Motion.isReduceMotionEnabled ? nil : .easeInOut(duration: 0.25),
                        value: currentIndex
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: DSSpacing.xl) {
        ForEach(0..<3) { index in
            VStack(spacing: DSSpacing.m) {
                Text("Page \(index + 1)")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                
                OnboardingProgressDots(currentIndex: index, total: 3)
            }
        }
    }
    .padding()
    .background(DSColors.background)
}
