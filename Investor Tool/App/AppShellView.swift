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
        .environmentObject(flowState)
        .tint(DSColors.accent)
    }
}

#Preview {
    AppShellView()
}
