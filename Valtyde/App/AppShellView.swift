//
//  AppShellView.swift
//  Valtyde
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

    var body: some View {
        // System tab bar is hidden per-tab; the custom ValtydeTabBar is overlaid
        // on top. TabView still owns selection + per-tab state preservation.
        TabView(selection: $selectedTab) {
            WatchlistView()
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.watchlist)

            ForecastHomeView()
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.forecast)

            LibraryView()
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.library)

            NavigationStack {
                SettingsView()
            }
            .toolbar(.hidden, for: .tabBar)
            .tag(Tab.settings)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            ValtydeTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, DSSpacing.m)
                .padding(.bottom, DSSpacing.s)
        }
        .environmentObject(flowState)
        .tint(DSColors.cyan)
    }
}

#Preview {
    AppShellView()
}
