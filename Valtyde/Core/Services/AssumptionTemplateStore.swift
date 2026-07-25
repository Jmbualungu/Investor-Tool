import Foundation
import SwiftData
import Combine

/// Service for managing assumption templates with local storage
@MainActor
class AssumptionTemplateStore: ObservableObject {
    private let modelContext: ModelContext
    @Published var templates: [EntityAssumptionsTemplate] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTemplates()
        seedIfEmpty()
    }
    
    private func loadTemplates() {
        let descriptor = FetchDescriptor<EntityAssumptionsTemplate>()
        templates = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func getTemplate(entityID: EntityID, horizon: Horizon) -> EntityAssumptionsTemplate? {
        return templates.first { $0.entityID == entityID && $0.horizon == horizon }
    }
    
    func updateItem(_ item: AssumptionItem) {
        try? modelContext.save()
        objectWillChange.send()
    }
    
    func resetTemplate(entityID: EntityID, horizon: Horizon) {
        // Remove existing
        if let existing = getTemplate(entityID: entityID, horizon: horizon) {
            modelContext.delete(existing)
        }
        
        // Re-seed
        let template = createTemplateForEntity(entityID, horizon: horizon)
        modelContext.insert(template)
        try? modelContext.save()
        loadTemplates()
    }
    
    // MARK: - Seeding
    
    func seedIfEmpty() {
        guard templates.isEmpty else { return }
        
        for entity in EntityID.allCases {
            for horizon in Horizon.allCases {
                let template = createTemplateForEntity(entity, horizon: horizon)
                modelContext.insert(template)
            }
        }
        
        try? modelContext.save()
        loadTemplates()
    }
    
    private func createTemplateForEntity(_ entityID: EntityID, horizon: Horizon) -> EntityAssumptionsTemplate {
        let template = EntityAssumptionsTemplate(entityID: entityID, horizon: horizon)
        
        // Add core assumptions common to all entities
        var items = createCoreAssumptions(horizon: horizon)
        
        // Add entity-specific assumptions
        switch entityID {
        case .autoIndustry:
            items.append(contentsOf: createAutoIndustryAssumptions(horizon: horizon))
        case .nvda:
            items.append(contentsOf: createNvidiaAssumptions(horizon: horizon))
        case .aapl:
            items.append(contentsOf: createAppleAssumptions(horizon: horizon))
        case .ge:
            items.append(contentsOf: createGEAssumptions(horizon: horizon))
        case .cost:
            items.append(contentsOf: createCostcoAssumptions(horizon: horizon))
        case .mcd:
            items.append(contentsOf: createMcDonaldsAssumptions(horizon: horizon))
        }
        
        template.items = items
        return template
    }
    
    // MARK: - Core Assumptions (shared by all entities)
    
    private func createCoreAssumptions(horizon: Horizon) -> [AssumptionItem] {
        let horizonMultiplier = Double(horizon.years)
        
        return [
            // Revenue Drivers
            AssumptionItem(
                key: "revenue_growth",
                title: "Revenue Growth",
                subtitle: "Annual revenue growth rate",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 8.0 + horizonMultiplier,
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 30.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "FCF", "Valuation"]
            ),
            AssumptionItem(
                key: "volume_growth",
                title: "Volume Growth",
                subtitle: "Unit/quantity growth",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 5.0,
                usesSlider: true,
                sliderMin: -15.0,
                sliderMax: 25.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "price_asp_change",
                title: "Price/ASP Change",
                subtitle: "Average selling price trend",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 2.0,
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 15.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin"]
            ),
            AssumptionItem(
                key: "mix_shift",
                title: "Mix Shift Impact",
                subtitle: "Product/segment mix quality",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 1.0,
                usesSlider: true,
                sliderMin: -5.0,
                sliderMax: 10.0,
                sliderStep: 0.25,
                sliderUnitLabel: "%",
                importance: 3,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin"]
            ),
            
            // Cost & Margins
            AssumptionItem(
                key: "gross_margin",
                title: "Gross Margin",
                subtitle: "Gross profit as % of revenue",
                section: .costAndMargins,
                valueType: .percent,
                baseValueDouble: 35.0,
                usesSlider: true,
                sliderMin: 5.0,
                sliderMax: 70.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "GrossMargin",
                affects: ["FCF", "Valuation"]
            ),
            AssumptionItem(
                key: "operating_margin",
                title: "Operating Margin",
                subtitle: "EBIT as % of revenue",
                section: .costAndMargins,
                valueType: .percent,
                baseValueDouble: 18.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 40.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Opex",
                affects: ["FCF", "Valuation"]
            ),
            AssumptionItem(
                key: "rd_pct_revenue",
                title: "R&D as % Revenue",
                subtitle: "Research & development intensity",
                section: .costAndMargins,
                valueType: .percent,
                baseValueDouble: 5.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 25.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 3,
                driverTag: "Opex",
                affects: ["OperatingMargin"]
            ),
            
            // Investment & Capex
            AssumptionItem(
                key: "capex_pct_revenue",
                title: "Capex as % Revenue",
                subtitle: "Capital expenditure intensity",
                section: .investmentAndCapex,
                valueType: .percent,
                baseValueDouble: 4.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 20.0,
                sliderStep: 0.25,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Capex",
                affects: ["FCF"]
            ),
            AssumptionItem(
                key: "maintenance_capex_split",
                title: "Maintenance Capex %",
                subtitle: "Portion of capex for maintenance",
                section: .investmentAndCapex,
                valueType: .percent,
                baseValueDouble: 60.0,
                usesSlider: true,
                sliderMin: 20.0,
                sliderMax: 100.0,
                sliderStep: 5.0,
                sliderUnitLabel: "%",
                importance: 2,
                driverTag: "Capex",
                affects: ["FCF"]
            ),
            
            // Working Capital
            AssumptionItem(
                key: "nwc_change_pct_revenue",
                title: "NWC Change as % Revenue",
                subtitle: "Working capital efficiency",
                section: .workingCapital,
                valueType: .percent,
                baseValueDouble: 2.0,
                usesSlider: true,
                sliderMin: -5.0,
                sliderMax: 10.0,
                sliderStep: 0.25,
                sliderUnitLabel: "%",
                importance: 3,
                driverTag: "WorkingCapital",
                affects: ["FCF"]
            ),
            AssumptionItem(
                key: "inventory_turns",
                title: "Inventory Turns",
                subtitle: "Times per year",
                section: .workingCapital,
                valueType: .ratio,
                baseValueDouble: 8.0,
                usesSlider: true,
                sliderMin: 2.0,
                sliderMax: 25.0,
                sliderStep: 0.5,
                sliderUnitLabel: "x",
                importance: 2,
                driverTag: "WorkingCapital",
                affects: ["FCF"]
            ),
            
            // Balance Sheet & Capital Allocation
            AssumptionItem(
                key: "net_debt_ebitda",
                title: "Net Debt / EBITDA",
                subtitle: "Leverage ratio",
                section: .balanceSheetAndCapitalAllocation,
                valueType: .ratio,
                baseValueDouble: 1.5,
                usesSlider: true,
                sliderMin: -3.0,
                sliderMax: 5.0,
                sliderStep: 0.25,
                sliderUnitLabel: "x",
                importance: 3,
                driverTag: "Financing",
                affects: ["SharePrice"]
            ),
            AssumptionItem(
                key: "buyback_pct_share_count",
                title: "Buyback % (Annual)",
                subtitle: "Share count reduction from buybacks",
                section: .balanceSheetAndCapitalAllocation,
                valueType: .percent,
                baseValueDouble: 2.0,
                usesSlider: true,
                sliderMin: -3.0,
                sliderMax: 5.0,
                sliderStep: 0.25,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Financing",
                affects: ["ShareCount", "SharePrice"]
            ),
            AssumptionItem(
                key: "sbc_dilution",
                title: "SBC Dilution (Annual)",
                subtitle: "Share-based compensation dilution",
                section: .balanceSheetAndCapitalAllocation,
                valueType: .percent,
                baseValueDouble: 1.5,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 5.0,
                sliderStep: 0.1,
                sliderUnitLabel: "%",
                importance: 3,
                driverTag: "Financing",
                affects: ["ShareCount", "SharePrice"]
            ),
            
            // Valuation & Returns (NEW)
            AssumptionItem(
                key: "starting_share_price",
                title: "Starting Share Price",
                subtitle: "Sample starting price",
                section: .valuationAndReturns,
                valueType: .currency,
                baseValueDouble: 100.0,
                usesSlider: true,
                sliderMin: 10.0,
                sliderMax: 500.0,
                sliderStep: 5.0,
                sliderUnitLabel: "$",
                importance: 5,
                driverTag: "Valuation",
                affects: ["SharePrice"]
            ),
            AssumptionItem(
                key: "starting_shares_outstanding",
                title: "Starting Shares Outstanding",
                subtitle: "Sample share count (millions)",
                section: .valuationAndReturns,
                valueType: .integer,
                baseValueDouble: 1000.0,
                usesSlider: true,
                sliderMin: 100.0,
                sliderMax: 20000.0,
                sliderStep: 100.0,
                sliderUnitLabel: "M",
                importance: 4,
                driverTag: "Valuation",
                affects: ["SharePrice"]
            ),
            AssumptionItem(
                key: "terminal_pe_multiple",
                title: "Terminal P/E Multiple",
                subtitle: "Exit valuation multiple",
                section: .valuationAndReturns,
                valueType: .ratio,
                baseValueDouble: 18.0,
                usesSlider: true,
                sliderMin: 5.0,
                sliderMax: 40.0,
                sliderStep: 0.5,
                sliderUnitLabel: "x",
                importance: 5,
                driverTag: "Valuation",
                affects: ["SharePrice", "Multiple"]
            ),
            AssumptionItem(
                key: "discount_rate",
                title: "Discount Rate / Required Return",
                subtitle: "Cost of equity assumption",
                section: .valuationAndReturns,
                valueType: .percent,
                baseValueDouble: 10.0,
                usesSlider: true,
                sliderMin: 6.0,
                sliderMax: 18.0,
                sliderStep: 0.25,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Valuation",
                affects: ["SharePrice"]
            ),
            AssumptionItem(
                key: "fcf_conversion_rate",
                title: "FCF Conversion Rate",
                subtitle: "FCF as % of EBIT",
                section: .valuationAndReturns,
                valueType: .percent,
                baseValueDouble: 75.0,
                usesSlider: true,
                sliderMin: 20.0,
                sliderMax: 100.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Valuation",
                affects: ["FCF", "SharePrice"]
            ),
            AssumptionItem(
                key: "dividend_yield",
                title: "Dividend Yield",
                subtitle: "Annual dividend as % of price",
                section: .valuationAndReturns,
                valueType: .percent,
                baseValueDouble: 1.5,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 8.0,
                sliderStep: 0.25,
                sliderUnitLabel: "%",
                importance: 2,
                driverTag: "Financing",
                affects: ["SharePrice"]
            ),
            
            // Narrative / Re-rating
            AssumptionItem(
                key: "regulatory_risk",
                title: "Regulatory/Geopolitical Risk",
                subtitle: nil,
                section: .narrativeRerating,
                valueType: .enumChoice,
                baseValueString: "Medium",
                importance: 3,
                driverTag: "Valuation",
                affects: ["Multiple"],
                notes: "Options: Low, Medium, High"
            ),
            AssumptionItem(
                key: "competitive_intensity",
                title: "Competitive Intensity",
                subtitle: nil,
                section: .narrativeRerating,
                valueType: .enumChoice,
                baseValueString: "Medium",
                importance: 3,
                driverTag: "Revenue",
                affects: ["Revenue", "Multiple"],
                notes: "Options: Low, Medium, High"
            ),
        ]
    }
    
    // MARK: - Entity-Specific Assumptions
    
    private func createAutoIndustryAssumptions(horizon: Horizon) -> [AssumptionItem] {
        return [
            AssumptionItem(
                key: "saar_unit_growth",
                title: "SAAR / Unit Proxy Growth",
                subtitle: "Seasonally adjusted annual rate",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 3.0,
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 15.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "incentives_pct_sales",
                title: "Incentives % of Sales",
                subtitle: "Promotional spending",
                section: .costAndMargins,
                valueType: .percent,
                baseValueDouble: 8.0,
                usesSlider: true,
                sliderMin: 2.0,
                sliderMax: 15.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "GrossMargin",
                affects: ["GrossMargin"]
            ),
            AssumptionItem(
                key: "ev_penetration",
                title: "EV Penetration %",
                subtitle: "Electric vehicle mix",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: horizon.years > 5 ? 35.0 : 15.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 80.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin", "Capex"]
            ),
            AssumptionItem(
                key: "dealer_inventory_days",
                title: "Dealer Inventory Days",
                subtitle: "Days of supply at dealers",
                section: .workingCapital,
                valueType: .integer,
                baseValueDouble: 55.0,
                usesSlider: true,
                sliderMin: 30.0,
                sliderMax: 90.0,
                sliderStep: 5.0,
                sliderUnitLabel: "days",
                importance: 2,
                driverTag: "WorkingCapital",
                affects: ["FCF"]
            ),
            AssumptionItem(
                key: "warranty_provision_pct",
                title: "Warranty/Recall Provision %",
                subtitle: "As % of revenue",
                section: .costAndMargins,
                valueType: .percent,
                baseValueDouble: 2.5,
                usesSlider: true,
                sliderMin: 0.5,
                sliderMax: 6.0,
                sliderStep: 0.25,
                sliderUnitLabel: "%",
                importance: 3,
                driverTag: "Opex",
                affects: ["OperatingMargin"]
            ),
        ]
    }
    
    private func createNvidiaAssumptions(horizon: Horizon) -> [AssumptionItem] {
        return [
            AssumptionItem(
                key: "datacenter_growth",
                title: "Data Center Growth",
                subtitle: "Annual growth in DC segment",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: horizon.years == 1 ? 45.0 : (horizon.years <= 3 ? 35.0 : 20.0),
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 60.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin"]
            ),
            AssumptionItem(
                key: "gpu_asp_trend",
                title: "GPU ASP Trend",
                subtitle: "Average selling price change",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 5.0,
                usesSlider: true,
                sliderMin: -20.0,
                sliderMax: 25.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin"]
            ),
            AssumptionItem(
                key: "inventory_days_nvda",
                title: "Inventory Days",
                subtitle: "Supply chain efficiency",
                section: .workingCapital,
                valueType: .integer,
                baseValueDouble: 90.0,
                usesSlider: true,
                sliderMin: 45.0,
                sliderMax: 180.0,
                sliderStep: 5.0,
                sliderUnitLabel: "days",
                importance: 3,
                driverTag: "WorkingCapital",
                affects: ["FCF"]
            ),
            AssumptionItem(
                key: "export_control_severity",
                title: "Export Control Severity",
                subtitle: "Regulatory restriction impact",
                section: .narrativeRerating,
                valueType: .enumChoice,
                baseValueString: "Medium",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue", "Multiple"],
                notes: "Options: Low, Medium, High, Critical"
            ),
            AssumptionItem(
                key: "custom_silicon_substitution_risk",
                title: "Custom Silicon Substitution Risk",
                subtitle: "Competitive threat score (0-100)",
                section: .narrativeRerating,
                valueType: .integer,
                baseValueDouble: 35.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 100.0,
                sliderStep: 5.0,
                sliderUnitLabel: "",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin", "Multiple"]
            ),
        ]
    }
    
    private func createAppleAssumptions(horizon: Horizon) -> [AssumptionItem] {
        return [
            AssumptionItem(
                key: "iphone_unit_growth",
                title: "iPhone Unit Growth",
                subtitle: "Annual iPhone unit change",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: horizon.years > 5 ? 1.0 : 3.0,
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 15.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "iphone_asp_growth",
                title: "iPhone ASP Growth",
                subtitle: "Average selling price trend",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 2.0,
                usesSlider: true,
                sliderMin: -5.0,
                sliderMax: 10.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin"]
            ),
            AssumptionItem(
                key: "installed_base_growth",
                title: "Installed Base Growth",
                subtitle: "Total active devices",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 5.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 15.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "services_arpu_growth",
                title: "Services ARPU Growth",
                subtitle: "Revenue per user in Services",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 8.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 20.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "OperatingMargin"]
            ),
            AssumptionItem(
                key: "upgrade_cycle_length",
                title: "Upgrade Cycle Length",
                subtitle: "Years between device upgrades",
                section: .revenueDrivers,
                valueType: .ratio,
                baseValueDouble: 3.2,
                usesSlider: true,
                sliderMin: 2.0,
                sliderMax: 5.0,
                sliderStep: 0.1,
                sliderUnitLabel: "yrs",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "app_store_regulation_risk",
                title: "App Store Regulation Risk",
                subtitle: "Impact from regulatory changes",
                section: .narrativeRerating,
                valueType: .enumChoice,
                baseValueString: "Medium",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue", "OperatingMargin", "Multiple"],
                notes: "Options: Low, Medium, High, Critical"
            ),
        ]
    }
    
    private func createGEAssumptions(horizon: Horizon) -> [AssumptionItem] {
        return [
            AssumptionItem(
                key: "book_to_bill",
                title: "Book-to-Bill Ratio",
                subtitle: "Orders vs shipments",
                section: .revenueDrivers,
                valueType: .ratio,
                baseValueDouble: 1.1,
                usesSlider: true,
                sliderMin: 0.7,
                sliderMax: 1.5,
                sliderStep: 0.05,
                sliderUnitLabel: "x",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "backlog_growth",
                title: "Backlog Growth",
                subtitle: "Order book expansion",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 5.0,
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 25.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "backlog_conversion",
                title: "Backlog Conversion Rate",
                subtitle: "% of backlog converted to revenue",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 45.0,
                usesSlider: true,
                sliderMin: 20.0,
                sliderMax: 80.0,
                sliderStep: 5.0,
                sliderUnitLabel: "%",
                importance: 3,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "aftermarket_mix",
                title: "Aftermarket Mix %",
                subtitle: "High-margin services revenue",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 35.0,
                usesSlider: true,
                sliderMin: 15.0,
                sliderMax: 60.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin"]
            ),
            AssumptionItem(
                key: "quality_certification_risk",
                title: "Quality/Certification Risk",
                subtitle: "Execution and compliance",
                section: .narrativeRerating,
                valueType: .enumChoice,
                baseValueString: "Low",
                importance: 3,
                driverTag: "Opex",
                affects: ["OperatingMargin", "Multiple"],
                notes: "Options: Low, Medium, High"
            ),
        ]
    }
    
    private func createCostcoAssumptions(horizon: Horizon) -> [AssumptionItem] {
        return [
            AssumptionItem(
                key: "membership_growth",
                title: "Membership Growth",
                subtitle: "Annual member count change",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 4.0,
                usesSlider: true,
                sliderMin: -2.0,
                sliderMax: 12.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue", "OperatingMargin"]
            ),
            AssumptionItem(
                key: "renewal_rate",
                title: "Renewal Rate",
                subtitle: "Member retention rate",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 92.0,
                usesSlider: true,
                sliderMin: 75.0,
                sliderMax: 98.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "exec_penetration",
                title: "Executive Membership Penetration",
                subtitle: "% of members with Exec tier",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 45.0,
                usesSlider: true,
                sliderMin: 25.0,
                sliderMax: 70.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue", "OperatingMargin"]
            ),
            AssumptionItem(
                key: "comp_sales_growth",
                title: "Comp Sales Growth",
                subtitle: "Same-warehouse sales growth",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 5.0,
                usesSlider: true,
                sliderMin: -5.0,
                sliderMax: 15.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "new_warehouse_openings",
                title: "New Warehouse Openings",
                subtitle: "Per year",
                section: .investmentAndCapex,
                valueType: .integer,
                baseValueDouble: Double(horizon.years * 5),
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 50.0,
                sliderStep: 1.0,
                sliderUnitLabel: "/yr",
                importance: 4,
                driverTag: "Capex",
                affects: ["Revenue", "Capex"]
            ),
        ]
    }
    
    private func createMcDonaldsAssumptions(horizon: Horizon) -> [AssumptionItem] {
        return [
            AssumptionItem(
                key: "same_store_sales",
                title: "Same-Store Sales Growth",
                subtitle: "Comp sales performance",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 4.0,
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 15.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 5,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "traffic_growth",
                title: "Traffic Growth",
                subtitle: "Customer visit change",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 2.0,
                usesSlider: true,
                sliderMin: -10.0,
                sliderMax: 10.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue"]
            ),
            AssumptionItem(
                key: "ticket_growth",
                title: "Average Ticket Growth",
                subtitle: "Price/mix impact",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: 3.0,
                usesSlider: true,
                sliderMin: -5.0,
                sliderMax: 12.0,
                sliderStep: 0.5,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue", "GrossMargin"]
            ),
            AssumptionItem(
                key: "digital_mix",
                title: "Digital Mix %",
                subtitle: "Digital/delivery sales penetration",
                section: .revenueDrivers,
                valueType: .percent,
                baseValueDouble: horizon.years > 5 ? 40.0 : 30.0,
                usesSlider: true,
                sliderMin: 10.0,
                sliderMax: 70.0,
                sliderStep: 1.0,
                sliderUnitLabel: "%",
                importance: 4,
                driverTag: "Revenue",
                affects: ["Revenue", "OperatingMargin"]
            ),
            AssumptionItem(
                key: "remodel_penetration",
                title: "Remodel Penetration %",
                subtitle: "% of stores modernized",
                section: .investmentAndCapex,
                valueType: .percent,
                baseValueDouble: Double(horizon.years) * 8.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 100.0,
                sliderStep: 5.0,
                sliderUnitLabel: "%",
                importance: 3,
                driverTag: "Capex",
                affects: ["Revenue", "OperatingMargin"]
            ),
            AssumptionItem(
                key: "franchisee_health_score",
                title: "Franchisee Health Score",
                subtitle: "Operator financial strength (0-100)",
                section: .narrativeRerating,
                valueType: .integer,
                baseValueDouble: 75.0,
                usesSlider: true,
                sliderMin: 0.0,
                sliderMax: 100.0,
                sliderStep: 5.0,
                sliderUnitLabel: "",
                importance: 3,
                driverTag: "Revenue",
                affects: ["Revenue", "OperatingMargin"]
            ),
        ]
    }
}
