//
//  Motion.swift
//  Investor Tool
//
//  Standard motion and animation constants for consistent UI feel
//

import SwiftUI

enum Motion {
    // MARK: - Duration Constants
    
    /// Fast transitions (150ms) - use for immediate feedback
    static let fast: Double = 0.15
    
    /// Standard transitions (250ms) - default for most UI
    static let standard: Double = 0.25
    
    /// Slow transitions (400ms) - use for emphasis
    static let slow: Double = 0.4
    
    // MARK: - Animation Presets
    
    /// Standard appearance animation
    static let appear = Animation.easeOut(duration: standard)
    
    /// Smooth disappearance
    static let disappear = Animation.easeIn(duration: fast)
    
    /// Emphasis animation with spring
    static let emphasize = Animation.spring(response: 0.35, dampingFraction: 0.85)
    
    /// Screen transition
    static let screenTransition = Animation.easeOut(duration: standard)
    
    /// Value change (sliders, toggles)
    static let valueChange = Animation.easeInOut(duration: fast)
    
    /// Header/chrome changes
    static let chrome = Animation.easeOut(duration: slow)
    
    // MARK: - Helper Functions
    
    /// Check if reduce motion is enabled
    static var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
    
    /// Execute animation only if reduce motion is disabled
    static func withAnimation<Result>(
        _ animation: Animation?,
        _ body: () throws -> Result
    ) rethrows -> Result {
        if isReduceMotionEnabled {
            return try body()
        } else {
            return try SwiftUI.withAnimation(animation, body)
        }
    }
}
