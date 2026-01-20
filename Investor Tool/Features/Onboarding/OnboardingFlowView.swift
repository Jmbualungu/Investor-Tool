import SwiftUI

struct OnboardingFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: DSSpacing.l) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DSSpacing.xl) {
                        content
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.top, DSSpacing.m)
                }
                
                footer
            }
            .padding(.bottom, DSSpacing.l)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var header: some View {
        VStack(spacing: DSSpacing.s) {
            HStack {
                Button {
                    if viewModel.step == .welcome {
                        dismiss()
                    } else {
                        viewModel.goBack()
                    }
                } label: {
                    Image(systemName: viewModel.step == .welcome ? "xmark" : "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(DSColors.surface)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(DSColors.border, lineWidth: 1)
                        )
                }
                
                Spacer()
                
                Text(viewModel.progressLabel)
                    .dsCaption()
            }
            .padding(.horizontal, DSSpacing.l)
            
            OnboardingProgress(step: viewModel.step)
                .padding(.horizontal, DSSpacing.l)
        }
        .padding(.top, DSSpacing.m)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.step {
        case .welcome:
            welcomeContent
        case .goals:
            goalsContent
        case .risk:
            riskContent
        case .benefits:
            benefitsContent
        case .teaser:
            teaserContent
        case .paywall:
            paywallContent
        }
    }
    
    private var footer: some View {
        VStack(spacing: DSSpacing.s) {
            DSPillButton(title: primaryCTA, style: .primary) {
                if viewModel.step == .paywall {
                    dismiss()
                } else {
                    viewModel.advance()
                }
            }
            .disabled(!viewModel.canContinue)
            .opacity(viewModel.canContinue ? 1 : 0.6)
            .padding(.horizontal, DSSpacing.l)
            
            if viewModel.step == .paywall {
                Button("Not now") {
                    dismiss()
                }
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
                .padding(.bottom, DSSpacing.s)
            }
        }
    }
    
    private var primaryCTA: String {
        switch viewModel.step {
        case .welcome:
            return "Start"
        case .paywall:
            return "Start free trial"
        default:
            return "Continue"
        }
    }
}

private extension OnboardingFlowView {
    var welcomeContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            ZStack {
                Circle()
                    .fill(DSColors.surface)
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .stroke(DSColors.border, lineWidth: 1)
                    )
                
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(DSColors.accent)
            }
            
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("Let’s personalize your investing plan")
                    .dsTitle()
                
                Text("Answer a few quick questions so we can tailor your experience.")
                    .dsSubheadline()
            }
        }
    }
    
    var goalsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("What brings you here?")
                    .dsTitle()
                Text("Select all that apply so we can customize your plan.")
                    .dsSubheadline()
            }
            
            VStack(spacing: DSSpacing.s) {
                ForEach(viewModel.goals) { goal in
                    OnboardingOptionPill(
                        title: goal.title,
                        icon: goal.icon,
                        isSelected: viewModel.selectedGoals.contains(goal.id)
                    ) {
                        viewModel.toggleGoal(goal)
                    }
                }
            }
        }
    }
    
    var riskContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("How comfortable are you with risk?")
                    .dsTitle()
                Text("We’ll shape your plan to match your comfort level.")
                    .dsSubheadline()
            }
            
            VStack(spacing: DSSpacing.s) {
                ForEach(RiskProfile.allCases) { profile in
                    OnboardingRiskCard(
                        title: profile.title,
                        description: profile.description,
                        icon: profile.icon,
                        isSelected: viewModel.selectedRisk == profile
                    ) {
                        viewModel.selectRisk(profile)
                    }
                }
            }
        }
    }
    
    var benefitsContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("What’s New")
                    .dsTitle()
                Text("A calm, focused way to stay on track.")
                    .dsSubheadline()
            }
            
            VStack(spacing: DSSpacing.m) {
                ForEach(viewModel.benefits) { benefit in
                    OnboardingBenefitRow(
                        icon: benefit.icon,
                        title: benefit.title,
                        subtitle: benefit.subtitle
                    )
                }
            }
        }
    }
    
    var teaserContent: some View {
        ZStack {
            LinearGradient(
                colors: [DSColors.surface2, DSColors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
            
            VStack(spacing: DSSpacing.s) {
                Text("Your plan is ready")
                    .dsTitle()
                Text("See your personalized strategy and projections.")
                    .dsSubheadline()
            }
            .padding(DSSpacing.xl)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }
    
    var paywallContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.l) {
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                Text("Unlock your personalized plan")
                    .dsTitle()
                Text("Start your free trial to access recommendations, alerts, and insights.")
                    .dsSubheadline()
            }
            
            DSGlassCard {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    ForEach(viewModel.benefits) { benefit in
                        OnboardingBenefitRow(
                            icon: benefit.icon,
                            title: benefit.title,
                            subtitle: benefit.subtitle
                        )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: DSSpacing.s) {
                DSSegmentedPill(
                    labels: viewModel.pricingOptions.map { $0.title },
                    selectedIndex: $viewModel.selectedPricingIndex
                )
                
                let option = viewModel.pricingOptions[viewModel.selectedPricingIndex]
                DSGlassCard {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(option.price)
                                .dsTitle()
                            Spacer()
                            if option.isBestValue {
                                Text("Best value")
                                    .font(DSTypography.caption.weight(.semibold))
                                    .foregroundColor(DSColors.accent)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(DSColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
                            }
                        }
                        Text(option.subtitle)
                            .dsSubheadline()
                    }
                }
            }
            
            Text("Cancel anytime.")
                .dsCaption()
        }
    }
}

private struct OnboardingProgress: View {
    let step: OnboardingStep
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(OnboardingStep.allCases) { item in
                Capsule()
                    .fill(item == step ? DSColors.accent : DSColors.surface2)
                    .frame(width: item == step ? 20 : 10, height: 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct OnboardingOptionPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.s) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(DSTypography.body)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(isSelected ? .white : DSColors.textPrimary)
            .padding(.horizontal, DSSpacing.l)
            .frame(height: DSSpacing.buttonHeightStandard)
            .background(isSelected ? DSColors.accent : DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                    .stroke(isSelected ? DSColors.accent : DSColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct OnboardingRiskCard: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(DSColors.accent)
                    .frame(width: 36, height: 36)
                    .background(DSColors.surface)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .dsHeadline()
                    Text(description)
                        .dsSubheadline()
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DSColors.accent)
                }
            }
            .padding(DSSpacing.l)
            .background(isSelected ? DSColors.surface2 : DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                    .stroke(isSelected ? DSColors.accent : DSColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct OnboardingBenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.m) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DSColors.surface2)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(DSColors.border, lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(DSColors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .dsHeadline()
                Text(subtitle)
                    .dsSubheadline()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        OnboardingFlowView()
    }
}
