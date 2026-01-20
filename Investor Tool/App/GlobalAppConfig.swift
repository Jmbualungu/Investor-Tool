//
//  GlobalAppConfig.swift
//  Investor Tool
//
//  Global app configuration and safe mode
//

import SwiftUI
import Combine

final class GlobalAppConfig: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let userDefaults = UserDefaults.standard
    
    /// Safe mode disables network/API calls and uses sample data
    var safeMode: Bool {
        get {
            if userDefaults.object(forKey: "safeMode") == nil {
                return false // Default to false - only enable via Settings toggle
            }
            return userDefaults.bool(forKey: "safeMode")
        }
        set {
            objectWillChange.send()
            userDefaults.set(newValue, forKey: "safeMode")
        }
    }
    
    /// Has user seen onboarding
    var hasSeenOnboarding: Bool {
        get { userDefaults.bool(forKey: "hasSeenOnboarding") }
        set {
            objectWillChange.send()
            userDefaults.set(newValue, forKey: "hasSeenOnboarding")
        }
    }
    
    /// Sample ticker for safe mode
    let sampleTicker = Ticker(symbol: "AAPL", name: "Apple Inc.")
    
    /// Sample assumptions for safe mode
    var sampleAssumptions: ForecastAssumptions {
        ForecastAssumptions(
            currentPrice: 150.0,
            currentRevenue: 383000.0,
            revenueCagr: 0.08,
            operatingMargin: 0.25,
            taxRate: 0.21,
            sharesOutstanding: 15500.0,
            netDebt: -62000.0,
            exitMultiple: 5.0,
            horizonYears: 5,
            discountRate: 0.10
        )
    }
    
    init() {
        print("GlobalAppConfig initialized - Safe Mode: \(safeMode)")
    }
    
    func toggleSafeMode() {
        safeMode.toggle()
        print("Safe Mode toggled to: \(safeMode)")
    }
}
