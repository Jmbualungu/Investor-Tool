import SwiftUI

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case goals
    case risk
    case benefits
    case teaser

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
            return "Conservative"
        case .balanced:
            return "Balanced"
        case .growth:
            return "Aggressive"
        }
    }

    var description: String {
        switch self {
        case .conservative:
            return "Cautious growth and a higher discount rate."
        case .balanced:
            return "Reasonable base-case assumptions."
        case .growth:
            return "Optimistic growth and a lower discount rate."
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
