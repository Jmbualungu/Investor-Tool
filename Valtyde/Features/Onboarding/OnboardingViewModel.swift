import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep = .welcome
    @Published var selectedGoals: Set<String> = []
    @Published var selectedRisk: RiskProfile? = nil

    let goals: [OnboardingGoal] = [
        OnboardingGoal(id: "value", title: "Value a specific company", icon: "building.2"),
        OnboardingGoal(id: "model", title: "Build a DCF model", icon: "function"),
        OnboardingGoal(id: "sensitivity", title: "Run sensitivity analysis", icon: "slider.horizontal.3"),
        OnboardingGoal(id: "watchlist", title: "Track ideas on a watchlist", icon: "star"),
        OnboardingGoal(id: "learn", title: "Learn how valuation works", icon: "book")
    ]

    let benefits: [OnboardingBenefit] = [
        OnboardingBenefit(
            id: "engine",
            icon: "function",
            title: "Full DCF engine",
            subtitle: "Project free cash flows and discount them to today's value."
        ),
        OnboardingBenefit(
            id: "sensitivity",
            icon: "slider.horizontal.3",
            title: "Sensitivity analysis",
            subtitle: "See how your valuation shifts as assumptions change."
        ),
        OnboardingBenefit(
            id: "library",
            icon: "tray.full",
            title: "Save your models",
            subtitle: "Keep every forecast in your library to revisit later."
        )
    ]

    var progressLabel: String {
        "Step \(step.rawValue + 1) of \(OnboardingStep.allCases.count)"
    }
    
    var canContinue: Bool {
        switch step {
        case .welcome:
            return true
        case .goals:
            return !selectedGoals.isEmpty
        case .risk:
            return selectedRisk != nil
        case .benefits, .teaser:
            return true
        }
    }
    
    func toggleGoal(_ goal: OnboardingGoal) {
        var next = selectedGoals
        if next.contains(goal.id) {
            next.remove(goal.id)
        } else {
            next.insert(goal.id)
        }
        selectedGoals = next
        #if DEBUG
        print("📱 [Onboarding] Goal toggled — id: \(goal.id), selected: \(selectedGoals), canContinue: \(canContinue)")
        #endif
    }
    
    func selectRisk(_ profile: RiskProfile) {
        selectedRisk = profile
    }
    
    func advance() {
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return }
        step = next
    }
    
    func goBack() {
        guard let previous = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }
    
    func reset() {
        step = .welcome
    }
}
