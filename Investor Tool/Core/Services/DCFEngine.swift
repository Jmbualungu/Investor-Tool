//
//  DCFEngine.swift
//  Investor Tool
//
//  Pure DCF evaluation functions for scenario analysis and previews
//

import Foundation

// MARK: - Input/Output Structs

struct DCFInputs: Equatable {
    var revenueDrivers: [RevenueDriver]
    var operating: OperatingAssumptions
    var valuation: ValuationAssumptions
    var horizonYears: Int
    var currentPrice: Double
}

struct DCFOutputs: Equatable {
    var revenueIndex: Double
    var fcfMargin: Double
    var fcfIndex: Double
    var intrinsicValue: Double
    var upsidePercent: Double
    var cagrPercent: Double
    var terminalSharePercent: Double
}

// MARK: - Scenario Preset Enum

enum ScenarioPreset: String, CaseIterable, Identifiable {
    case bear
    case base
    case bull
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .bear: return "Bear"
        case .base: return "Base"
        case .bull: return "Bull"
        }
    }
}

// MARK: - DCF Engine

struct DCFEngine {
    
    // MARK: - Pure DCF Evaluation
    
    /// Evaluates DCF with the given inputs without mutating any state
    static func evaluateDCF(_ inputs: DCFInputs) -> DCFOutputs {
        // Calculate revenue index
        let revenueIndex = calculateRevenueIndex(drivers: inputs.revenueDrivers)
        
        // Calculate FCF margin
        let fcfMargin = calculateFCFMargin(operating: inputs.operating)
        
        // Calculate FCF index
        let fcfIndex = revenueIndex * fcfMargin
        let clampedFCFIndex = min(max(fcfIndex, 0.0), 120.0)
        
        // Calculate intrinsic value
        let intrinsicValue = calculateIntrinsicValue(
            fcfIndex: clampedFCFIndex,
            valuation: inputs.valuation
        )
        
        // Calculate upside
        let upsidePercent = calculateUpsidePercent(
            intrinsic: intrinsicValue,
            current: inputs.currentPrice
        )
        
        // Calculate CAGR
        let cagrPercent = calculateCAGR(
            intrinsic: intrinsicValue,
            current: inputs.currentPrice,
            years: inputs.horizonYears
        )
        
        // Terminal value share (approximation: ~65% typical)
        let terminalSharePercent = 65.0
        
        return DCFOutputs(
            revenueIndex: revenueIndex,
            fcfMargin: fcfMargin,
            fcfIndex: clampedFCFIndex,
            intrinsicValue: intrinsicValue,
            upsidePercent: upsidePercent,
            cagrPercent: cagrPercent,
            terminalSharePercent: terminalSharePercent
        )
    }
    
    // MARK: - Scenario Preview Generation
    
    /// Generates scenario inputs from a base case with deterministic adjustments
    static func scenarioInputs(
        from base: DCFInputs,
        preset: ScenarioPreset
    ) -> DCFInputs {
        var adjusted = base
        
        switch preset {
        case .base:
            // No changes for base
            return base
            
        case .bear:
            // Revenue drivers: -20% of range for percent, -0.05 for multiple
            adjusted.revenueDrivers = base.revenueDrivers.map { driver in
                var modified = driver
                let range = driver.max - driver.min
                
                switch driver.unit {
                case .percent:
                    // Move down by 20% of range
                    let adjustment = range * 0.20
                    modified.value = max(driver.min, driver.value - adjustment)
                case .multiple:
                    // Reduce by 0.05
                    modified.value = max(driver.min, driver.value - 0.05)
                case .number, .currency:
                    // Move down by 20% of range
                    let adjustment = range * 0.20
                    modified.value = max(driver.min, driver.value - adjustment)
                }
                
                return modified
            }
            
            // Operating: margin -3 pts, capex +1 pt, working cap +0.5 pt
            adjusted.operating.operatingMargin = max(5.0, base.operating.operatingMargin - 3.0)
            adjusted.operating.capexPercent = min(15.0, base.operating.capexPercent + 1.0)
            adjusted.operating.workingCapitalPercent = min(5.0, base.operating.workingCapitalPercent + 0.5)
            
            // Valuation: discount rate +1.0 pt, terminal growth -0.3 pt
            adjusted.valuation.discountRate = min(20.0, base.valuation.discountRate + 1.0)
            adjusted.valuation.terminalGrowth = max(1.0, base.valuation.terminalGrowth - 0.3)
            
            // Ensure terminal growth < discount rate - 0.5
            if adjusted.valuation.terminalGrowth >= adjusted.valuation.discountRate - 0.5 {
                adjusted.valuation.terminalGrowth = adjusted.valuation.discountRate - 0.6
            }
            
        case .bull:
            // Revenue drivers: +20% of range for percent, +0.05 for multiple
            adjusted.revenueDrivers = base.revenueDrivers.map { driver in
                var modified = driver
                let range = driver.max - driver.min
                
                switch driver.unit {
                case .percent:
                    // Move up by 20% of range
                    let adjustment = range * 0.20
                    modified.value = min(driver.max, driver.value + adjustment)
                case .multiple:
                    // Increase by 0.05
                    modified.value = min(driver.max, driver.value + 0.05)
                case .number, .currency:
                    // Move up by 20% of range
                    let adjustment = range * 0.20
                    modified.value = min(driver.max, driver.value + adjustment)
                }
                
                return modified
            }
            
            // Operating: margin +3 pts, capex -1 pt, working cap -0.5 pt
            adjusted.operating.operatingMargin = min(40.0, base.operating.operatingMargin + 3.0)
            adjusted.operating.capexPercent = max(1.0, base.operating.capexPercent - 1.0)
            adjusted.operating.workingCapitalPercent = max(0.0, base.operating.workingCapitalPercent - 0.5)
            
            // Valuation: discount rate -1.0 pt, terminal growth +0.3 pt
            adjusted.valuation.discountRate = max(5.0, base.valuation.discountRate - 1.0)
            adjusted.valuation.terminalGrowth = min(4.0, base.valuation.terminalGrowth + 0.3)
            
            // Ensure terminal growth < discount rate - 0.5
            if adjusted.valuation.terminalGrowth >= adjusted.valuation.discountRate - 0.5 {
                adjusted.valuation.terminalGrowth = adjusted.valuation.discountRate - 0.6
            }
        }
        
        return adjusted
    }
    
    // MARK: - Aggressiveness Score (0-100)
    
    /// Calculates an aggressiveness score based on current assumptions
    static func calculateAggressivenessScore(inputs: DCFInputs) -> Double {
        // Revenue aggressiveness: average position of drivers within their ranges
        var revenueSum = 0.0
        var revenueCount = 0
        
        for driver in inputs.revenueDrivers where driver.impactsRevenue {
            let range = driver.max - driver.min
            guard range > 0 else { continue }
            let position = (driver.value - driver.min) / range
            revenueSum += position
            revenueCount += 1
        }
        
        let revenueAvg = revenueCount > 0 ? revenueSum / Double(revenueCount) : 0.5
        
        // Margin aggressiveness: position within 5-40% band
        let marginRange = 40.0 - 5.0
        let marginPos = (inputs.operating.operatingMargin - 5.0) / marginRange
        let clampedMarginPos = min(max(marginPos, 0.0), 1.0)
        
        // Valuation aggressiveness: lower discount rate and higher terminal growth = more aggressive
        let discountRange = 20.0 - 5.0
        let discountPos = 1.0 - ((inputs.valuation.discountRate - 5.0) / discountRange) // Invert: lower = more aggressive
        let clampedDiscountPos = min(max(discountPos, 0.0), 1.0)
        
        let terminalRange = 4.0 - 1.0
        let terminalPos = (inputs.valuation.terminalGrowth - 1.0) / terminalRange
        let clampedTerminalPos = min(max(terminalPos, 0.0), 1.0)
        
        let valPos = (clampedDiscountPos + clampedTerminalPos) / 2.0
        
        // Combine: 45% revenue, 30% margin, 25% valuation
        let score = 100.0 * (0.45 * revenueAvg + 0.30 * clampedMarginPos + 0.25 * valPos)
        
        return min(max(score, 0.0), 100.0)
    }
    
    /// Returns a label and target for the given score and lens style
    static func confidenceLabel(
        score: Double,
        targetStyle: DCFInvestmentStyle
    ) -> (label: String, isAligned: Bool, targetScore: Double) {
        let label: String
        if score <= 33 {
            label = "Conservative"
        } else if score <= 66 {
            label = "Balanced"
        } else {
            label = "Aggressive"
        }
        
        // Target centers
        let targetScore: Double
        switch targetStyle {
        case .conservative:
            targetScore = 25.0
        case .base:
            targetScore = 50.0
        case .aggressive:
            targetScore = 75.0
        }
        
        // Aligned if within ±12 points of target
        let isAligned = abs(score - targetScore) <= 12.0
        
        return (label, isAligned, targetScore)
    }
    
    // MARK: - Sparkline Data Generation
    
    /// Generates deterministic sparkline data points for visualization
    static func generateSparklineData(
        for metric: SparklineMetric,
        inputs: DCFInputs
    ) -> [Double] {
        switch metric {
        case .revenue:
            return generateRevenueSparkline(inputs: inputs)
        case .intrinsic:
            return generateIntrinsicSparkline(inputs: inputs)
        }
    }
    
    private static func generateRevenueSparkline(inputs: DCFInputs) -> [Double] {
        let start = 100.0
        let end = inputs.revenueDrivers.isEmpty ? 100.0 : calculateRevenueIndex(drivers: inputs.revenueDrivers)
        let points = 6
        
        var data: [Double] = []
        for i in 0..<points {
            let progress = Double(i) / Double(points - 1)
            // Smooth interpolation with slight curve
            let value = start + (end - start) * pow(progress, 0.9)
            data.append(value)
        }
        
        return data
    }
    
    private static func generateIntrinsicSparkline(inputs: DCFInputs) -> [Double] {
        let outputs = evaluateDCF(inputs)
        let intrinsic = outputs.intrinsicValue
        let current = inputs.currentPrice
        
        // Create a trend from current price to intrinsic with curvature
        let points = 6
        var data: [Double] = []
        
        for i in 0..<points {
            let progress = Double(i) / Double(points - 1)
            // Add curvature based on discount rate (higher discount = more pronounced curve)
            let curveFactor = inputs.valuation.discountRate / 100.0
            let curvedProgress = pow(progress, 1.0 + curveFactor * 0.5)
            let value = current + (intrinsic - current) * curvedProgress
            data.append(value)
        }
        
        return data
    }
    
    // MARK: - Private Helpers
    
    private static func calculateRevenueIndex(drivers: [RevenueDriver]) -> Double {
        guard !drivers.isEmpty else { return 100.0 }
        
        var totalMultiplier: Double = 1.0
        
        for driver in drivers where driver.impactsRevenue {
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
                let range = driver.max - driver.min
                guard range > 0 else { continue }
                let normalizedValue = (driver.value - driver.min) / range
                multiplier = 0.8 + (normalizedValue * 0.4) // Range: 0.8 to 1.2
            }
            
            totalMultiplier *= multiplier
        }
        
        let result = 100.0 * totalMultiplier
        
        // Clamp to reasonable range
        return min(max(result, 30.0), 300.0)
    }
    
    private static func calculateFCFMargin(operating: OperatingAssumptions) -> Double {
        let fcfMargin = max(0, operating.operatingMargin * (1.0 - operating.taxRate / 100.0) - operating.capexPercent - operating.workingCapitalPercent) / 100.0
        
        // Clamp to reasonable range
        return min(max(fcfMargin, 0.0), 0.35)
    }
    
    private static func calculateIntrinsicValue(
        fcfIndex: Double,
        valuation: ValuationAssumptions
    ) -> Double {
        // Base scale factor
        let baseScale = 1.2
        
        // Simple PV factor approximation
        let pvFactor = 1.0 / max(0.01, valuation.discountRate / 100.0)
        
        // Terminal value factor
        let terminalFactor = 1.0 / max(0.01, (valuation.discountRate - valuation.terminalGrowth) / 100.0)
        
        // Intrinsic value = (PV of forecast period) + (PV of terminal value)
        let forecastPV = fcfIndex * baseScale * 0.9 * pvFactor
        let terminalPV = fcfIndex * baseScale * 0.6 * terminalFactor
        
        let intrinsic = forecastPV + terminalPV
        
        // Clamp to reasonable range
        return min(max(intrinsic, 20.0), 800.0)
    }
    
    private static func calculateUpsidePercent(intrinsic: Double, current: Double) -> Double {
        guard current > 0 else { return 0.0 }
        return ((intrinsic - current) / current) * 100.0
    }
    
    private static func calculateCAGR(intrinsic: Double, current: Double, years: Int) -> Double {
        guard current > 0 && years > 0 else { return 0.0 }
        
        let cagr = (pow(intrinsic / current, 1.0 / Double(years)) - 1.0) * 100.0
        
        // Clamp to reasonable range
        return min(max(cagr, -50.0), 50.0)
    }
}

// MARK: - Sparkline Metric

enum SparklineMetric {
    case revenue
    case intrinsic
}
