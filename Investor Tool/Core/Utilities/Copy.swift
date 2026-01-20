//
//  Copy.swift
//  Investor Tool
//
//  Centralized copy/microcopy strings for consistent messaging
//

import Foundation

enum Copy {
    // MARK: - Legal & Disclaimers
    
    static let notFinancialAdvice = "For educational use only. Not financial advice."
    static let educationalPurposes = "For educational purposes only. Not financial advice."
    
    // MARK: - Onboarding
    
    static let startForecasting = "Start forecasting →"
    static let continueCTA = "Continue →"
    
    // MARK: - Flow Navigation
    
    static let viewValuation = "View valuation →"
    static let setRevenueDrivers = "Set revenue drivers →"
    static let continueToOperating = "Continue to Operating Assumptions →"
    static let continueToValuation = "Continue to Valuation →"
    static let viewSensitivity = "View Sensitivity →"
    
    // MARK: - Empty States
    
    static let startWithTicker = "Start with a ticker"
    static let noMatchesFound = "No matches found"
    static let tryCompanyName = "Try searching by company name or symbol"
    static let setAssumptionsFirst = "Set assumptions first"
    static let returnToDrivers = "Return to drivers"
    static let unableToCompute = "Unable to compute valuation"
    static let resetAssumptions = "Reset assumptions"
    
    // MARK: - Actions
    
    static let resetToDefaults = "Reset to defaults"
    static let revertChanges = "Revert changes"
    static let applyScenario = "Apply scenario"
    static let viewChanges = "View changes"
    static let editAssumptions = "Edit assumptions"
    
    // MARK: - Marketing / Onboarding
    
    static let forecastWithClarity = "Forecast with clarity"
    static let assumptionsYouControl = "Assumptions you control"
    static let scenarioCompare = "Scenario compare"
    static let sensitivityAtAGlance = "Sensitivity at a glance"
    static let dataDrivenForecasting = "Data-driven forecasting"
    
    // MARK: - Messages
    
    static let searchPrompt = "Type ticker or company name"
    static let noResultsMessage = "No results match your search. Try another ticker or company name."
    static let driversEmptyMessage = "Configure revenue drivers to see your forecast."
    static let valuationEmptyMessage = "Complete all assumptions to view valuation results."
}
