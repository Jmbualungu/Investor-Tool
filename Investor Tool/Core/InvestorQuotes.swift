//
//  InvestorQuotes.swift
//  Investor Tool
//
//  Curated investor quotes for onboarding
//

import Foundation

struct InvestorQuote: Identifiable {
    let id = UUID()
    let text: String
    let author: String
}

enum InvestorQuotes {
    static let onboarding: [InvestorQuote] = [
        InvestorQuote(
            text: "Risk comes from not knowing what you're doing.",
            author: "Warren Buffett"
        ),
        InvestorQuote(
            text: "The big money is not in the buying and selling, but in the waiting.",
            author: "Charlie Munger"
        ),
        InvestorQuote(
            text: "The most important thing is to keep the most important thing the most important thing.",
            author: "Howard Marks"
        )
    ]
}
