//
//  LibraryView.swift
//  Investor Tool
//
//  Library tab - saved forecasts (placeholder for now)
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.background
                    .ignoresSafeArea()
                
                emptyState
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DSSpacing.l) {
            Image(systemName: "books.vertical")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(DSColors.textSecondary)
            
            VStack(spacing: DSSpacing.s) {
                Text("Library Coming Soon")
                    .font(DSTypography.title)
                    .foregroundColor(DSColors.textPrimary)
                
                Text("Your saved forecasts will appear here. Use the Forecast tab to create valuations.")
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.xl)
            }
            
            // Feature list
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                featureRow(icon: "bookmark.fill", title: "Save forecasts")
                featureRow(icon: "square.and.arrow.up", title: "Export valuations")
                featureRow(icon: "chart.line.uptrend.xyaxis", title: "Track changes over time")
                featureRow(icon: "folder.fill", title: "Organize by portfolio")
            }
            .padding(DSSpacing.l)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
            .padding(.horizontal, DSSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DSSpacing.xl)
    }
    
    private func featureRow(icon: String, title: String) -> some View {
        HStack(spacing: DSSpacing.m) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DSColors.accent)
                .frame(width: 24)
            
            Text(title)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    LibraryView()
}
