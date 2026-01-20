//
//  AppLogger.swift
//  Investor Tool
//
//  Lightweight logging for debugging (DEBUG builds only)
//

import Foundation
import os.log

enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.investortool"
    private static let logger = Logger(subsystem: subsystem, category: "app")
    
    /// Log a debug message (only in DEBUG builds)
    static func log(_ message: String, category: LogCategory = .general) {
        #if DEBUG
        logger.debug("\(category.emoji) [\(category.rawValue)] \(message)")
        #endif
    }
    
    /// Log an error message
    static func error(_ message: String, error: Error? = nil) {
        #if DEBUG
        if let error = error {
            logger.error("❌ [ERROR] \(message): \(error.localizedDescription)")
        } else {
            logger.error("❌ [ERROR] \(message)")
        }
        #endif
    }
    
    /// Log a warning message
    static func warning(_ message: String) {
        #if DEBUG
        logger.warning("⚠️ [WARNING] \(message)")
        #endif
    }
}

// MARK: - Log Categories

extension AppLogger {
    enum LogCategory: String {
        case general = "General"
        case navigation = "Navigation"
        case validation = "Validation"
        case calculation = "Calculation"
        case userAction = "UserAction"
        case state = "State"
        
        var emoji: String {
            switch self {
            case .general: return "ℹ️"
            case .navigation: return "🧭"
            case .validation: return "✅"
            case .calculation: return "🧮"
            case .userAction: return "👆"
            case .state: return "📊"
            }
        }
    }
}
