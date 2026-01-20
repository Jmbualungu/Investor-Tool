import SwiftUI

struct DSCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let hasBorder: Bool
    let hasShadow: Bool

    init(
        padding: CGFloat = DSSpacing.l,
        hasBorder: Bool = true,
        hasShadow: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.hasBorder = hasBorder
        self.hasShadow = hasShadow
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            content
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous))
        .overlay(
            Group {
                if hasBorder {
                    RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                        .stroke(DSColors.border, lineWidth: 1)
                }
            }
        )
        .shadow(
            color: hasShadow ? Color.black.opacity(0.15) : Color.clear,
            radius: hasShadow ? 12 : 0,
            x: 0,
            y: hasShadow ? 6 : 0
        )
    }
}

struct DSPillChip: View {
    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .black : DSColors.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? DSColors.accent : DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                    .stroke(isSelected ? Color.clear : DSColors.border, lineWidth: 0.5)
            )
            .shadow(color: isSelected ? DSColors.accent.opacity(0.25) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .animation(.easeOut(duration: 0.2), value: isSelected)
    }
}

struct DSSectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .dsHeadline()
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.accent)
                    .accessibilityLabel(actionTitle)
            }
        }
    }
}

struct DSStatCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            Text(value)
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
        }
        .padding(DSSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.surface2)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
}

struct DSProgressBarRow: View {
    let label: String
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text(label)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                Spacer()
                Text("\(Int(percentage))%")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textPrimary)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DSColors.surface)
                        .frame(height: 8)
                    Capsule()
                        .fill(color)
                        .frame(width: max(8, CGFloat(percentage / 100) * geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct DSTabBar: View {
    var body: some View {
        HStack(spacing: 36) {
            Image(systemName: "chart.line.uptrend.xyaxis")
            Image(systemName: "magnifyingglass")
            Image(systemName: "star")
            Image(systemName: "bell")
            Image(systemName: "person.crop.circle")
        }
        .font(.system(size: 18, weight: .semibold))
        .foregroundColor(DSColors.textSecondary)
        .padding(.vertical, DSSpacing.m)
        .frame(maxWidth: .infinity)
        .background(DSColors.surface)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(DSColors.border),
            alignment: .top
        )
    }
}

struct DSPrimaryButton: View {
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
        Button(action: action) {
            HStack(spacing: DSSpacing.s) {
                Text(title)
                    .fontWeight(.semibold)
                
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .font(DSTypography.body)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeightStandard)
            .background(DSColors.accent)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct DSSecondaryButton: View {
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
        Button(action: action) {
            HStack(spacing: DSSpacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                Text(title)
                    .fontWeight(.semibold)
            }
            .font(DSTypography.body)
            .foregroundColor(DSColors.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeightStandard)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
