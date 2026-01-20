import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String = "tray",
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DSSpacing.l) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(DSColors.textSecondary)
            
            Text(title)
                .dsTitle()
                .multilineTextAlignment(.center)
            
            Text(message)
                .dsBody()
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if let actionTitle, let action {
                DSPillButton(
                    title: actionTitle,
                    style: .primary,
                    action: action
                )
                .frame(maxWidth: 280)
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColors.background)
    }
}

#Preview {
    VStack(spacing: 20) {
        EmptyStateView(
            icon: "chart.line.uptrend.xyaxis",
            title: "No History",
            message: "Run a forecast to see results here.",
            actionTitle: "Go Home",
            action: {}
        )
        
        EmptyStateView(
            icon: "magnifyingglass",
            title: Copy.noMatchesFound,
            message: Copy.tryCompanyName
        )
    }
}
