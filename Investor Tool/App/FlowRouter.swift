//
//  FlowRouter.swift
//  Investor Tool
//
//  Comprehensive flow router for the full app navigation
//

import SwiftUI
import Combine

enum FlowRoute: Hashable {
    case welcome
    case tickerSearch
    case assumptions
    case forecast
    case sensitivity
    case settings
    
    var displayName: String {
        switch self {
        case .welcome: return "Welcome"
        case .tickerSearch: return "Ticker Search"
        case .assumptions: return "Assumptions"
        case .forecast: return "Forecast"
        case .sensitivity: return "Sensitivity"
        case .settings: return "Settings"
        }
    }
}

final class FlowRouter: ObservableObject {
    @Published var path: [FlowRoute] = []
    @Published var selectedTicker: Ticker?
    @Published var selectedHorizon: Int = 5
    @Published var assumptions: ForecastAssumptions
    
    init() {
        self.assumptions = ForecastAssumptions.default
        print("FlowRouter initialized")
    }
    
    // MARK: - Navigation Methods
    
    func push(_ route: FlowRoute) {
        path.append(route)
        print("Pushed route: \(route.displayName), path count: \(path.count)")
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        let popped = path.removeLast()
        print("Popped route: \(popped.displayName), path count: \(path.count)")
    }
    
    func popToRoot() {
        path.removeAll()
        print("Popped to root")
    }
    
    func reset() {
        path.removeAll()
        selectedTicker = nil
        selectedHorizon = 5
        assumptions = ForecastAssumptions.default
        print("Router reset")
    }
    
    // MARK: - Direct Navigation
    
    func goToWelcome() {
        path = [.welcome]
    }
    
    func goToTickerSearch() {
        path = [.tickerSearch]
    }
    
    func goToAssumptions() {
        path = [.tickerSearch, .assumptions]
    }
    
    func goToSensitivity() {
        path = [.tickerSearch, .assumptions, .forecast, .sensitivity]
    }
    
    // MARK: - Flow Methods
    
    func continueFromTickerSearch(ticker: Ticker, horizon: Int) {
        selectedTicker = ticker
        selectedHorizon = horizon
        push(.assumptions)
    }
    
    func continueFromAssumptions(assumptions: ForecastAssumptions) {
        self.assumptions = assumptions
        push(.forecast)
    }
    
    func continueToSensitivity() {
        push(.sensitivity)
    }
}
