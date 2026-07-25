import Foundation
import SwiftData

// MARK: - Enums

/// Entity identifiers for template assumptions
enum EntityID: String, Codable, CaseIterable, Identifiable {
    case autoIndustry = "auto_industry"
    case nvda
    case aapl
    case ge
    case cost
    case mcd
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .autoIndustry: return "Auto Industry"
        case .nvda: return "NVIDIA"
        case .aapl: return "Apple"
        case .ge: return "GE"
        case .cost: return "Costco"
        case .mcd: return "McDonald's"
        }
    }
}

/// Time horizons for forecasting
enum Horizon: String, Codable, CaseIterable, Identifiable {
    case oneYear = "1Y"
    case threeYear = "3Y"
    case fiveYear = "5Y"
    case tenYear = "10Y"
    
    var id: String { rawValue }
    
    var years: Int {
        switch self {
        case .oneYear: return 1
        case .threeYear: return 3
        case .fiveYear: return 5
        case .tenYear: return 10
        }
    }
    
    var description: String {
        switch self {
        case .oneYear: return "Near-term cycle + execution"
        case .threeYear: return "Strategy begins to show"
        case .fiveYear: return "Business model durability"
        case .tenYear: return "Long-cycle regime change"
        }
    }
}

/// Assumption categories
enum AssumptionSection: String, Codable, CaseIterable {
    case revenueDrivers
    case costAndMargins
    case investmentAndCapex
    case workingCapital
    case balanceSheetAndCapitalAllocation
    case valuationAndReturns
    case narrativeRerating
    
    var displayName: String {
        switch self {
        case .revenueDrivers: return "Revenue Drivers"
        case .costAndMargins: return "Cost & Margins"
        case .investmentAndCapex: return "Investment & Capex"
        case .workingCapital: return "Working Capital"
        case .balanceSheetAndCapitalAllocation: return "Balance Sheet & Capital Allocation"
        case .valuationAndReturns: return "Valuation & Returns"
        case .narrativeRerating: return "Narrative / Re-rating"
        }
    }
}

/// Type of value for an assumption
enum ValueType: String, Codable {
    case percent
    case currency
    case ratio
    case integer
    case slider
    case enumChoice
    case text
}

// MARK: - Models

/// Individual assumption item with metadata and slider configuration
@Model
final class AssumptionItem {
    var id: UUID
    var key: String // Stable identifier for ticker mapping
    var title: String
    var subtitle: String?
    var sectionRaw: String
    var valueTypeRaw: String
    
    // Base case value
    var baseValueDouble: Double?
    var baseValueString: String?
    
    // Slider configuration
    var usesSlider: Bool
    var sliderMin: Double?
    var sliderMax: Double?
    var sliderStep: Double?
    var sliderUnitLabel: String?
    
    // Scenario fields (for future use)
    var bullValueDouble: Double?
    var bearValueDouble: Double?
    
    // Metadata
    var importance: Int // 1-5
    var driverTag: String // Revenue, GrossMargin, Opex, Capex, WorkingCapital, Financing, Valuation
    var affectsRaw: String // JSON array as string
    var notes: String?
    
    var section: AssumptionSection {
        get { AssumptionSection(rawValue: sectionRaw) ?? .revenueDrivers }
        set { sectionRaw = newValue.rawValue }
    }
    
    var valueType: ValueType {
        get { ValueType(rawValue: valueTypeRaw) ?? .slider }
        set { valueTypeRaw = newValue.rawValue }
    }
    
    var affects: [String] {
        get {
            guard let data = affectsRaw.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                affectsRaw = string
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        key: String,
        title: String,
        subtitle: String? = nil,
        section: AssumptionSection,
        valueType: ValueType,
        baseValueDouble: Double? = nil,
        baseValueString: String? = nil,
        usesSlider: Bool = false,
        sliderMin: Double? = nil,
        sliderMax: Double? = nil,
        sliderStep: Double? = nil,
        sliderUnitLabel: String? = nil,
        bullValueDouble: Double? = nil,
        bearValueDouble: Double? = nil,
        importance: Int = 3,
        driverTag: String,
        affects: [String] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.sectionRaw = section.rawValue
        self.valueTypeRaw = valueType.rawValue
        self.baseValueDouble = baseValueDouble
        self.baseValueString = baseValueString
        self.usesSlider = usesSlider
        self.sliderMin = sliderMin
        self.sliderMax = sliderMax
        self.sliderStep = sliderStep
        self.sliderUnitLabel = sliderUnitLabel
        self.bullValueDouble = bullValueDouble
        self.bearValueDouble = bearValueDouble
        self.importance = importance
        self.driverTag = driverTag
        self.notes = notes
        
        // Set affects
        if let data = try? JSONEncoder().encode(affects),
           let string = String(data: data, encoding: .utf8) {
            self.affectsRaw = string
        } else {
            self.affectsRaw = "[]"
        }
    }
}

/// Template containing all assumptions for an entity at a specific horizon
@Model
final class EntityAssumptionsTemplate {
    var id: UUID
    var entityIDRaw: String
    var horizonRaw: String
    @Relationship(deleteRule: .cascade) var items: [AssumptionItem]
    
    var entityID: EntityID {
        get { EntityID(rawValue: entityIDRaw) ?? .aapl }
        set { entityIDRaw = newValue.rawValue }
    }
    
    var horizon: Horizon {
        get { Horizon(rawValue: horizonRaw) ?? .fiveYear }
        set { horizonRaw = newValue.rawValue }
    }
    
    init(
        id: UUID = UUID(),
        entityID: EntityID,
        horizon: Horizon,
        items: [AssumptionItem] = []
    ) {
        self.id = id
        self.entityIDRaw = entityID.rawValue
        self.horizonRaw = horizon.rawValue
        self.items = items
    }
}

// MARK: - Codable Fallback Models (for iOS < 17)

struct CodableAssumptionItem: Codable, Identifiable {
    var id: UUID
    var key: String
    var title: String
    var subtitle: String?
    var section: AssumptionSection
    var valueType: ValueType
    var baseValueDouble: Double?
    var baseValueString: String?
    var usesSlider: Bool
    var sliderMin: Double?
    var sliderMax: Double?
    var sliderStep: Double?
    var sliderUnitLabel: String?
    var bullValueDouble: Double?
    var bearValueDouble: Double?
    var importance: Int
    var driverTag: String
    var affects: [String]
    var notes: String?
}

struct CodableEntityAssumptionsTemplate: Codable, Identifiable {
    var id: UUID
    var entityID: EntityID
    var horizon: Horizon
    var items: [CodableAssumptionItem]
}
