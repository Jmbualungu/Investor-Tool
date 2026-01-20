//
//  AppState.swift
//  Investor Tool
//
//  Central app state container
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    // Authentication state
    @Published var isLoggedIn: Bool = true
    
    // Navigation state
    @Published var selectedTab: Int = 0
    
    // Boot state
    @Published var isReady: Bool = true
    
    init() {
        print("AppState initialized")
    }
}
