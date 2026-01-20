//
//  DSBottomBar.swift
//  Investor Tool
//
//  Robinhood-style bottom CTA bar with primary and optional secondary actions
//

import SwiftUI

struct DSBottomBar<PrimaryContent: View, SecondaryContent: View>: View {
    let primaryContent: PrimaryContent
    let secondaryContent: SecondaryContent?
    
    init(
        @ViewBuilder primary: () -> PrimaryContent,
        @ViewBuilder secondary: () -> SecondaryContent
    ) {
        self.primaryContent = primary()
        self.secondaryContent = secondary()
    }
    
    init(@ViewBuilder primary: () -> PrimaryContent) where SecondaryContent == EmptyView {
        self.primaryContent = primary()
        self.secondaryContent = nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(DSColors.border.opacity(0.5))
            
            VStack(spacing: DSSpacing.m) {
                if let secondary = secondaryContent {
                    secondary
                }
                
                primaryContent
            }
            .padding(.horizontal, DSSpacing.l)
            .padding(.top, DSSpacing.m)
            .padding(.bottom, DSSpacing.l)
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Convenience Builders

struct DSBottomBarPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button {
            HapticManager.shared.impact(style: .light)
            action()
        } label: {
            HStack(spacing: DSSpacing.s) {
                Text(title)
                    .fontWeight(.semibold)
                
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .primaryCTAStyle()
        .pressableScale()
    }
}

struct DSBottomBarSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button {
            HapticManager.shared.impact(style: .light)
            action()
        } label: {
            HStack(spacing: DSSpacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text(title)
                    .fontWeight(.semibold)
            }
        }
        .secondaryCTAStyle()
        .pressableScale()
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        
        DSBottomBar {
            DSBottomBarPrimaryButton("Continue", icon: "arrow.right") {}
        } secondary: {
            DSBottomBarSecondaryButton("Reset to defaults", icon: "arrow.counterclockwise") {}
        }
    }
    .background(DSColors.background)
}
