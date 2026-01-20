//
//  CompanyContextModels.swift
//  Investor Tool
//
//  Company context data models for comprehensive company analysis
//  Architecture: Designed for future backend integration (Supabase/REST)
//

import Foundation

// MARK: - Main Model

struct CompanyContextModel: Codable, Identifiable {
    var id: String { ticker }
    let ticker: String
    let companyName: String
    let sector: String
    let industry: String
    let tags: [String]
    
    let snapshot: SnapshotModel
    let heatMap: HeatMapModel
    let revenueDrivers: [DriverModel]
    let competitors: [CompetitorModel]
    let risks: [RiskModel]
    let framing: String
}

// MARK: - Snapshot Model

struct SnapshotModel: Codable {
    let currentPrice: Double
    let marketCap: Double
    let dayChangeAbs: Double
    let dayChangePct: Double
    let description: String
    let geography: String
    let businessModel: String
    let lifecycle: String
}

// MARK: - Heat Map Model

struct HeatMapModel: Codable {
    let rows: [HeatMapRow]
    let columns: [String] // e.g., ["1Y", "3Y", "5Y"]
}

struct HeatMapRow: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let values: [HeatMapCell] // must match columns count
}

struct HeatMapCell: Codable, Identifiable {
    let id: String
    let score: Double  // normalized 0...1
    let label: String  // e.g., "High", "Med", "Low"
}

// MARK: - Driver Model

struct DriverModel: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let sensitivity: String // "Low"/"Med"/"High"
}

// MARK: - Competitor Model

struct CompetitorModel: Codable, Identifiable {
    let id: String
    let name: String
    let relativeScale: String // "Smaller"/"Similar"/"Larger"
    let note: String?
}

// MARK: - Risk Model

struct RiskModel: Codable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let impact: String // "Low"/"Med"/"High"
}

// MARK: - Helper Extensions

extension SnapshotModel {
    var formattedPrice: String {
        Formatters.formatCurrency(currentPrice)
    }
    
    var formattedMarketCap: String {
        Formatters.formatMarketCap(marketCap)
    }
    
    var formattedDayChange: String {
        let sign = dayChangeAbs >= 0 ? "+" : ""
        return "\(sign)\(Formatters.formatCurrency(dayChangeAbs))"
    }
    
    var formattedDayChangePct: String {
        let sign = dayChangePct >= 0 ? "+" : ""
        return "\(sign)\(Formatters.formatNumber(dayChangePct, decimals: 2))%"
    }
    
    var isPositiveChange: Bool {
        dayChangePct >= 0
    }
}
