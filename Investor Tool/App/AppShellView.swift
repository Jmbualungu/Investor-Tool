//
//  AppShellView.swift
//  Investor Tool
//
//  Main app shell with Robinhood-like tab bar
//

import SwiftUI

struct AppShellView: View {
    @StateObject private var flowState = DCFFlowState()
    @State private var selectedTab: Tab = .forecast

    enum Tab {
        case watchlist
        case forecast
        case library
        case settings
    }

    init() {
        // Valtyde tab bar: translucent navy, cyan active, faint inactive.
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(DSColors.surface).withAlphaComponent(0.92)
        let cyan = UIColor(DSColors.cyan)
        let faint = UIColor(DSColors.textTertiary)
        for item in [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance,
        ] {
            item.selected.iconColor = cyan
            item.selected.titleTextAttributes = [.foregroundColor: cyan]
            item.normal.iconColor = faint
            item.normal.titleTextAttributes = [.foregroundColor: faint]
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Watchlist Tab
            WatchlistView()
                .tabItem {
                    Label("Watchlist", systemImage: "star.fill")
                }
                .tag(Tab.watchlist)
            
            // Forecast Tab (Main)
            ForecastHomeView()
                .tabItem {
                    Label("Forecast", systemImage: "sparkles")
                }
                .tag(Tab.forecast)
            
            // Library Tab
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
                .tag(Tab.library)
            
            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(Tab.settings)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(flowState)
        .tint(DSColors.cyan)
    }
}

#Preview {
    AppShellView()
}
