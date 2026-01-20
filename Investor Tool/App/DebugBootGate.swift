//
//  DebugBootGate.swift
//  Investor Tool
//
//  Safety harness for controlled app boot
//

import SwiftUI
import Combine

final class DebugBootGate: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let userDefaults = UserDefaults.standard
    private let key = "debug_boot_minimal"
    
    /// When true, app boots in minimal diagnostic mode
    var debugBootMinimal: Bool {
        get { userDefaults.bool(forKey: key) }
        set {
            objectWillChange.send()
            userDefaults.set(newValue, forKey: key)
        }
    }
    
    /// Reset to safe state if needed
    func resetToSafe() {
        debugBootMinimal = true
    }
}
