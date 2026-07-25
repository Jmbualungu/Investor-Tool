//
//  Quote.swift
//  Valtyde
//
//  A market quote — current price and the change over today's session.
//

import Foundation

/// A snapshot of a ticker's market price and how it has moved today.
///
/// Maps to Finnhub's `/quote` response fields:
/// `c` (current price), `d` (absolute change), `dp` (percent change).
struct Quote: Equatable {
    let symbol: String
    /// Current/last price.
    let price: Double
    /// Absolute price change over today's session.
    let change: Double
    /// Percent price change over today's session.
    let changePercent: Double

    /// True when the day's change is flat or positive.
    var isUp: Bool { changePercent >= 0 }
}
