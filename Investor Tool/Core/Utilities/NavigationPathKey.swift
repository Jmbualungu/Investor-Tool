//
//  NavigationPathKey.swift
//  Investor Tool
//
//  Environment key for accessing navigation path binding
//

import SwiftUI

private struct NavigationPathKey: EnvironmentKey {
    static let defaultValue: Binding<[AppRoute]>? = nil
}

extension EnvironmentValues {
    var navigationPath: Binding<[AppRoute]>? {
        get { self[NavigationPathKey.self] }
        set { self[NavigationPathKey.self] = newValue }
    }
}
