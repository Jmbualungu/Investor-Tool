import Foundation

/// Lightweight illustrative forecast calculator for template preview
/// NOTE: This is NOT a full valuation engine - it's a simplified model to demonstrate
/// how assumptions affect outcomes. Will be replaced with proper DCF/projection model later.
struct ForecastPreviewEngine {
    
    /// Preview result showing illustrative impacts
    struct PreviewResult {
        var revenueIndex: Double // Starting at 100
        var fcfMarginEstimate: Double // As percentage
        var fcfIndex: Double // Starting at 100
        var shareCountChange: Double // As percentage
        var impliedSharePrice: Double
        var impliedTotalReturn: Double // As percentage
        var keyDrivers: [String] // Top 3 assumptions affecting valuation
    }
    
    /// Calculate preview using template assumptions
    /// Model: Simple compound growth + multiple-based terminal value
    static func calculatePreview(template: EntityAssumptionsTemplate) -> PreviewResult {
        // Extract key assumptions
        let revenueGrowth = getAssumptionValue(template: template, key: "revenue_growth") ?? 8.0
        let operatingMargin = getAssumptionValue(template: template, key: "operating_margin") ?? 18.0
        let fcfConversionRate = getAssumptionValue(template: template, key: "fcf_conversion_rate") ?? 75.0
        let buybackPct = getAssumptionValue(template: template, key: "buyback_pct_share_count") ?? 2.0
        let sbcDilution = getAssumptionValue(template: template, key: "sbc_dilution") ?? 1.5
        let startingPrice = getAssumptionValue(template: template, key: "starting_share_price") ?? 100.0
        let terminalPE = getAssumptionValue(template: template, key: "terminal_pe_multiple") ?? 18.0
        
        let years = Double(template.horizon.years)
        
        // 1. Revenue Index: compound growth over horizon
        // Formula: 100 * (1 + growth_rate)^years
        let revenueIndex = 100.0 * pow(1.0 + revenueGrowth / 100.0, years)
        
        // 2. FCF Margin Estimate: Operating Margin * FCF Conversion Rate
        // This is simplified - real model would subtract taxes, capex, etc.
        let fcfMarginEstimate = (operatingMargin / 100.0) * (fcfConversionRate / 100.0) * 100.0
        
        // 3. FCF Index: Revenue Index * FCF Margin (normalized)
        // Starting at 100, grows with revenue and margin improvement
        let fcfIndex = revenueIndex * (fcfMarginEstimate / (18.0 * 0.75)) // Normalized to base assumptions
        
        // 4. Share Count Change: compound net buybacks - dilution
        // Net buyback rate per year
        let netBuybackRate = (buybackPct - sbcDilution) / 100.0
        let shareCountChangePct = (pow(1.0 + netBuybackRate, years) - 1.0) * 100.0
        
        // 5. Implied Share Price (Illustrative)
        // Model: (FCF Index / Share Count Index) * terminal multiple scalar
        // This is a simplified "FCF per share grows, then apply multiple" approach
        let shareCountIndex = 100.0 * pow(1.0 + netBuybackRate, years)
        let fcfPerShareIndex = fcfIndex / (shareCountIndex / 100.0)
        
        // Terminal value: FCF per share index * multiple * base price scalar
        // Normalized so that base case ~= reasonable return
        let impliedSharePrice = (fcfPerShareIndex / 100.0) * (terminalPE / 18.0) * startingPrice
        
        // 6. Implied Total Return
        let impliedTotalReturn = ((impliedSharePrice - startingPrice) / startingPrice) * 100.0
        
        // 7. Key Drivers: Find top 3 assumptions by importance that affect valuation/FCF
        let keyDrivers = findKeyDrivers(template: template)
        
        return PreviewResult(
            revenueIndex: revenueIndex,
            fcfMarginEstimate: fcfMarginEstimate,
            fcfIndex: fcfIndex,
            shareCountChange: shareCountChangePct,
            impliedSharePrice: impliedSharePrice,
            impliedTotalReturn: impliedTotalReturn,
            keyDrivers: keyDrivers
        )
    }
    
    /// Get assumption value by key
    private static func getAssumptionValue(template: EntityAssumptionsTemplate, key: String) -> Double? {
        return template.items.first(where: { $0.key == key })?.baseValueDouble
    }
    
    /// Find top 3 most important assumptions affecting valuation/FCF
    private static func findKeyDrivers(template: EntityAssumptionsTemplate) -> [String] {
        let relevantItems = template.items.filter { item in
            item.affects.contains(where: { ["FCF", "Valuation", "SharePrice", "Multiple"].contains($0) })
        }
        
        let sorted = relevantItems.sorted { $0.importance > $1.importance }
        return Array(sorted.prefix(3).map { $0.title })
    }
}
