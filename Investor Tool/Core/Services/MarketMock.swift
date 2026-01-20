//
//  MarketMock.swift
//  Investor Tool
//
//  Deterministic mock market data generator
//

import Foundation

struct MarketMock {
    // MARK: - Deterministic Random Generator
    
    /// Simple LCG (Linear Congruential Generator) for deterministic randomness
    private struct DeterministicRandom {
        private var state: UInt64
        
        init(seed: Int) {
            self.state = UInt64(abs(seed))
        }
        
        mutating func next() -> Double {
            // LCG parameters (same as glibc)
            state = (state &* 1103515245 &+ 12345) & 0x7fffffff
            return Double(state) / Double(0x7fffffff)
        }
        
        mutating func nextInRange(_ range: ClosedRange<Double>) -> Double {
            let random = next()
            return range.lowerBound + random * (range.upperBound - range.lowerBound)
        }
    }
    
    // MARK: - Seed Generation
    
    /// Generate deterministic seed from ticker symbol
    static func seedFromSymbol(_ symbol: String) -> Int {
        var hash = 0
        for char in symbol.unicodeScalars {
            hash = (hash &* 31 &+ Int(char.value)) & 0x7fffffff
        }
        return abs(hash)
    }
    
    // MARK: - Current Price
    
    /// Generate deterministic current price for a symbol
    static func mockCurrentPrice(symbol: String) -> Double {
        let seed = seedFromSymbol(symbol)
        var rng = DeterministicRandom(seed: seed)
        
        // Base price between $50 and $500
        let basePrice = rng.nextInRange(50...500)
        
        // Round to 2 decimals
        return (basePrice * 100).rounded() / 100
    }
    
    // MARK: - Day Change
    
    /// Generate deterministic day change (absolute and percentage)
    static func mockDayChange(symbol: String) -> (absolute: Double, percent: Double) {
        let seed = seedFromSymbol(symbol)
        var rng = DeterministicRandom(seed: seed + 1000) // Different seed for variation
        
        let currentPrice = mockCurrentPrice(symbol: symbol)
        
        // Change between -5% and +5%
        let percentChange = rng.nextInRange(-5.0...5.0)
        let absoluteChange = currentPrice * (percentChange / 100.0)
        
        // Round to 2 decimals
        let roundedAbsolute = (absoluteChange * 100).rounded() / 100
        let roundedPercent = (percentChange * 100).rounded() / 100
        
        return (absolute: roundedAbsolute, percent: roundedPercent)
    }
    
    // MARK: - Price Series
    
    /// Generate deterministic price series for a symbol and time range
    static func mockPriceSeries(symbol: String, range: PriceRange) -> [Double] {
        let seed = seedFromSymbol(symbol)
        var rng = DeterministicRandom(seed: seed + Int(range.rawValue.hashValue))
        
        let currentPrice = mockCurrentPrice(symbol: symbol)
        let pointCount = range.pointCount
        
        var series: [Double] = []
        series.reserveCapacity(pointCount)
        
        // Start price (slightly different from current)
        let dayChange = mockDayChange(symbol: symbol)
        let startPrice = currentPrice - dayChange.absolute
        
        // Generate smooth price movement using random walk
        var price = startPrice
        let volatility = currentPrice * 0.02 // 2% volatility per step
        
        for i in 0..<pointCount {
            // Random walk with drift toward current price
            let drift = (currentPrice - price) / Double(pointCount - i)
            let noise = rng.nextInRange(-volatility...volatility)
            
            price += drift + noise
            
            // Ensure price stays positive and within reasonable bounds
            price = max(price, currentPrice * 0.5)
            price = min(price, currentPrice * 1.5)
            
            // Round to 2 decimals
            let roundedPrice = (price * 100).rounded() / 100
            series.append(roundedPrice)
        }
        
        // Ensure last point is exactly current price
        if !series.isEmpty {
            series[series.count - 1] = currentPrice
        }
        
        return series
    }
    
    // MARK: - Previous Close
    
    /// Get previous close price (for day change calculation)
    static func mockPreviousClose(symbol: String) -> Double {
        let current = mockCurrentPrice(symbol: symbol)
        let change = mockDayChange(symbol: symbol)
        return current - change.absolute
    }
    
    // MARK: - Intraday High/Low
    
    /// Generate mock intraday high/low
    static func mockDayHighLow(symbol: String) -> (high: Double, low: Double) {
        let current = mockCurrentPrice(symbol: symbol)
        let seed = seedFromSymbol(symbol)
        var rng = DeterministicRandom(seed: seed + 2000)
        
        let highPercent = rng.nextInRange(0.5...3.0)
        let lowPercent = rng.nextInRange(0.5...3.0)
        
        let high = current * (1 + highPercent / 100)
        let low = current * (1 - lowPercent / 100)
        
        return (
            high: (high * 100).rounded() / 100,
            low: (low * 100).rounded() / 100
        )
    }
}
