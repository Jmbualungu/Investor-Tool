//
//  DSRow.swift
//  Investor Tool
//
//  Robinhood-style settings row component
//

import SwiftUI

struct DSRow: View {
    let title: String
    let subtitle: String?
    let value: String?
    let accessory: Accessory
    let action: (() -> Void)?
    
    enum Accessory {
        case none
        case chevron
        case toggle(Binding<Bool>)
        case valuePill(String)
    }
    
    init(
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        accessory: Accessory = .none,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.accessory = accessory
        self.action = action
    }
    
    var body: some View {
        Button {
            if let action {
                HapticManager.shared.selectionChanged()
                action()
            }
        } label: {
            HStack(spacing: DSSpacing.m) {
                // Left: Title + Subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DSTypography.body)
                        .foregroundColor(DSColors.textPrimary)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
                
                Spacer(minLength: DSSpacing.m)
                
                // Right: Value or Accessory
                accessoryView
            }
            .padding(DSSpacing.l)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil && !isToggle)
    }
    
    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            if let value {
                Text(value)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
            }
            
        case .chevron:
            if let value {
                Text(value)
                    .font(DSTypography.body)
                    .foregroundColor(DSColors.textSecondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DSColors.textTertiary)
            
        case .toggle(let binding):
            Toggle("", isOn: binding)
                .labelsHidden()
                .tint(DSColors.accent)
            
        case .valuePill(let pillValue):
            Text(pillValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DSColors.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DSColors.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        }
    }
    
    private var isToggle: Bool {
        if case .toggle = accessory {
            return true
        }
        return false
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        DSRow(
            title: "Discount Rate",
            subtitle: "Cost of equity capital",
            accessory: .valuePill("10.5%")
        )
        
        Divider().background(DSColors.border)
        
        DSRow(
            title: "Terminal Growth",
            value: "2.5%",
            accessory: .chevron
        ) {}
        
        Divider().background(DSColors.border)
        
        DSRow(
            title: "Dark Mode",
            subtitle: "Switch to dark theme",
            accessory: .toggle(.constant(true))
        )
    }
    .background(DSColors.surface)
    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
            .stroke(DSColors.border, lineWidth: 1)
    )
    .padding()
    .background(DSColors.background)
}
