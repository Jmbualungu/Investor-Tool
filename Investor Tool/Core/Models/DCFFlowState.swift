//
//  DCFFlowState.swift
//  Investor Tool
//
//  State management for DCF Setup Flow
//

import Foundation
import SwiftUI
import Combine

@MainActor
class DCFFlowState: ObservableObject {
    // Selected ticker
    @Published var selectedTicker: DCFTicker?
    
    // Investment lens
    @Published var investmentLens: InvestmentLens = InvestmentLens()
    
    // Revenue drivers
    @Published var revenueDrivers: [RevenueDriver] = []
    
    // Operating assumptions
    @Published var operatingAssumptions: OperatingAssumptions = OperatingAssumptions()
    
    // Valuation assumptions
    @Published var valuationAssumptions: ValuationAssumptions = ValuationAssumptions()
    
    // Watchlist functionality
    @Published var watchlistSymbols: Set<String> = []
    
    // Preset snapshots (for drift detection)
    private var revenueDriverBaseSnapshot: [UUID: Double] = [:]
    private var operatingBaseSnapshot: OperatingAssumptions = OperatingAssumptions()
    private var valuationBaseSnapshot: ValuationAssumptions = ValuationAssumptions()
    
    // MARK: - Computed Properties
    
    var derivedTopLineRevenue: Double {
        guard !revenueDrivers.isEmpty else { return 100.0 }
        
        var totalMultiplier: Double = 1.0
        
        for driver in revenueDrivers where driver.impactsRevenue {
            let multiplier: Double
            
            switch driver.unit {
            case .percent:
                // For percent: value of 5% = multiplier of 1.05
                multiplier = 1.0 + (driver.value / 100.0)
            case .multiple:
                // For multiple: value is already a multiplier
                multiplier = driver.value
            case .number, .currency:
                // Normalize to a multiplier using min/max scaling
                let normalizedValue = (driver.value - driver.min) / (driver.max - driver.min)
                multiplier = 0.8 + (normalizedValue * 0.4) // Range: 0.8 to 1.2
            }
            
            totalMultiplier *= multiplier
        }
        
        let result = 100.0 * totalMultiplier
        
        // Clamp to reasonable range
        return min(max(result, 30.0), 300.0)
    }
    
    var derivedFreeCashFlowIndex: Double {
        let revenueIndex = derivedTopLineRevenue
        
        // Calculate FCF margin
        var fcfMarginApprox = max(0, operatingAssumptions.operatingMargin * (1.0 - operatingAssumptions.taxRate / 100.0) - operatingAssumptions.capexPercent - operatingAssumptions.workingCapitalPercent) / 100.0
        
        // Clamp to reasonable range
        fcfMarginApprox = min(max(fcfMarginApprox, 0.0), 0.35)
        
        let fcfIndex = revenueIndex * fcfMarginApprox
        
        // Clamp FCF index
        return min(max(fcfIndex, 0.0), 120.0)
    }
    
    var baselineCurrentPrice: Double {
        // Use actual price if available
        if let price = selectedTicker?.currentPrice {
            return price
        }
        
        // Generate deterministic mock price based on symbol hash
        guard let symbol = selectedTicker?.symbol else { return 150.0 }
        
        // Use symbol hash for consistent but varied prices
        let hash = abs(symbol.hashValue)
        let priceVariation = Double(hash % 150) + 100 // Range: 100-250
        return priceVariation
    }
    
    var derivedIntrinsicValue: Double {
        let fcfIndex = derivedFreeCashFlowIndex
        let discountRate = valuationAssumptions.discountRate
        let terminalGrowth = valuationAssumptions.terminalGrowth
        
        // Base scale factor
        let baseScale = 1.2
        
        // Simple PV factor approximation
        let pvFactor = 1.0 / max(0.01, discountRate / 100.0)
        
        // Terminal value factor
        let terminalFactor = 1.0 / max(0.01, (discountRate - terminalGrowth) / 100.0)
        
        // Intrinsic value = (PV of forecast period) + (PV of terminal value)
        let forecastPV = fcfIndex * baseScale * 0.9 * pvFactor
        let terminalPV = fcfIndex * baseScale * 0.6 * terminalFactor
        
        let intrinsic = forecastPV + terminalPV
        
        // Clamp to reasonable range
        return min(max(intrinsic, 20.0), 800.0)
    }
    
    var derivedUpsidePercent: Double {
        let intrinsic = derivedIntrinsicValue
        let current = baselineCurrentPrice
        
        guard current > 0 else { return 0.0 }
        
        return ((intrinsic - current) / current) * 100.0
    }
    
    var derivedCAGR: Double {
        let intrinsic = derivedIntrinsicValue
        let current = baselineCurrentPrice
        let years = Double(investmentLens.horizon.years)
        
        guard current > 0 && years > 0 else { return 0.0 }
        
        let cagr = (pow(intrinsic / current, 1.0 / years) - 1.0) * 100.0
        
        // Clamp to reasonable range
        return min(max(cagr, -50.0), 50.0)
    }
    
    // MARK: - Watchlist Management
    
    func toggleWatchlist(symbol: String) {
        if watchlistSymbols.contains(symbol) {
            watchlistSymbols.remove(symbol)
        } else {
            watchlistSymbols.insert(symbol)
        }
    }
    
    func isInWatchlist(symbol: String) -> Bool {
        watchlistSymbols.contains(symbol)
    }
    
    // MARK: - Preset Management
    
    func applyPreset(_ preset: PresetScenario, animated: Bool = true) {
        switch preset {
        case .consensus:
            applyConsensusPreset()
        case .bear:
            applyBearPreset()
        case .base:
            restoreBasePreset()
        case .bull:
            applyBullPreset()
        }
    }
    
    func saveBaseSnapshot() {
        revenueDriverBaseSnapshot = Dictionary(uniqueKeysWithValues: revenueDrivers.map { ($0.id, $0.value) })
    }
    
    func saveValuationSnapshot() {
        valuationBaseSnapshot = valuationAssumptions
    }
    
    private func applyConsensusPreset() {
        for i in revenueDrivers.indices {
            let driver = revenueDrivers[i]
            // Midpoint
            revenueDrivers[i] = RevenueDriver(
                id: driver.id,
                title: driver.title,
                subtitle: driver.subtitle,
                unit: driver.unit,
                value: (driver.min + driver.max) / 2.0,
                min: driver.min,
                max: driver.max,
                step: driver.step,
                impactsRevenue: driver.impactsRevenue
            )
        }
        saveBaseSnapshot()
    }
    
    private func applyBearPreset() {
        for i in revenueDrivers.indices {
            let driver = revenueDrivers[i]
            // Lower quartile
            let bearValue = driver.min + (driver.max - driver.min) * 0.25
            revenueDrivers[i] = RevenueDriver(
                id: driver.id,
                title: driver.title,
                subtitle: driver.subtitle,
                unit: driver.unit,
                value: bearValue,
                min: driver.min,
                max: driver.max,
                step: driver.step,
                impactsRevenue: driver.impactsRevenue
            )
        }
    }
    
    private func applyBullPreset() {
        for i in revenueDrivers.indices {
            let driver = revenueDrivers[i]
            // Upper quartile
            let bullValue = driver.min + (driver.max - driver.min) * 0.75
            revenueDrivers[i] = RevenueDriver(
                id: driver.id,
                title: driver.title,
                subtitle: driver.subtitle,
                unit: driver.unit,
                value: bullValue,
                min: driver.min,
                max: driver.max,
                step: driver.step,
                impactsRevenue: driver.impactsRevenue
            )
        }
    }
    
    private func restoreBasePreset() {
        guard !revenueDriverBaseSnapshot.isEmpty else {
            // If no snapshot, apply consensus
            applyConsensusPreset()
            return
        }
        
        for i in revenueDrivers.indices {
            if let savedValue = revenueDriverBaseSnapshot[revenueDrivers[i].id] {
                let driver = revenueDrivers[i]
                revenueDrivers[i] = RevenueDriver(
                    id: driver.id,
                    title: driver.title,
                    subtitle: driver.subtitle,
                    unit: driver.unit,
                    value: savedValue,
                    min: driver.min,
                    max: driver.max,
                    step: driver.step,
                    impactsRevenue: driver.impactsRevenue
                )
            }
        }
    }
    
    // MARK: - Operating Assumptions Presets
    
    func applyOperatingPreset(_ preset: PresetScenario) {
        switch preset {
        case .consensus, .base:
            operatingAssumptions = operatingBaseSnapshot
        case .bear:
            operatingAssumptions = OperatingAssumptions(
                grossMargin: 48.0,
                operatingMargin: 16.0,
                taxRate: 24.0,
                capexPercent: 6.0,
                workingCapitalPercent: 2.0
            )
        case .bull:
            operatingAssumptions = OperatingAssumptions(
                grossMargin: 62.0,
                operatingMargin: 28.0,
                taxRate: 18.0,
                capexPercent: 2.5,
                workingCapitalPercent: 0.5
            )
        }
    }
    
    func saveOperatingSnapshot() {
        operatingBaseSnapshot = operatingAssumptions
    }
    
    func resetOperatingToDefaults() {
        operatingAssumptions = OperatingAssumptions()
        saveOperatingSnapshot()
    }
    
    // MARK: - Revenue Driver Generation
    
    func generateRevenueDrivers() {
        guard let ticker = selectedTicker else { return }
        
        revenueDrivers = TickerRepository.shared.generateDefaultRevenueDrivers(
            for: ticker.businessModel,
            sector: ticker.sector
        )
        
        // Save initial state as base
        saveBaseSnapshot()
        
        // Initialize operating snapshot
        saveOperatingSnapshot()
    }
    
    // MARK: - Navigation Helpers
    
    func popToRevenueDrivers(path: Binding<[AppRoute]>) {
        // Find the index of .dcfRevenueDrivers in the path
        if let index = path.wrappedValue.firstIndex(where: { route in
            if case .dcfRevenueDrivers = route {
                return true
            }
            return false
        }) {
            // Remove all routes after RevenueDrivers to navigate back
            path.wrappedValue = Array(path.wrappedValue.prefix(through: index))
        }
    }
    
    func popToOperatingAssumptions(path: Binding<[AppRoute]>) {
        if let index = path.wrappedValue.firstIndex(where: { route in
            if case .dcfOperatingAssumptions = route {
                return true
            }
            return false
        }) {
            path.wrappedValue = Array(path.wrappedValue.prefix(through: index))
        }
    }
    
    func popToValuationAssumptions(path: Binding<[AppRoute]>) {
        if let index = path.wrappedValue.firstIndex(where: { route in
            if case .dcfValuationAssumptions = route {
                return true
            }
            return false
        }) {
            path.wrappedValue = Array(path.wrappedValue.prefix(through: index))
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        selectedTicker = nil
        investmentLens = InvestmentLens()
        revenueDrivers = []
        revenueDriverBaseSnapshot = [:]
        operatingBaseSnapshot = OperatingAssumptions()
        valuationBaseSnapshot = ValuationAssumptions()
    }
    
    func resetAllToDefaults() {
        selectedTicker = nil
        watchlistSymbols = []
        
        // Reset lens to defaults
        investmentLens = InvestmentLens()
        
        // Reset assumptions to defaults
        revenueDrivers = []
        operatingAssumptions = OperatingAssumptions()
        valuationAssumptions = ValuationAssumptions()
        
        // Reset snapshots too
        revenueDriverBaseSnapshot = [:]
        operatingBaseSnapshot = OperatingAssumptions()
        valuationBaseSnapshot = ValuationAssumptions()
    }
    
    // MARK: - Drift Detection (Premium Feature)
    
    func isRevenueDriverDrifted(driverID: UUID, tolerance: Double = 0.0001) -> Bool {
        guard let baseValue = revenueDriverBaseSnapshot[driverID],
              let currentDriver = revenueDrivers.first(where: { $0.id == driverID }) else {
            return false
        }
        
        return abs(currentDriver.value - baseValue) > tolerance
    }
    
    func isAnyRevenueDriverDrifted(tolerance: Double = 0.0001) -> Bool {
        for driver in revenueDrivers {
            if isRevenueDriverDrifted(driverID: driver.id, tolerance: tolerance) {
                return true
            }
        }
        return false
    }
    
    func isOperatingDrifted(tolerance: Double = 0.0001) -> Bool {
        let current = operatingAssumptions
        let base = operatingBaseSnapshot
        
        return abs(current.grossMargin - base.grossMargin) > tolerance ||
               abs(current.operatingMargin - base.operatingMargin) > tolerance ||
               abs(current.taxRate - base.taxRate) > tolerance ||
               abs(current.capexPercent - base.capexPercent) > tolerance ||
               abs(current.workingCapitalPercent - base.workingCapitalPercent) > tolerance
    }
    
    func isValuationDrifted(tolerance: Double = 0.0001) -> Bool {
        let current = valuationAssumptions
        let base = valuationBaseSnapshot
        
        return abs(current.discountRate - base.discountRate) > tolerance ||
               abs(current.terminalGrowth - base.terminalGrowth) > tolerance ||
               current.terminalMethod != base.terminalMethod
    }
    
    func hasAnyDrift() -> Bool {
        return isAnyRevenueDriverDrifted() || isOperatingDrifted() || isValuationDrifted()
    }
    
    // MARK: - Change Tracking (Premium Feature)
    
    func revenueChanges() -> [ChangeItem] {
        var changes: [ChangeItem] = []
        
        for driver in revenueDrivers {
            if isRevenueDriverDrifted(driverID: driver.id) {
                if let baseValue = revenueDriverBaseSnapshot[driver.id] {
                    changes.append(ChangeItem(
                        label: driver.title,
                        baseValue: driver.unit.format(baseValue),
                        currentValue: driver.unit.format(driver.value)
                    ))
                }
            }
        }
        
        return changes
    }
    
    func operatingChanges() -> [ChangeItem] {
        var changes: [ChangeItem] = []
        let current = operatingAssumptions
        let base = operatingBaseSnapshot
        
        if abs(current.grossMargin - base.grossMargin) > 0.0001 {
            changes.append(ChangeItem(
                label: "Gross Margin",
                baseValue: String(format: "%.1f%%", base.grossMargin),
                currentValue: String(format: "%.1f%%", current.grossMargin)
            ))
        }
        
        if abs(current.operatingMargin - base.operatingMargin) > 0.0001 {
            changes.append(ChangeItem(
                label: "Operating Margin",
                baseValue: String(format: "%.1f%%", base.operatingMargin),
                currentValue: String(format: "%.1f%%", current.operatingMargin)
            ))
        }
        
        if abs(current.taxRate - base.taxRate) > 0.0001 {
            changes.append(ChangeItem(
                label: "Tax Rate",
                baseValue: String(format: "%.1f%%", base.taxRate),
                currentValue: String(format: "%.1f%%", current.taxRate)
            ))
        }
        
        if abs(current.capexPercent - base.capexPercent) > 0.0001 {
            changes.append(ChangeItem(
                label: "CapEx %",
                baseValue: String(format: "%.1f%%", base.capexPercent),
                currentValue: String(format: "%.1f%%", current.capexPercent)
            ))
        }
        
        if abs(current.workingCapitalPercent - base.workingCapitalPercent) > 0.0001 {
            changes.append(ChangeItem(
                label: "Working Capital %",
                baseValue: String(format: "%.1f%%", base.workingCapitalPercent),
                currentValue: String(format: "%.1f%%", current.workingCapitalPercent)
            ))
        }
        
        return changes
    }
    
    func valuationChanges() -> [ChangeItem] {
        var changes: [ChangeItem] = []
        let current = valuationAssumptions
        let base = valuationBaseSnapshot
        
        if abs(current.discountRate - base.discountRate) > 0.0001 {
            changes.append(ChangeItem(
                label: "Discount Rate",
                baseValue: String(format: "%.1f%%", base.discountRate),
                currentValue: String(format: "%.1f%%", current.discountRate)
            ))
        }
        
        if abs(current.terminalGrowth - base.terminalGrowth) > 0.0001 {
            changes.append(ChangeItem(
                label: "Terminal Growth",
                baseValue: String(format: "%.1f%%", base.terminalGrowth),
                currentValue: String(format: "%.1f%%", current.terminalGrowth)
            ))
        }
        
        if current.terminalMethod != base.terminalMethod {
            changes.append(ChangeItem(
                label: "Terminal Method",
                baseValue: base.terminalMethod.rawValue,
                currentValue: current.terminalMethod.rawValue
            ))
        }
        
        return changes
    }
    
    // MARK: - Revert Functions (Premium Feature)
    
    func revertRevenueDriversToBase() {
        restoreBasePreset()
    }
    
    func revertOperatingToBase() {
        operatingAssumptions = operatingBaseSnapshot
    }
    
    func revertValuationToBase() {
        valuationAssumptions = valuationBaseSnapshot
    }
    
    func revertAllToBase() {
        revertRevenueDriversToBase()
        revertOperatingToBase()
        revertValuationToBase()
    }
    
    // MARK: - Scenario Preview Helpers (Pure Functions)
    
    /// Returns DCF inputs from current state (for scenario preview)
    func getCurrentInputs() -> DCFInputs {
        return DCFInputs(
            revenueDrivers: revenueDrivers,
            operating: operatingAssumptions,
            valuation: valuationAssumptions,
            horizonYears: investmentLens.horizon.years,
            currentPrice: baselineCurrentPrice
        )
    }
    
    /// Returns DCF inputs from base snapshots (for scenario preview)
    func getBaseInputs() -> DCFInputs {
        // Reconstruct base revenue drivers from snapshot
        let baseRevenueDrivers = revenueDrivers.map { driver in
            if let baseValue = revenueDriverBaseSnapshot[driver.id] {
                return RevenueDriver(
                    id: driver.id,
                    title: driver.title,
                    subtitle: driver.subtitle,
                    unit: driver.unit,
                    value: baseValue,
                    min: driver.min,
                    max: driver.max,
                    step: driver.step,
                    impactsRevenue: driver.impactsRevenue
                )
            }
            return driver
        }
        
        return DCFInputs(
            revenueDrivers: baseRevenueDrivers,
            operating: operatingBaseSnapshot,
            valuation: valuationBaseSnapshot,
            horizonYears: investmentLens.horizon.years,
            currentPrice: baselineCurrentPrice
        )
    }
    
    /// Apply a scenario preset to the live state (mutates)
    func applyScenario(_ preset: ScenarioPreset) {
        let baseInputs = getBaseInputs()
        let scenarioInputs = DCFEngine.scenarioInputs(from: baseInputs, preset: preset)
        
        // Update live state
        revenueDrivers = scenarioInputs.revenueDrivers
        operatingAssumptions = scenarioInputs.operating
        valuationAssumptions = scenarioInputs.valuation
        
        // If applying base, update snapshots
        if preset == .base {
            saveBaseSnapshot()
            saveOperatingSnapshot()
            saveValuationSnapshot()
        }
    }
}
