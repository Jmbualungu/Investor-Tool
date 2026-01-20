//
//  PriceRange.swift
//  Investor Tool
//
//  Price chart time range options
//

import Foundation

enum PriceRange: String, CaseIterable, Identifiable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case oneYear = "1Y"
    
    var id: String { rawValue }
    
    var pointCount: Int {
        switch self {
        case .oneDay: return 60      // 60 points (every 6.5 minutes for trading hours)
        case .oneWeek: return 35     // 35 points (7 trading days)
        case .oneMonth: return 30    // 30 points (~1 per trading day)
        case .oneYear: return 52     // 52 points (weekly)
        }
    }
    
    var displayName: String {
        switch self {
        case .oneDay: return "1 Day"
        case .oneWeek: return "1 Week"
        case .oneMonth: return "1 Month"
        case .oneYear: return "1 Year"
        }
    }
}
