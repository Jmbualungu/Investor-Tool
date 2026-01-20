//
//  ChangeSummarySheet.swift
//  Investor Tool
//
//  Premium feature: Shows what changed vs base assumptions
//

import SwiftUI

struct ChangeItem: Identifiable {
    let id = UUID()
    let label: String
    let baseValue: String
    let currentValue: String
}

struct ChangeSummarySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var flowState: DCFFlowState
    
    let onRevertAll: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.l) {
                        // Header
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("Changes Summary")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(DSColors.textPrimary)
                            
                            Text("Review what you've changed from the base assumptions.")
                                .font(DSTypography.body)
                                .foregroundColor(DSColors.textSecondary)
                                .lineSpacing(4)
                        }
                        
                        // Revenue Drivers Changes
                        if !flowState.revenueChanges().isEmpty {
                            changeSection(
                                title: "Revenue Drivers",
                                icon: "chart.line.uptrend.xyaxis",
                                changes: flowState.revenueChanges()
                            )
                        }
                        
                        // Operating Assumptions Changes
                        if !flowState.operatingChanges().isEmpty {
                            changeSection(
                                title: "Operating Assumptions",
                                icon: "gearshape.fill",
                                changes: flowState.operatingChanges()
                            )
                        }
                        
                        // Valuation Assumptions Changes
                        if !flowState.valuationChanges().isEmpty {
                            changeSection(
                                title: "Valuation Assumptions",
                                icon: "dollarsign.circle.fill",
                                changes: flowState.valuationChanges()
                            )
                        }
                        
                        // No Changes Message
                        if flowState.revenueChanges().isEmpty &&
                           flowState.operatingChanges().isEmpty &&
                           flowState.valuationChanges().isEmpty {
                            VStack(spacing: DSSpacing.m) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 48, weight: .semibold))
                                    .foregroundColor(DSColors.accent)
                                
                                Text("No Changes")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(DSColors.textPrimary)
                                
                                Text("All assumptions match the base values.")
                                    .font(DSTypography.body)
                                    .foregroundColor(DSColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.xl)
                        }
                        
                        // Revert All Button
                        if flowState.hasAnyDrift() {
                            Button {
                                onRevertAll()
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text("Revert All to Base")
                                        .fontWeight(.semibold)
                                }
                            }
                            .secondaryCTAStyle()
                        }
                    }
                    .padding(DSSpacing.l)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
    }
    
    private func changeSection(title: String, icon: String, changes: [ChangeItem]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            HStack(spacing: DSSpacing.s) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DSColors.accent)
                
                Text(title)
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
            }
            
            VStack(spacing: DSSpacing.s) {
                ForEach(changes) { change in
                    changeRow(change: change)
                }
            }
        }
        .padding(DSSpacing.l)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
    
    private func changeRow(change: ChangeItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(change.label)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            HStack(spacing: DSSpacing.s) {
                Text(change.baseValue)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textTertiary)
                    .strikethrough()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(DSColors.accent)
                
                Text(change.currentValue)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.accent)
                    .fontWeight(.semibold)
            }
        }
        .padding(DSSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    }
}

#Preview {
    ChangeSummarySheet(onRevertAll: {})
        .environmentObject({
            let state = DCFFlowState()
            state.selectedTicker = DCFTicker(
                symbol: "AAPL",
                name: "Apple Inc.",
                sector: "Technology",
                industry: "Consumer Electronics",
                marketCapTier: .large,
                businessModel: .platform,
                blurb: "Test"
            )
            state.generateRevenueDrivers()
            return state
        }())
}
