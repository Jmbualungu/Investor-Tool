import Foundation
import Combine

enum SearchState: Equatable {
    case idle
    case searching
    case results(count: Int)
    case empty
}

final class BrowseViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var searchQuery = "" {
        didSet {
            performSearch()
        }
    }
    @Published var selectedTab: MarketTab = .macro
    @Published var selectedSector: Sector = .technology
    @Published var topMovers: [MoverItem] = []
    @Published var sectorTiles: [SectorTile] = []
    @Published var futuresContracts: [FutureContract] = []
    @Published var economicEvents: [EconomicEvent] = []
    @Published var searchResults: [TickerSearchResult] = []
    @Published var showSearchOverlay = false
    
    // Loading states
    @Published var isLoadingTopMovers = false
    @Published var isLoadingSectorData = false
    @Published var searchState: SearchState = .idle
    
    // Recent searches
    @Published var recentSearches: [String] = []
    
    // MARK: - Private Properties
    
    private let dataService = StubMarketDataService.shared
    private var searchTask: Task<Void, Never>?
    private let recentSearchesKey = "com.augur.browse.recentSearches"
    private let maxRecentSearches = 5
    
    // MARK: - Initialization
    
    init() {
        loadRecentSearches()
        loadData()
    }
    
    // MARK: - Public Methods
    
    func loadData() {
        isLoadingTopMovers = true
        
        Task { @MainActor in
            // Simulate async load
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            topMovers = dataService.getTopMovers()
            sectorTiles = dataService.getSectorTiles(for: selectedSector)
            futuresContracts = dataService.getFuturesContracts()
            economicEvents = dataService.getEconomicEvents()
            isLoadingTopMovers = false
        }
    }
    
    func updateSector(_ sector: Sector) {
        selectedSector = sector
        isLoadingSectorData = true
        
        // Simulate async load with delay for smooth animation
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
            sectorTiles = dataService.getSectorTiles(for: sector)
            isLoadingSectorData = false
        }
    }
    
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        showSearchOverlay = false
        searchState = .idle
    }
    
    func addToRecentSearches(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Remove if already exists
        recentSearches.removeAll { $0.uppercased() == trimmed.uppercased() }
        
        // Add to front
        recentSearches.insert(trimmed.uppercased(), at: 0)
        
        // Limit to max
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        // Persist
        saveRecentSearches()
    }
    
    // MARK: - Private Methods
    
    private func performSearch() {
        // Cancel any existing search task
        searchTask?.cancel()
        
        // Show/hide overlay based on query
        showSearchOverlay = !searchQuery.isEmpty
        
        // If query is empty, clear results immediately
        guard !searchQuery.isEmpty else {
            searchResults = []
            searchState = .idle
            return
        }
        
        // Set searching state
        searchState = .searching
        
        // Debounce search by 200ms
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                try await Task.sleep(nanoseconds: 200_000_000) // 200ms
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                // Perform search on main actor
                await MainActor.run {
                    let results = self.dataService.searchTickers(query: self.searchQuery)
                    self.searchResults = results
                    
                    if results.isEmpty {
                        self.searchState = .empty
                    } else {
                        self.searchState = .results(count: results.count)
                    }
                }
            } catch {
                // Task was cancelled or error occurred
                await MainActor.run {
                    self.searchState = .idle
                }
            }
        }
    }
    
    private func loadRecentSearches() {
        if let data = UserDefaults.standard.data(forKey: recentSearchesKey),
           let searches = try? JSONDecoder().decode([String].self, from: data) {
            recentSearches = searches
        }
    }
    
    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: recentSearchesKey)
        }
    }
}
