//
//  ComingSoonSheet.swift
//  Investor Tool
//
//  Premium feature: Sheet for disabled save/share features
//

import SwiftUI

struct ComingSoonSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let feature: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DSSpacing.xl) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DSColors.accent.opacity(0.2),
                                    DSColors.accent.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: feature == "Save" ? "lock.fill" : "paperplane.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(DSColors.accent)
                }
                
                // Title & Description
                VStack(spacing: DSSpacing.m) {
                    Text("\(feature) Coming Soon")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    VStack(spacing: DSSpacing.s) {
                        Text("Sign-in and cloud sync are coming soon.")
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text("You'll be able to save forecasts, compare scenarios, and share a link.")
                            .font(DSTypography.body)
                            .foregroundColor(DSColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, DSSpacing.xl)
                
                Spacer()
                
                // Features Preview
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    featureRow(icon: "cloud.fill", text: "Cloud sync across devices")
                    featureRow(icon: "square.stack.3d.up.fill", text: "Compare multiple scenarios")
                    featureRow(icon: "link", text: "Share via link")
                    featureRow(icon: "chart.line.uptrend.xyaxis", text: "Export to PDF/Excel")
                }
                .padding(DSSpacing.l)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(DSColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                        .stroke(DSColors.border, lineWidth: 1)
                )
                .padding(.horizontal, DSSpacing.l)
                
                Spacer()
                
                // Close Button
                Button {
                    dismiss()
                } label: {
                    Text("OK")
                        .fontWeight(.semibold)
                }
                .primaryCTAStyle()
                .padding(.horizontal, DSSpacing.l)
            }
            .padding(.vertical, DSSpacing.xl)
            .background(DSColors.background)
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
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: DSSpacing.m) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DSColors.accent)
                .frame(width: 24)
            
            Text(text)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
        }
    }
}

#Preview {
    ComingSoonSheet(feature: "Save")
}
