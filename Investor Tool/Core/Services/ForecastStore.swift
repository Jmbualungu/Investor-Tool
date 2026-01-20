import Foundation
import Combine

final class ForecastStore: ObservableObject {
    @Published var savedTickers: Set<String> = []
    @Published var recentlyAdded: String? = nil
    @Published var recentlyRemoved: String? = nil
    
    private let userDefaultsKey = "com.augur.forecast.savedTickers"
    private let maxForecastSize = 50
    
    init() {
        loadFromUserDefaults()
    }
    
    func add(ticker: String, animated: Bool = true) {
        let normalizedTicker = ticker.uppercased()
        
        // Check limit
        guard savedTickers.count < maxForecastSize else {
            return
        }
        
        savedTickers.insert(normalizedTicker)
        
        if animated {
            recentlyAdded = normalizedTicker
            // Clear after animation
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                self.recentlyAdded = nil
            }
        }
        
        saveToUserDefaults()
    }
    
    func remove(ticker: String, animated: Bool = true) {
        let normalizedTicker = ticker.uppercased()
        savedTickers.remove(normalizedTicker)
        
        if animated {
            recentlyRemoved = normalizedTicker
            // Clear after animation
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
                self.recentlyRemoved = nil
            }
        }
        
        saveToUserDefaults()
    }
    
    func contains(ticker: String) -> Bool {
        let normalizedTicker = ticker.uppercased()
        return savedTickers.contains(normalizedTicker)
    }
    
    func toggle(ticker: String) {
        if contains(ticker: ticker) {
            remove(ticker: ticker)
        } else {
            add(ticker: ticker)
        }
    }
    
    var count: Int {
        savedTickers.count
    }
    
    var isFull: Bool {
        savedTickers.count >= maxForecastSize
    }
    
    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let tickers = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return
        }
        savedTickers = tickers
    }
    
    private func saveToUserDefaults() {
        guard let data = try? JSONEncoder().encode(savedTickers) else {
            return
        }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}
