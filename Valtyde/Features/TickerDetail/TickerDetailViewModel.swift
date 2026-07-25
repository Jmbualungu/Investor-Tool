import Foundation
import Combine

@MainActor
final class TickerDetailViewModel: ObservableObject {
    @Published var ticker: String
    @Published var companyName: String
    @Published var price: Double
    @Published var changeToday: Double
    @Published var changeTodayPercent: Double
    @Published var changeAfterHours: Double
    @Published var changeAfterHoursPercent: Double
    @Published var selectedTimeframe: ChartTimeframe = .oneDay
    @Published var tradingTrendSelection: TradingTrendOption = .robinhood
    
    // New properties for enhanced data
    @Published var isLoading: Bool = false
    @Published var tickerDetailData: TickerDetailData?
    @Published var errorMessage: String?

    // Existing properties for sections that stay
    @Published var relatedLists: [String] = []
    @Published var peopleAlsoOwn: [PeerHolding] = []
    @Published var earnings: [EarningsPoint] = []
    @Published var qas: [ShareholderQA] = []
    @Published var shortInterestSeries: [ShortInterestPoint] = []
    @Published var researchReport: ResearchReportModel
    @Published var stats: [StatItem] = []
    @Published var news: [NewsItem] = []
    @Published var analystRatings: AnalystRatingsModel

    let chartDataByTimeframe: [ChartTimeframe: [Double]]
    private let dataSource: TickerDetailDataSource

    init(ticker: Ticker, dataSource: TickerDetailDataSource = MockTickerDetailDataSource()) {
        self.dataSource = dataSource
        self.ticker = ticker.symbol
        self.companyName = ticker.name
        self.price = 218.42
        self.changeToday = -3.18
        self.changeTodayPercent = -1.44
        self.changeAfterHours = 0.82
        self.changeAfterHoursPercent = 0.38

        self.chartDataByTimeframe = [
            .oneDay: [212, 214, 216, 215, 218, 217, 219, 218, 217, 218],
            .oneWeek: [222, 220, 219, 221, 218, 216, 217, 218, 219, 218],
            .oneMonth: [196, 202, 210, 206, 214, 212, 218, 220, 216, 218],
            .threeMonths: [180, 188, 192, 198, 205, 212, 220, 218, 214, 218],
            .ytd: [155, 165, 172, 180, 190, 200, 210, 218, 212, 218],
            .oneYear: [120, 135, 150, 165, 180, 195, 210, 220, 205, 218],
            .fiveYears: [45, 60, 80, 95, 120, 140, 165, 190, 210, 218]
        ]

        self.relatedLists = [
            "100 Most Popular",
            "24 Hour Market",
            "Automotive",
            "Consumer Services & Retail",
            "Texas",
            "Popular Recurring Investments"
        ]

        self.peopleAlsoOwn = [
            PeerHolding(companyName: "Apple", ticker: "AAPL", percentChange: 1.12),
            PeerHolding(companyName: "Amazon", ticker: "AMZN", percentChange: -0.84),
            PeerHolding(companyName: "NVIDIA", ticker: "NVDA", percentChange: 2.44)
        ]

        self.earnings = [
            EarningsPoint(quarter: "Q4 FY24", estimatedEPS: 0.62, actualEPS: 0.71),
            EarningsPoint(quarter: "Q1 FY25", estimatedEPS: 0.44, actualEPS: nil),
            EarningsPoint(quarter: "Q2 FY25", estimatedEPS: 0.48, actualEPS: nil),
            EarningsPoint(quarter: "Q3 FY25", estimatedEPS: 0.55, actualEPS: nil)
        ]

        self.qas = [
            ShareholderQA(dateLabel: "OCT 22", title: "Tesla vehicles are more affordable", questionsAnswered: 2),
            ShareholderQA(dateLabel: "SEP 25", title: "Full Self-Driving updates", questionsAnswered: 5),
            ShareholderQA(dateLabel: "AUG 19", title: "Robotaxi roadmap", questionsAnswered: 3)
        ]

        self.shortInterestSeries = [
            ShortInterestPoint(label: "Aug", shortInterestPercent: 3.2, daysToCover: 1.5),
            ShortInterestPoint(label: "Sep", shortInterestPercent: 3.6, daysToCover: 1.7),
            ShortInterestPoint(label: "Oct", shortInterestPercent: 3.1, daysToCover: 1.6),
            ShortInterestPoint(label: "Nov", shortInterestPercent: 2.9, daysToCover: 1.4),
            ShortInterestPoint(label: "Dec", shortInterestPercent: 3.3, daysToCover: 1.8)
        ]

        self.researchReport = ResearchReportModel(
            provider: "Morningstar",
            updatedDate: "Updated Jan 2",
            rating: 2,
            ratingMax: 5,
            moat: "Narrow",
            fairValue: "$300.00"
        )

        self.stats = [
            StatItem(label: "Volume", value: "84.2M"),
            StatItem(label: "Overnight vol", value: "5.2M"),
            StatItem(label: "Avg vol", value: "92.1M"),
            StatItem(label: "Open", value: "$221.60"),
            StatItem(label: "Today's high/low", value: "$223.10 / $216.40"),
            StatItem(label: "Market cap", value: "$693B"),
            StatItem(label: "52-week high/low", value: "$299.29 / $101.81"),
            StatItem(label: "P/E ratio", value: "61.2"),
            StatItem(label: "Dividend yield", value: "0.00%"),
            StatItem(label: "Borrow rate", value: "0.25%"),
            StatItem(label: "Short inventory", value: "45M")
        ]

        self.news = [
            NewsItem(source: "Bloomberg", timeAgo: "2h", headline: "Tesla cuts prices in key markets as demand cools", percentChange: -0.8),
            NewsItem(source: "Reuters", timeAgo: "4h", headline: "Elon Musk teases next-gen platform update", percentChange: 0.5),
            NewsItem(source: "CNBC", timeAgo: "6h", headline: "Tesla deliveries expected to rebound in Q1", percentChange: nil)
        ]

        self.analystRatings = AnalystRatingsModel(
            totalRatings: 50,
            buyPercent: 40,
            holdPercent: 36,
            sellPercent: 24,
            bullsSay: "Strong brand loyalty and expanding energy business provide long-term margin upside."
        )
        
        // Load ticker detail data asynchronously
        Task {
            await loadTickerDetail()
        }
    }

    var currentChartData: [Double] {
        chartDataByTimeframe[selectedTimeframe] ?? []
    }
    
    // MARK: - Data Loading
    
    func loadTickerDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            tickerDetailData = try await dataSource.fetchTickerDetail(symbol: ticker)
        } catch {
            errorMessage = error.localizedDescription
            // Still populate with fallback data so UI doesn't break
            tickerDetailData = MockTickerDetailDataSource().createFallbackData(symbol: ticker)
        }
        
        isLoading = false
    }
}
