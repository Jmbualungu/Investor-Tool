import SwiftUI
import SwiftData

struct SettingsView: View {
    @StateObject private var disclaimerManager = DisclaimerManager()
    @State private var showResetAlert = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    DSGlassCard {
                        NavigationLink {
                            OnboardingFlowView()
                        } label: {
                            HStack {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(DSColors.accent)
                                
                                Text("Onboarding")
                                    .dsHeadline()
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DSColors.textSecondary)
                            }
                        }
                    }
                    
                    DSGlassCard {
                        NavigationLink {
                            AboutView()
                        } label: {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(DSColors.accent)
                                
                                Text("About")
                                    .dsHeadline()
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DSColors.textSecondary)
                            }
                        }
                    }
                    
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            HStack {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(DSColors.accent)
                                
                                Text("Preferences")
                                    .dsHeadline()
                            }
                            
                            Text("Additional settings coming soon")
                                .dsCaption()
                        }
                    }
                    
                    DSGlassCard {
                        NavigationLink {
                            AssumptionsTemplateView(modelContext: modelContext)
                        } label: {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(DSColors.accent)
                                
                                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                    Text("Assumptions Templates")
                                        .dsHeadline()
                                    
                                    Text("Edit sample templates for forecasting")
                                        .dsCaption()
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DSColors.textSecondary)
                            }
                        }
                    }
                    
                    #if DEBUG
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            HStack {
                                Image(systemName: "ladybug")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(DSColors.danger)
                                
                                Text("Developer Tools")
                                    .dsHeadline()
                            }
                            
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    Text("Reset Financial Disclaimer")
                                        .font(DSTypography.body)
                                        .foregroundColor(DSColors.danger)
                                    Spacer()
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(DSColors.danger)
                                }
                                .padding(.vertical, DSSpacing.xs)
                            }
                            
                            Text("Status: \(disclaimerManager.hasAccepted ? "✓ Accepted" : "✗ Not Accepted")")
                                .dsCaption()
                                .foregroundColor(disclaimerManager.hasAccepted ? DSColors.success : DSColors.textSecondary)
                        }
                    }
                    #endif
                }
                .padding(DSSpacing.l)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("Reset Disclaimer", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                disclaimerManager.reset()
            }
        } message: {
            Text("This will reset the financial disclaimer acceptance. You'll need to accept it again on next app launch.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
