import SwiftUI

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case goals
    case risk
    case benefits
    case teaser
    case paywall
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .goals:
            return "Your Goals"
        case .risk:
            return "Risk Comfort"
        case .benefits:
            return "What's New"
        case .teaser:
            return "Your Plan"
        case .paywall:
            return "Unlock"
        }
    }
}

struct OnboardingGoal: Identifiable, Hashable {
    let id: String
    let title: String
    let icon: String
}

enum RiskProfile: String, CaseIterable, Identifiable {
    case conservative
    case balanced
    case growth
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .conservative:
            return "Low volatility"
        case .balanced:
            return "Balanced"
        case .growth:
            return "Growth-focused"
        }
    }
    
    var description: String {
        switch self {
        case .conservative:
            return "Steadier returns with smaller swings."
        case .balanced:
            return "A mix of stability and growth."
        case .growth:
            return "Higher upside with more volatility."
        }
    }
    
    var icon: String {
        switch self {
        case .conservative:
            return "shield.lefthalf.filled"
        case .balanced:
            return "scale.3d"
        case .growth:
            return "arrow.up.right.circle"
        }
    }
}

struct OnboardingBenefit: Identifiable, Hashable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
}

struct PricingOption: Identifiable, Hashable {
    let id: String
    let title: String
    let price: String
    let subtitle: String
    let isBestValue: Bool
}
