//
//  ValtydeTabBar.swift
//  Investor Tool
//
//  Valtyde's custom floating tab bar — a translucent, rounded bar with a cyan
//  active glow and a slightly larger center "Forecast" action. Replaces the
//  stock UITabBar chrome to match the brand mockup.
//

import SwiftUI

struct ValtydeTabBar: View {
    @Binding var selectedTab: AppShellView.Tab

    private struct Item: Identifiable {
        let tab: AppShellView.Tab
        let icon: String
        let label: String
        var isCenter: Bool = false
        var id: String { label }
    }

    private let items: [Item] = [
        Item(tab: .watchlist, icon: "chart.bar.fill",      label: "Watchlist"),
        Item(tab: .forecast,  icon: "sparkles",            label: "Forecast", isCenter: true),
        Item(tab: .library,   icon: "books.vertical.fill", label: "Library"),
        Item(tab: .settings,  icon: "gearshape.fill",      label: "Settings"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(item)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DSColors.surface.opacity(0.82))
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(DSColors.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 18, x: 0, y: 10)
    }

    private func tabButton(_ item: Item) -> some View {
        let isActive = selectedTab == item.tab
        return Button {
            HapticManager.shared.impact(style: .light)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTab = item.tab
            }
        } label: {
            VStack(spacing: 5) {
                // Active-state cyan glow dot (mirrors the mockup's .tab.on::before).
                Circle()
                    .fill(DSColors.cyan)
                    .frame(width: 5, height: 5)
                    .dsGlow(color: DSColors.cyan, radius: 5)
                    .opacity(isActive ? 1 : 0)

                Image(systemName: item.icon)
                    .font(.system(size: item.isCenter ? 24 : 20, weight: .semibold))
                    .foregroundColor(isActive ? DSColors.cyan : DSColors.textTertiary)
                    .dsGlow(color: isActive ? DSColors.accentGlow : .clear, radius: isActive ? 8 : 0)

                Text(item.label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(isActive ? DSColors.cyan : DSColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        DSColors.background.ignoresSafeArea()
        VStack {
            Spacer()
            ValtydeTabBar(selectedTab: .constant(.forecast))
                .padding(.horizontal, DSSpacing.m)
        }
    }
}
