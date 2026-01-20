//
//  AppRouterCoordinator.swift
//  Investor Tool
//
//  Simple navigation coordinator
//

import SwiftUI
import Combine

final class AppRouterCoordinator: ObservableObject {
    @Published var path: [Route] = []
    
    init() {
        print("AppRouterCoordinator initialized")
    }
    
    func push(_ route: Route) {
        path.append(route)
    }
    
    func pop() {
        _ = path.popLast()
    }
    
    func popToRoot() {
        path = []
    }
    
    func reset() {
        path = []
    }
}
