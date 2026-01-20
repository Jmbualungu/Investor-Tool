import Foundation
import Combine

final class WatchlistStore: ObservableObject {
    @Published var watchlist: Set<String> = []
    @Published var recentlyAdded: String? = nil
    @Published var recentlyRemoved: String? = nil
    
    private let userDefaultsKey = "com.augur.watchlist"
    private let maxWatchlistSize = 100
    
    init() {
        loadFromUserDefaults()
    }
    
    func add(ticker: String, animated: Bool = true) {
        let normalizedTicker = ticker.uppercased()
        
        // Check limit
        guard watchlist.count < maxWatchlistSize else {
            return
        }
        
        watchlist.insert(normalizedTicker)
        
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
        watchlist.remove(normalizedTicker)
        
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
        return watchlist.contains(normalizedTicker)
    }
    
    func toggle(ticker: String) {
        if contains(ticker: ticker) {
            remove(ticker: ticker)
        } else {
            add(ticker: ticker)
        }
    }
    
    var count: Int {
        watchlist.count
    }
    
    var isFull: Bool {
        watchlist.count >= maxWatchlistSize
    }
    
    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let tickers = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return
        }
        watchlist = tickers
    }
    
    private func saveToUserDefaults() {
        guard let data = try? JSONEncoder().encode(watchlist) else {
            return
        }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}
