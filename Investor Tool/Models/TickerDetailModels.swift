import Foundation

enum ChartTimeframe: String, CaseIterable, Identifiable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case ytd = "YTD"
    case oneYear = "1Y"
    case fiveYears = "5Y"

    var id: String { rawValue }
}

struct PeerHolding: Identifiable {
    let id = UUID()
    let companyName: String
    let ticker: String
    let percentChange: Double
}

struct EarningsPoint: Identifiable {
    let id = UUID()
    let quarter: String
    let estimatedEPS: Double
    let actualEPS: Double?
}

struct ShareholderQA: Identifiable {
    let id = UUID()
    let dateLabel: String
    let title: String
    let questionsAnswered: Int
}

struct ShortInterestPoint: Identifiable {
    let id = UUID()
    let label: String
    let shortInterestPercent: Double
    let daysToCover: Double
}

struct ResearchReportModel {
    let provider: String
    let updatedDate: String
    let rating: Int
    let ratingMax: Int
    let moat: String
    let fairValue: String
}

struct StatItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

struct NewsItem: Identifiable {
    let id = UUID()
    let source: String
    let timeAgo: String
    let headline: String
    let percentChange: Double?
}

struct AnalystRatingsModel {
    let totalRatings: Int
    let buyPercent: Double
    let holdPercent: Double
    let sellPercent: Double
    let bullsSay: String
}

enum TradingTrendOption: String, CaseIterable, Identifiable {
    case robinhood = "Robinhood"
    case hedgeFunds = "Hedge funds"
    case insiders = "Insiders"

    var id: String { rawValue }
}

// MARK: - New Enhanced Models for Robinhood-style detail page

struct CompanyProfile {
    let description: String
    let ceo: String
    let employees: Int
    let foundedYear: Int
    let headquarters: String
}

struct KeyStats {
    let volume: Double?
    let open: Double?
    let high: Double?
    let low: Double?
    let avgVolume: Double?
    let marketCap: Double?
    let week52High: Double?
    let week52Low: Double?
    let peRatio: Double?
    let dividendYield: Double?
    let shortInventory: Double?
    let borrowRate: Double?
    let overnightVolume: Double?
}

struct NewsItemDetail: Identifiable {
    let id: UUID
    let title: String
    let source: String
    let publishedAt: Date
    let url: String?
    let summary: String
    let priceImpact: Double?
    
    init(
        id: UUID = UUID(),
        title: String,
        source: String,
        publishedAt: Date,
        url: String? = nil,
        summary: String,
        priceImpact: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.source = source
        self.publishedAt = publishedAt
        self.url = url
        self.summary = summary
        self.priceImpact = priceImpact
    }
}

enum AnalystRating: String {
    case strongBuy = "Strong Buy"
    case buy = "Buy"
    case hold = "Hold"
    case sell = "Sell"
    case strongSell = "Strong Sell"
}

struct AnalystConsensus {
    let strongBuy: Int
    let buy: Int
    let hold: Int
    let sell: Int
    let strongSell: Int
    let avgPriceTarget: Double?
    let highPriceTarget: Double?
    let lowPriceTarget: Double?
    
    var total: Int {
        strongBuy + buy + hold + sell + strongSell
    }
    
    var strongBuyPercent: Double {
        total > 0 ? (Double(strongBuy) / Double(total)) * 100 : 0
    }
    
    var buyPercent: Double {
        total > 0 ? (Double(buy) / Double(total)) * 100 : 0
    }
    
    var holdPercent: Double {
        total > 0 ? (Double(hold) / Double(total)) * 100 : 0
    }
    
    var sellPercent: Double {
        total > 0 ? (Double(sell) / Double(total)) * 100 : 0
    }
    
    var strongSellPercent: Double {
        total > 0 ? (Double(strongSell) / Double(total)) * 100 : 0
    }
}

struct AnalystAction: Identifiable {
    let id: UUID
    let firm: String
    let rating: AnalystRating
    let date: Date
    let priceTarget: Double?
    let summary: String
    
    init(
        id: UUID = UUID(),
        firm: String,
        rating: AnalystRating,
        date: Date,
        priceTarget: Double? = nil,
        summary: String
    ) {
        self.id = id
        self.firm = firm
        self.rating = rating
        self.date = date
        self.priceTarget = priceTarget
        self.summary = summary
    }
}

struct TickerDetailData {
    let symbol: String
    let companyName: String
    let price: Double
    let changeToday: Double
    let changeTodayPercent: Double
    let profile: CompanyProfile
    let keyStats: KeyStats
    let news: [NewsItemDetail]
    let analystConsensus: AnalystConsensus
    let analystActions: [AnalystAction]
}
