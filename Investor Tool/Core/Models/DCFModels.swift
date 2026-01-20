//
//  DCFModels.swift
//  Investor Tool
//
//  Created for DCF Setup Flow
//

import Foundation

// MARK: - Enums

enum MarketCapTier: String, Codable, CaseIterable {
    case small
    case mid
    case large
    
    var displayName: String {
        switch self {
        case .small: return "Small Cap"
        case .mid: return "Mid Cap"
        case .large: return "Large Cap"
        }
    }
}

enum BusinessModelTag: String, Codable, CaseIterable {
    case subscription
    case transactional
    case assetHeavy
    case platform
    case advertising
    case other
    
    var displayName: String {
        switch self {
        case .subscription: return "Subscription"
        case .transactional: return "Transactional"
        case .assetHeavy: return "Asset-Heavy"
        case .platform: return "Platform"
        case .advertising: return "Advertising"
        case .other: return "Other"
        }
    }
}

enum DCFHorizon: String, Codable, CaseIterable {
    case oneYear
    case threeYear
    case fiveYear
    case tenYear
    
    var displayName: String {
        switch self {
        case .oneYear: return "1Y"
        case .threeYear: return "3Y"
        case .fiveYear: return "5Y"
        case .tenYear: return "10Y"
        }
    }
    
    var years: Int {
        switch self {
        case .oneYear: return 1
        case .threeYear: return 3
        case .fiveYear: return 5
        case .tenYear: return 10
        }
    }
}

enum DCFInvestmentStyle: String, Codable, CaseIterable {
    case conservative
    case base
    case aggressive
    
    var displayName: String {
        switch self {
        case .conservative: return "Conservative"
        case .base: return "Base"
        case .aggressive: return "Aggressive"
        }
    }
}

enum DCFInvestmentObjective: String, Codable, CaseIterable {
    case appreciation
    case compounding
    case downsideProtection
    
    var displayName: String {
        switch self {
        case .appreciation: return "Appreciation"
        case .compounding: return "Compounding"
        case .downsideProtection: return "Downside Protection"
        }
    }
}

enum UnitType: String, Codable, CaseIterable {
    case percent
    case multiple
    case currency
    case number
    
    func format(_ value: Double) -> String {
        switch self {
        case .percent:
            return String(format: "%.1f%%", value)
        case .multiple:
            return String(format: "%.2fx", value)
        case .currency:
            return String(format: "$%.0f", value)
        case .number:
            return String(format: "%.0f", value)
        }
    }
}

// MARK: - DCF Ticker (Extended)

struct DCFTicker: Identifiable, Hashable, Codable {
    let id: UUID
    let symbol: String
    let name: String
    let sector: String
    let industry: String
    let marketCapTier: MarketCapTier
    let businessModel: BusinessModelTag
    let blurb: String
    let currentPrice: Double?
    let currency: String
    
    init(
        id: UUID = UUID(),
        symbol: String,
        name: String,
        sector: String,
        industry: String,
        marketCapTier: MarketCapTier,
        businessModel: BusinessModelTag,
        blurb: String,
        currentPrice: Double? = nil,
        currency: String = "USD"
    ) {
        self.id = id
        self.symbol = symbol.uppercased()
        self.name = name
        self.sector = sector
        self.industry = industry
        self.marketCapTier = marketCapTier
        self.businessModel = businessModel
        self.blurb = blurb
        self.currentPrice = currentPrice
        self.currency = currency
    }
}

// MARK: - Investment Lens

struct InvestmentLens: Codable, Equatable {
    var horizon: DCFHorizon
    var style: DCFInvestmentStyle
    var objective: DCFInvestmentObjective
    
    init(
        horizon: DCFHorizon = .fiveYear,
        style: DCFInvestmentStyle = .base,
        objective: DCFInvestmentObjective = .appreciation
    ) {
        self.horizon = horizon
        self.style = style
        self.objective = objective
    }
    
    var previewText: String {
        switch (style, objective) {
        case (.conservative, .downsideProtection):
            return "This lens will bias your assumptions toward lower risk and capital preservation."
        case (.aggressive, .appreciation):
            return "This lens will bias your assumptions toward high growth and upside capture."
        case (.base, .compounding):
            return "This lens will bias your assumptions toward steady, sustainable growth."
        case (.conservative, _):
            return "This lens will bias your assumptions toward lower risk and cautious projections."
        case (.aggressive, _):
            return "This lens will bias your assumptions toward higher growth and optimistic outcomes."
        default:
            return "This lens will bias your assumptions toward balanced, moderate projections."
        }
    }
}

// MARK: - Revenue Driver

struct RevenueDriver: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let subtitle: String
    let unit: UnitType
    var value: Double
    let min: Double
    let max: Double
    let step: Double
    let impactsRevenue: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        unit: UnitType,
        value: Double,
        min: Double,
        max: Double,
        step: Double,
        impactsRevenue: Bool = true
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.unit = unit
        self.value = value
        self.min = min
        self.max = max
        self.step = step
        self.impactsRevenue = impactsRevenue
    }
}

// MARK: - Preset Scenario

enum PresetScenario: String, CaseIterable {
    case consensus
    case bear
    case base
    case bull
    
    var displayName: String {
        switch self {
        case .consensus: return "Consensus"
        case .bear: return "Bear"
        case .base: return "Base"
        case .bull: return "Bull"
        }
    }
}

// MARK: - Operating Assumptions

struct OperatingAssumptions: Codable, Equatable {
    var grossMargin: Double        // %
    var operatingMargin: Double    // %
    var taxRate: Double            // %
    var capexPercent: Double       // % of revenue
    var workingCapitalPercent: Double // % of revenue
    
    init(
        grossMargin: Double = 55.0,
        operatingMargin: Double = 22.0,
        taxRate: Double = 21.0,
        capexPercent: Double = 4.0,
        workingCapitalPercent: Double = 1.0
    ) {
        self.grossMargin = grossMargin
        self.operatingMargin = operatingMargin
        self.taxRate = taxRate
        self.capexPercent = capexPercent
        self.workingCapitalPercent = workingCapitalPercent
    }
}

// MARK: - Valuation Assumptions

struct ValuationAssumptions: Codable, Equatable {
    var discountRate: Double       // %
    var terminalGrowth: Double     // %
    var terminalMethod: TerminalMethod
    var exitMultiple: Double?      // optional (for later)
    
    init(
        discountRate: Double = 9.0,
        terminalGrowth: Double = 2.5,
        terminalMethod: TerminalMethod = .perpetuity,
        exitMultiple: Double? = nil
    ) {
        self.discountRate = discountRate
        self.terminalGrowth = terminalGrowth
        self.terminalMethod = terminalMethod
        self.exitMultiple = exitMultiple
    }
}

enum TerminalMethod: String, CaseIterable, Identifiable, Codable {
    case perpetuity = "Perpetuity Growth"
    case exitMultiple = "Exit Multiple"
    
    var id: String { rawValue }
}
