import SwiftUI

// MARK: - DSGlassCard
struct DSGlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            content
        }
        .padding(DSSpacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

// MARK: - DSPillButton
enum DSPillButtonStyle {
    case primary
    case secondary
    case destructive
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return DSColors.accent
        case .secondary:
            return DSColors.surface
        case .destructive:
            return DSColors.danger
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary, .destructive:
            return .white
        case .secondary:
            return DSColors.textPrimary
        }
    }
}

struct DSPillButton: View {
    let title: String
    let style: DSPillButtonStyle
    let icon: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        title: String,
        style: DSPillButtonStyle = .primary,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.s) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(DSTypography.button)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DSSpacing.buttonHeightStandard)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        }
    }
}

// MARK: - DSSegmentedPill
struct DSSegmentedPill: View {
    let labels: [String]
    @Binding var selectedIndex: Int
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedIndex = index
                    }
                } label: {
                    Text(label)
                        .font(DSTypography.subheadline)
                        .fontWeight(selectedIndex == index ? .semibold : .regular)
                        .foregroundColor(selectedIndex == index ? DSColors.textPrimary : DSColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: DSSpacing.buttonHeightCompact)
                        .background {
                            if selectedIndex == index {
                                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                                    .fill(DSColors.accent)
                                    .matchedGeometryEffect(id: "segmentHighlight", in: animation)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
}

// MARK: - DSIconCircleButton
struct DSIconCircleButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(DSColors.border, lineWidth: 1)
                )
        }
    }
}

// MARK: - DSSearchPill
struct DSSearchPill: View {
    @Binding var text: String
    let placeholder: String
    
    init(text: Binding<String>, placeholder: String = "Search") {
        self._text = text
        self.placeholder = placeholder
    }
    
    var body: some View {
        HStack(spacing: DSSpacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DSColors.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(DSTypography.body)
                .foregroundColor(DSColors.textPrimary)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DSColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, DSSpacing.l)
        .frame(height: DSSpacing.buttonHeightStandard)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
}

// MARK: - DSChip
struct DSChip: View {
    let text: String
    let action: (() -> Void)?
    
    init(text: String, action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    chipContent
                }
                .buttonStyle(.plain)
            } else {
                chipContent
            }
        }
    }
    
    private var chipContent: some View {
        Text(text)
            .font(DSTypography.subheadline)
            .fontWeight(.medium)
            .foregroundColor(DSColors.textPrimary)
            .padding(.horizontal, DSSpacing.m)
            .padding(.vertical, DSSpacing.s)
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                    .stroke(DSColors.border, lineWidth: 1)
            )
    }
}

// MARK: - DSChipBar
struct DSChipBar: View {
    let items: [String]
    let onTap: ((String) -> Void)?
    
    init(items: [String], onTap: ((String) -> Void)? = nil) {
        self.items = items
        self.onTap = onTap
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.s) {
                ForEach(items, id: \.self) { item in
                    DSChip(text: item) {
                        onTap?(item)
                    }
                }
            }
        }
    }
}

// MARK: - DSMetricRow
struct DSMetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
            Spacer()
            Text(value)
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
        }
    }
}

// MARK: - Legacy Components (for backward compatibility)
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        DSPillButton(title: title, style: .primary, action: action)
    }
}

struct TickerPill: View {
    let symbol: String
    let name: String
    
    var body: some View {
        HStack(spacing: DSSpacing.s) {
            Text(symbol)
                .font(DSTypography.headline)
                .foregroundColor(DSColors.textPrimary)
            Text(name)
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
        }
        .padding(.horizontal, DSSpacing.m)
        .padding(.vertical, DSSpacing.s)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
    }
}

struct SectionCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        DSGlassCard {
            content
        }
    }
}

struct LabeledTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isValid: (String) -> Bool
    let helpText: String?
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        helpText: String? = nil,
        isValid: @escaping (String) -> Bool = { _ in true }
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.helpText = helpText
        self.isValid = isValid
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textSecondary)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(DSColors.surface)
                .foregroundColor(DSColors.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous)
                        .stroke(isValid(text) ? DSColors.border : DSColors.danger, lineWidth: 1)
                )
            if let helpText, !isValid(text) {
                InlineHelpText(text: helpText)
            }
        }
    }
}

struct InlineHelpText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(DSTypography.caption)
            .foregroundColor(DSColors.textSecondary)
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        DSMetricRow(label: label, value: value)
    }
}
