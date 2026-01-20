import Foundation

enum MockData {
    static let popularTickers: [Ticker] = [
        Ticker(symbol: "AAPL", name: "Apple", popularityRank: 1),
        Ticker(symbol: "MSFT", name: "Microsoft", popularityRank: 2),
        Ticker(symbol: "NVDA", name: "NVIDIA", popularityRank: 3),
        Ticker(symbol: "AMZN", name: "Amazon", popularityRank: 4),
        Ticker(symbol: "GOOGL", name: "Alphabet", popularityRank: 5),
        Ticker(symbol: "META", name: "Meta Platforms", popularityRank: 6),
        Ticker(symbol: "TSLA", name: "Tesla", popularityRank: 7),
        Ticker(symbol: "JPM", name: "JPMorgan Chase", popularityRank: 8),
        Ticker(symbol: "V", name: "Visa", popularityRank: 9),
        Ticker(symbol: "UNH", name: "UnitedHealth Group", popularityRank: 10)
    ]

    static let tickers: [Ticker] = {
        let broader = [
            Ticker(symbol: "KO", name: "Coca-Cola", popularityRank: 100),
            Ticker(symbol: "PEP", name: "PepsiCo", popularityRank: 101),
            Ticker(symbol: "WMT", name: "Walmart", popularityRank: 102),
            Ticker(symbol: "COST", name: "Costco", popularityRank: 103),
            Ticker(symbol: "DIS", name: "Walt Disney", popularityRank: 104),
            Ticker(symbol: "BA", name: "Boeing", popularityRank: 105),
            Ticker(symbol: "XOM", name: "Exxon Mobil", popularityRank: 106),
            Ticker(symbol: "CVX", name: "Chevron", popularityRank: 107),
            Ticker(symbol: "ORCL", name: "Oracle", popularityRank: 108),
            Ticker(symbol: "NFLX", name: "Netflix", popularityRank: 109),
            Ticker(symbol: "INTC", name: "Intel", popularityRank: 110),
            Ticker(symbol: "AMD", name: "Advanced Micro Devices", popularityRank: 111),
            Ticker(symbol: "AVGO", name: "Broadcom", popularityRank: 112),
            Ticker(symbol: "CSCO", name: "Cisco", popularityRank: 113),
            Ticker(symbol: "CRM", name: "Salesforce", popularityRank: 114),
            Ticker(symbol: "ADBE", name: "Adobe", popularityRank: 115),
            Ticker(symbol: "QCOM", name: "Qualcomm", popularityRank: 116),
            Ticker(symbol: "NKE", name: "Nike", popularityRank: 117),
            Ticker(symbol: "MCD", name: "McDonald's", popularityRank: 118),
            Ticker(symbol: "SBUX", name: "Starbucks", popularityRank: 119),
            Ticker(symbol: "PG", name: "Procter & Gamble", popularityRank: 120),
            Ticker(symbol: "JNJ", name: "Johnson & Johnson", popularityRank: 121)
        ]

        return (popularTickers + broader)
            .sorted {
                if $0.popularityRank != $1.popularityRank {
                    return $0.popularityRank < $1.popularityRank
                }
                return $0.symbol < $1.symbol
            }
    }()

    static let assumptions = ForecastAssumptions.default

    static let forecastResult = ForecastResult(
        fairValue: 145,
        currentPrice: 100,
        upsidePercent: 0.45,
        projections: [
            ProjectionRow(
                id: 0,
                year: 0,
                revenue: 1_000,
                operatingIncome: 220,
                afterTaxOperatingIncome: 174,
                impliedEnterpriseValue: 4_000,
                impliedEquityValue: 4_000,
                impliedPrice: 4
            ),
            ProjectionRow(
                id: 1,
                year: 1,
                revenue: 1_080,
                operatingIncome: 238,
                afterTaxOperatingIncome: 188,
                impliedEnterpriseValue: 4_320,
                impliedEquityValue: 4_320,
                impliedPrice: 4.32
            )
        ],
        returnsByHorizon: [
            ReturnSummary(id: 1, horizonYears: 1, totalReturn: 0.12, annualizedReturn: 0.12),
            ReturnSummary(id: 3, horizonYears: 3, totalReturn: 0.35, annualizedReturn: 0.105)
        ]
    )

    static let appItems: [AppItem] = [
        AppItem(
            id: UUID(),
            title: "Base Case — Alpha Tech",
            input: "Revenue CAGR 8%, Exit Multiple 4x, Margin 22%",
            output: "Implied price rises steadily with a 5-year annualized return around 10%.",
            createdAt: Date().addingTimeInterval(-86400 * 2)
        ),
        AppItem(
            id: UUID(),
            title: "Bear Case — Alpha Tech",
            input: "Revenue CAGR 2%, Exit Multiple 3x, Margin 18%",
            output: "Implied price growth slows; annualized return trends to mid single digits.",
            createdAt: Date().addingTimeInterval(-86400 * 3)
        ),
        AppItem(
            id: UUID(),
            title: "Bull Case — Alpha Tech",
            input: "Revenue CAGR 12%, Exit Multiple 5x, Margin 26%",
            output: "Implied price accelerates with double-digit annualized returns.",
            createdAt: Date().addingTimeInterval(-86400 * 4)
        ),
        AppItem(
            id: UUID(),
            title: "Scenario — RetailCo",
            input: "Revenue CAGR 6%, Exit Multiple 2.5x, Margin 12%",
            output: "Stable trajectory with modest upside and steady cash flow profile.",
            createdAt: Date().addingTimeInterval(-86400 * 6)
        ),
        AppItem(
            id: UUID(),
            title: "Scenario — HealthPlus",
            input: "Revenue CAGR 9%, Exit Multiple 3.5x, Margin 24%",
            output: "Attractive profile with resilient margins and consistent growth.",
            createdAt: Date().addingTimeInterval(-86400 * 7)
        ),
        AppItem(
            id: UUID(),
            title: "Scenario — FinServe",
            input: "Revenue CAGR 5%, Exit Multiple 3x, Margin 20%",
            output: "Balanced outlook; moderate valuation expansion potential.",
            createdAt: Date().addingTimeInterval(-86400 * 9)
        ),
        AppItem(
            id: UUID(),
            title: "Scenario — EnergyCo",
            input: "Revenue CAGR 4%, Exit Multiple 2x, Margin 15%",
            output: "Cyclical profile with limited multiple expansion; returns rely on efficiency gains.",
            createdAt: Date().addingTimeInterval(-86400 * 11)
        ),
        AppItem(
            id: UUID(),
            title: "Scenario — CloudWorks",
            input: "Revenue CAGR 14%, Exit Multiple 6x, Margin 28%",
            output: "High growth with premium multiple; elevated upside expectations.",
            createdAt: Date().addingTimeInterval(-86400 * 12)
        ),
        AppItem(
            id: UUID(),
            title: "Scenario — AutoNext",
            input: "Revenue CAGR 3%, Exit Multiple 2.5x, Margin 10%",
            output: "Lower growth profile with stable but muted return potential.",
            createdAt: Date().addingTimeInterval(-86400 * 14)
        )
    ]
}
