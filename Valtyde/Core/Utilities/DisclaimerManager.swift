import SwiftUI
import Combine

/// Manages the state of the financial disclaimer acceptance
/// Persists acceptance to UserDefaults for app lifecycle persistence
final class DisclaimerManager: ObservableObject {
    @AppStorage("hasAcceptedFinancialDisclaimer") var hasAccepted: Bool = false
    
    /// Mark the disclaimer as accepted
    func accept() {
        hasAccepted = true
    }
    
    /// Reset the disclaimer acceptance (for testing purposes only)
    func reset() {
        hasAccepted = false
    }
}
