//
//  CompanyContextProvider.swift
//  Investor Tool
//
//  Provider protocol for company context data
//  Future-proof: implement with Supabase, REST API, or mock data
//

import Foundation

// MARK: - Provider Protocol

protocol CompanyContextProviding {
    /// Fetches comprehensive company context for a given ticker
    /// - Parameter ticker: Stock ticker symbol (e.g., "AAPL")
    /// - Returns: CompanyContextModel with all context data
    /// - Throws: CompanyContextError if fetch fails
    func fetchCompanyContext(ticker: String) async throws -> CompanyContextModel
}

// MARK: - Error Types

enum CompanyContextError: Error, LocalizedError {
    case notFound
    case invalidTicker
    case internalError
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Company data not found for this ticker"
        case .invalidTicker:
            return "Invalid ticker symbol"
        case .internalError:
            return "An internal error occurred"
        case .networkError:
            return "Network request failed"
        }
    }
}
