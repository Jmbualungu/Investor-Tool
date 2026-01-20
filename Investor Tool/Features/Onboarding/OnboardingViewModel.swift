import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep = .welcome
    @Published var selectedGoals: Set<String> = []
    @Published var selectedRisk: RiskProfile? = nil
    @Published var selectedPricingIndex: Int = 1
    
    let goals: [OnboardingGoal] = [
        OnboardingGoal(id: "wealth", title: "Grow long-term wealth", icon: "chart.line.uptrend.xyaxis"),
        OnboardingGoal(id: "income", title: "Build monthly income", icon: "banknote"),
        OnboardingGoal(id: "inflation", title: "Beat inflation", icon: "flame"),
        OnboardingGoal(id: "risk", title: "Reduce downside risk", icon: "shield"),
        OnboardingGoal(id: "learn", title: "Learn investing", icon: "book")
    ]
    
    let benefits: [OnboardingBenefit] = [
        OnboardingBenefit(
            id: "personalized",
            icon: "sparkles",
            title: "Personalized allocation",
            subtitle: "A plan matched to your goals and risk comfort."
        ),
        OnboardingBenefit(
            id: "alerts",
            icon: "bell.badge",
            title: "Rebalancing alerts",
            subtitle: "Timely nudges to stay on track."
        ),
        OnboardingBenefit(
            id: "insights",
            icon: "chart.bar.xaxis",
            title: "Tax-smart insights",
            subtitle: "Estimated impact of taxes and fees."
        )
    ]
    
    let pricingOptions: [PricingOption] = [
        PricingOption(
            id: "monthly",
            title: "Monthly",
            price: "$12.99",
            subtitle: "Billed monthly",
            isBestValue: false
        ),
        PricingOption(
            id: "annual",
            title: "Annual",
            price: "$79.99",
            subtitle: "Save 49% vs monthly",
            isBestValue: true
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
        case .benefits, .teaser, .paywall:
            return true
        }
    }
    
    func toggleGoal(_ goal: OnboardingGoal) {
        if selectedGoals.contains(goal.id) {
            selectedGoals.remove(goal.id)
        } else {
            selectedGoals.insert(goal.id)
        }
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
