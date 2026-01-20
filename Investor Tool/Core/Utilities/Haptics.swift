//
//  Haptics.swift
//  Investor Tool
//
//  Haptic feedback helper for premium tactile interactions
//

import UIKit

@MainActor
final class HapticManager {
    static let shared = HapticManager()
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators on init for reduced latency
        lightImpact.prepare()
        mediumImpact.prepare()
        selection.prepare()
    }
    
    /// Trigger a light impact (e.g., button taps, preset selections)
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        switch style {
        case .light:
            lightImpact.impactOccurred()
            lightImpact.prepare()
        case .medium:
            mediumImpact.impactOccurred()
            mediumImpact.prepare()
        case .heavy:
            heavyImpact.impactOccurred()
            heavyImpact.prepare()
        case .soft, .rigid:
            // Use light as fallback for soft/rigid
            lightImpact.impactOccurred()
            lightImpact.prepare()
        @unknown default:
            lightImpact.impactOccurred()
            lightImpact.prepare()
        }
    }
    
    /// Trigger a selection change feedback (e.g., segmented controls, toggles)
    func selectionChanged() {
        selection.selectionChanged()
        selection.prepare()
    }
    
    /// Trigger a notification feedback (success/error/warning)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notification.notificationOccurred(type)
        notification.prepare()
    }
    
    /// Trigger success feedback
    func success() {
        notification(type: .success)
    }
    
    /// Trigger error feedback
    func error() {
        notification(type: .error)
    }
    
    /// Trigger warning feedback
    func warning() {
        notification(type: .warning)
    }
}
