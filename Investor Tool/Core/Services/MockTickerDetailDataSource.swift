import Foundation

/// Mock implementation of TickerDetailDataSource for development and testing
/// Provides rich, realistic data for major tech stocks with artificial delay to simulate network calls
final class MockTickerDetailDataSource: TickerDetailDataSource {
    
    func fetchTickerDetail(symbol: String) async throws -> TickerDetailData {
        // Simulate network delay (200-600ms)
        let delayNanoseconds = UInt64.random(in: 200_000_000...600_000_000)
        try await Task.sleep(nanoseconds: delayNanoseconds)
        
        // Return mock data based on symbol
        switch symbol.uppercased() {
        case "AAPL":
            return createAppleData()
        case "MSFT":
            return createMicrosoftData()
        case "NVDA":
            return createNvidiaData()
        case "TSLA":
            return createTeslaData()
        default:
            return createFallbackData(symbol: symbol)
        }
    }
    
    // MARK: - Apple Mock Data
    
    private func createAppleData() -> TickerDetailData {
        let profile = CompanyProfile(
            description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company is known for its innovative products including iPhone, iPad, Mac, Apple Watch, and services.",
            ceo: "Tim Cook",
            employees: 164_000,
            foundedYear: 1976,
            headquarters: "Cupertino, California"
        )
        
        let stats = KeyStats(
            volume: 84_216_300,
            open: 186.50,
            high: 188.20,
            low: 185.40,
            avgVolume: 92_100_000,
            marketCap: 2_800_000_000_000,
            week52High: 199.62,
            week52Low: 164.08,
            peRatio: 29.5,
            dividendYield: 0.52,
            shortInventory: 125_000_000,
            borrowRate: 0.15,
            overnightVolume: 5_200_000
        )
        
        let news = [
            NewsItemDetail(
                title: "Apple announces new AI features coming to iOS 18",
                source: "Bloomberg",
                publishedAt: Date().addingTimeInterval(-2 * 3600),
                summary: "Apple unveiled new artificial intelligence features that will be integrated into iOS 18, focusing on privacy-first approach.",
                priceImpact: 1.2
            ),
            NewsItemDetail(
                title: "iPhone sales exceed expectations in Q1",
                source: "CNBC",
                publishedAt: Date().addingTimeInterval(-4 * 3600),
                summary: "Strong iPhone 15 demand drives better-than-expected revenue growth.",
                priceImpact: 0.8
            ),
            NewsItemDetail(
                title: "Apple expands services revenue with new subscription tiers",
                source: "Reuters",
                publishedAt: Date().addingTimeInterval(-6 * 3600),
                summary: "The company introduces new pricing models for Apple One and Apple Music.",
                priceImpact: nil
            ),
            NewsItemDetail(
                title: "Analysts raise price targets following earnings beat",
                source: "MarketWatch",
                publishedAt: Date().addingTimeInterval(-8 * 3600),
                summary: "Multiple Wall Street firms increased their price targets for AAPL stock.",
                priceImpact: 0.5
            )
        ]
        
        let consensus = AnalystConsensus(
            strongBuy: 15,
            buy: 12,
            hold: 8,
            sell: 3,
            strongSell: 2,
            avgPriceTarget: 210.00,
            highPriceTarget: 240.00,
            lowPriceTarget: 170.00
        )
        
        let actions = [
            AnalystAction(firm: "Morgan Stanley", rating: .strongBuy, date: Date().addingTimeInterval(-1 * 86400), priceTarget: 230.00, summary: "Raised price target on strong services growth"),
            AnalystAction(firm: "Goldman Sachs", rating: .buy, date: Date().addingTimeInterval(-2 * 86400), priceTarget: 215.00, summary: "Maintains positive outlook on iPhone cycle"),
            AnalystAction(firm: "JP Morgan", rating: .strongBuy, date: Date().addingTimeInterval(-3 * 86400), priceTarget: 240.00, summary: "Most bullish on AI integration potential"),
            AnalystAction(firm: "Bank of America", rating: .buy, date: Date().addingTimeInterval(-5 * 86400), priceTarget: 220.00, summary: "Services segment continues to impress"),
            AnalystAction(firm: "Wells Fargo", rating: .hold, date: Date().addingTimeInterval(-7 * 86400), priceTarget: 195.00, summary: "Waiting for clarity on China demand"),
            AnalystAction(firm: "Citigroup", rating: .buy, date: Date().addingTimeInterval(-10 * 86400), priceTarget: 210.00, summary: "Vision Pro launch could drive upside"),
            AnalystAction(firm: "Deutsche Bank", rating: .hold, date: Date().addingTimeInterval(-12 * 86400), priceTarget: 190.00, summary: "Valuation appears full at current levels"),
            AnalystAction(firm: "UBS", rating: .buy, date: Date().addingTimeInterval(-14 * 86400), priceTarget: 205.00, summary: "Ecosystem strength supports premium multiple"),
            AnalystAction(firm: "Barclays", rating: .hold, date: Date().addingTimeInterval(-18 * 86400), priceTarget: 185.00, summary: "Neutral on near-term catalysts"),
            AnalystAction(firm: "Evercore ISI", rating: .strongBuy, date: Date().addingTimeInterval(-20 * 86400), priceTarget: 235.00, summary: "Top pick in mega-cap tech"),
            AnalystAction(firm: "Credit Suisse", rating: .buy, date: Date().addingTimeInterval(-22 * 86400), priceTarget: 225.00, summary: "iPhone 15 momentum exceeding estimates"),
            AnalystAction(firm: "Raymond James", rating: .strongBuy, date: Date().addingTimeInterval(-24 * 86400), priceTarget: 238.00, summary: "Services attach rate accelerating"),
            AnalystAction(firm: "Cowen", rating: .buy, date: Date().addingTimeInterval(-26 * 86400), priceTarget: 218.00, summary: "Wearables segment showing resilience"),
            AnalystAction(firm: "Needham", rating: .buy, date: Date().addingTimeInterval(-28 * 86400), priceTarget: 212.00, summary: "Strong holiday quarter expected"),
            AnalystAction(firm: "Piper Sandler", rating: .strongBuy, date: Date().addingTimeInterval(-30 * 86400), priceTarget: 242.00, summary: "AI features driving upgrade cycle"),
            AnalystAction(firm: "Loop Capital", rating: .hold, date: Date().addingTimeInterval(-32 * 86400), priceTarget: 192.00, summary: "Macro headwinds tempering growth"),
            AnalystAction(firm: "Wedbush", rating: .strongBuy, date: Date().addingTimeInterval(-35 * 86400), priceTarget: 250.00, summary: "Bull case scenario increasingly likely"),
            AnalystAction(firm: "KeyBanc", rating: .buy, date: Date().addingTimeInterval(-37 * 86400), priceTarget: 222.00, summary: "China stabilization a positive catalyst"),
            AnalystAction(firm: "RBC Capital", rating: .buy, date: Date().addingTimeInterval(-40 * 86400), priceTarget: 217.00, summary: "Vision Pro adoption ahead of schedule"),
            AnalystAction(firm: "Mizuho", rating: .buy, date: Date().addingTimeInterval(-42 * 86400), priceTarget: 214.00, summary: "Mac refresh cycle supporting revenue"),
            AnalystAction(firm: "BMO Capital", rating: .hold, date: Date().addingTimeInterval(-45 * 86400), priceTarget: 188.00, summary: "Valuation limits near-term upside"),
            AnalystAction(firm: "Rosenblatt", rating: .buy, date: Date().addingTimeInterval(-47 * 86400), priceTarget: 216.00, summary: "Supply chain improvements noted"),
            AnalystAction(firm: "DA Davidson", rating: .buy, date: Date().addingTimeInterval(-50 * 86400), priceTarget: 219.00, summary: "Margin expansion trajectory intact"),
            AnalystAction(firm: "Tigress Financial", rating: .strongBuy, date: Date().addingTimeInterval(-52 * 86400), priceTarget: 245.00, summary: "Best-in-class ecosystem monetization"),
            AnalystAction(firm: "New Street Research", rating: .buy, date: Date().addingTimeInterval(-55 * 86400), priceTarget: 221.00, summary: "5G tailwinds still underappreciated"),
            AnalystAction(firm: "Bernstein", rating: .buy, date: Date().addingTimeInterval(-57 * 86400), priceTarget: 213.00, summary: "India market opportunity expanding"),
            AnalystAction(firm: "Stifel", rating: .hold, date: Date().addingTimeInterval(-60 * 86400), priceTarget: 194.00, summary: "Waiting for more clarity on demand"),
            AnalystAction(firm: "Oppenheimer", rating: .buy, date: Date().addingTimeInterval(-62 * 86400), priceTarget: 224.00, summary: "Apple Pay and FinTech growing"),
            AnalystAction(firm: "Susquehanna", rating: .hold, date: Date().addingTimeInterval(-65 * 86400), priceTarget: 191.00, summary: "Mixed channel checks this quarter"),
            AnalystAction(firm: "TD Cowen", rating: .buy, date: Date().addingTimeInterval(-67 * 86400), priceTarget: 215.00, summary: "Services margins expanding further"),
            AnalystAction(firm: "Canaccord", rating: .buy, date: Date().addingTimeInterval(-70 * 86400), priceTarget: 220.00, summary: "iPhone SE refresh positive for ASP"),
            AnalystAction(firm: "BofA Securities", rating: .strongBuy, date: Date().addingTimeInterval(-72 * 86400), priceTarget: 232.00, summary: "AI integration best positioned"),
            AnalystAction(firm: "Jefferies", rating: .buy, date: Date().addingTimeInterval(-75 * 86400), priceTarget: 218.00, summary: "Watch Ultra gaining traction"),
            AnalystAction(firm: "Wolfe Research", rating: .hold, date: Date().addingTimeInterval(-77 * 86400), priceTarget: 193.00, summary: "Competitive pressures mounting"),
            AnalystAction(firm: "JPM Securities", rating: .buy, date: Date().addingTimeInterval(-80 * 86400), priceTarget: 226.00, summary: "Advertising business undervalued"),
            AnalystAction(firm: "Guggenheim", rating: .buy, date: Date().addingTimeInterval(-82 * 86400), priceTarget: 211.00, summary: "Content spending driving engagement"),
            AnalystAction(firm: "Baird", rating: .buy, date: Date().addingTimeInterval(-85 * 86400), priceTarget: 223.00, summary: "Apple Card adoption accelerating"),
            AnalystAction(firm: "Truist", rating: .hold, date: Date().addingTimeInterval(-87 * 86400), priceTarget: 189.00, summary: "Near-term catalysts limited"),
            AnalystAction(firm: "Macquarie", rating: .buy, date: Date().addingTimeInterval(-90 * 86400), priceTarget: 217.00, summary: "International growth impressive"),
            AnalystAction(firm: "HSBC", rating: .buy, date: Date().addingTimeInterval(-92 * 86400), priceTarget: 214.00, summary: "Premium positioning remains strong"),
            AnalystAction(firm: "Redburn", rating: .hold, date: Date().addingTimeInterval(-95 * 86400), priceTarget: 196.00, summary: "Execution solid but priced in"),
            AnalystAction(firm: "Atlantic Equities", rating: .buy, date: Date().addingTimeInterval(-97 * 86400), priceTarget: 219.00, summary: "Mac business stabilizing nicely"),
            AnalystAction(firm: "D.A. Davidson", rating: .strongBuy, date: Date().addingTimeInterval(-100 * 86400), priceTarget: 237.00, summary: "Vision Pro ecosystem emerging"),
            AnalystAction(firm: "Craig-Hallum", rating: .buy, date: Date().addingTimeInterval(-102 * 86400), priceTarget: 216.00, summary: "AirPods refresh cycle underway"),
            AnalystAction(firm: "B. Riley", rating: .buy, date: Date().addingTimeInterval(-105 * 86400), priceTarget: 212.00, summary: "Installed base at all-time high"),
            AnalystAction(firm: "Benchmark", rating: .hold, date: Date().addingTimeInterval(-107 * 86400), priceTarget: 198.00, summary: "Regulatory risks increasing"),
            AnalystAction(firm: "Maxim Group", rating: .buy, date: Date().addingTimeInterval(-110 * 86400), priceTarget: 221.00, summary: "App Store resilience impressive"),
            AnalystAction(firm: "Northland", rating: .buy, date: Date().addingTimeInterval(-112 * 86400), priceTarget: 215.00, summary: "China recovery taking hold"),
            AnalystAction(firm: "William Blair", rating: .buy, date: Date().addingTimeInterval(-115 * 86400), priceTarget: 227.00, summary: "Subscription bundles gaining share"),
            AnalystAction(firm: "Stephens", rating: .strongBuy, date: Date().addingTimeInterval(-117 * 86400), priceTarget: 241.00, summary: "Best risk/reward in mega-cap tech")
        ]
        
        return TickerDetailData(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 187.25,
            changeToday: 2.15,
            changeTodayPercent: 1.16,
            profile: profile,
            keyStats: stats,
            news: news,
            analystConsensus: consensus,
            analystActions: actions
        )
    }
    
    // MARK: - Microsoft Mock Data
    
    private func createMicrosoftData() -> TickerDetailData {
        let profile = CompanyProfile(
            description: "Microsoft Corporation develops, licenses, and supports software, services, devices, and solutions worldwide. The company operates through segments including Productivity and Business Processes, Intelligent Cloud, and More Personal Computing.",
            ceo: "Satya Nadella",
            employees: 221_000,
            foundedYear: 1975,
            headquarters: "Redmond, Washington"
        )
        
        let stats = KeyStats(
            volume: 28_450_000,
            open: 412.50,
            high: 415.80,
            low: 410.20,
            avgVolume: 32_800_000,
            marketCap: 3_100_000_000_000,
            week52High: 425.00,
            week52Low: 309.45,
            peRatio: 35.2,
            dividendYield: 0.78,
            shortInventory: 68_000_000,
            borrowRate: 0.12,
            overnightVolume: 2_100_000
        )
        
        let news = [
            NewsItemDetail(
                title: "Microsoft Azure revenue growth accelerates to 31%",
                source: "CNBC",
                publishedAt: Date().addingTimeInterval(-1 * 3600),
                summary: "Cloud computing division shows strong momentum with AI services driving adoption.",
                priceImpact: 2.4
            ),
            NewsItemDetail(
                title: "OpenAI partnership delivers $10B in AI revenue",
                source: "Bloomberg",
                publishedAt: Date().addingTimeInterval(-3 * 3600),
                summary: "Microsoft's investment in OpenAI is paying off with rapid commercialization.",
                priceImpact: 1.5
            ),
            NewsItemDetail(
                title: "Copilot adoption surpasses 50 million enterprise users",
                source: "Reuters",
                publishedAt: Date().addingTimeInterval(-5 * 3600),
                summary: "AI assistant sees rapid uptake across Microsoft 365 suite.",
                priceImpact: nil
            )
        ]
        
        let consensus = AnalystConsensus(
            strongBuy: 18,
            buy: 14,
            hold: 6,
            sell: 2,
            strongSell: 0,
            avgPriceTarget: 445.00,
            highPriceTarget: 500.00,
            lowPriceTarget: 380.00
        )
        
        let actions = [
            AnalystAction(firm: "Wedbush", rating: .strongBuy, date: Date().addingTimeInterval(-1 * 86400), priceTarget: 500.00, summary: "AI monetization exceeding expectations"),
            AnalystAction(firm: "Morgan Stanley", rating: .strongBuy, date: Date().addingTimeInterval(-2 * 86400), priceTarget: 475.00, summary: "Azure continues to gain share"),
            AnalystAction(firm: "Piper Sandler", rating: .buy, date: Date().addingTimeInterval(-4 * 86400), priceTarget: 450.00, summary: "Cloud growth trajectory remains strong"),
            AnalystAction(firm: "Goldman Sachs", rating: .buy, date: Date().addingTimeInterval(-6 * 86400), priceTarget: 440.00, summary: "Best positioned for AI era"),
            AnalystAction(firm: "Oppenheimer", rating: .strongBuy, date: Date().addingTimeInterval(-8 * 86400), priceTarget: 480.00, summary: "Copilot driving incremental revenue"),
            AnalystAction(firm: "Jefferies", rating: .buy, date: Date().addingTimeInterval(-10 * 86400), priceTarget: 435.00, summary: "Enterprise AI adoption accelerating"),
            AnalystAction(firm: "Stifel", rating: .hold, date: Date().addingTimeInterval(-12 * 86400), priceTarget: 410.00, summary: "Valuation reflects strong fundamentals"),
            AnalystAction(firm: "RBC Capital", rating: .buy, date: Date().addingTimeInterval(-15 * 86400), priceTarget: 455.00, summary: "Azure AI services gaining traction")
        ]
        
        return TickerDetailData(
            symbol: "MSFT",
            companyName: "Microsoft Corporation",
            price: 413.80,
            changeToday: 5.20,
            changeTodayPercent: 1.27,
            profile: profile,
            keyStats: stats,
            news: news,
            analystConsensus: consensus,
            analystActions: actions
        )
    }
    
    // MARK: - NVIDIA Mock Data
    
    private func createNvidiaData() -> TickerDetailData {
        let profile = CompanyProfile(
            description: "NVIDIA Corporation provides graphics and compute solutions. The company operates in two segments: Graphics and Compute & Networking. It is the leading designer of graphics processing units that enhance the visual computing experience.",
            ceo: "Jensen Huang",
            employees: 29_600,
            foundedYear: 1993,
            headquarters: "Santa Clara, California"
        )
        
        let stats = KeyStats(
            volume: 52_800_000,
            open: 485.20,
            high: 492.50,
            low: 483.10,
            avgVolume: 58_200_000,
            marketCap: 1_200_000_000_000,
            week52High: 502.66,
            week52Low: 108.13,
            peRatio: 68.5,
            dividendYield: 0.03,
            shortInventory: 95_000_000,
            borrowRate: 0.35,
            overnightVolume: 4_800_000
        )
        
        let news = [
            NewsItemDetail(
                title: "NVIDIA data center revenue triples year-over-year",
                source: "Reuters",
                publishedAt: Date().addingTimeInterval(-2 * 3600),
                summary: "AI chip demand shows no signs of slowing as hyperscalers expand capacity.",
                priceImpact: 3.2
            ),
            NewsItemDetail(
                title: "Blackwell GPU architecture launches with record backlog",
                source: "Bloomberg",
                publishedAt: Date().addingTimeInterval(-5 * 3600),
                summary: "Next-generation AI chips already sold out through 2026.",
                priceImpact: 2.8
            ),
            NewsItemDetail(
                title: "Partnership with major cloud providers expands",
                source: "CNBC",
                publishedAt: Date().addingTimeInterval(-7 * 3600),
                summary: "AWS, Azure, and Google Cloud commit to billion-dollar GPU purchases.",
                priceImpact: 1.5
            ),
            NewsItemDetail(
                title: "Gaming segment recovery drives upside surprise",
                source: "MarketWatch",
                publishedAt: Date().addingTimeInterval(-10 * 3600),
                summary: "RTX 50 series launch sees strong consumer demand.",
                priceImpact: nil
            )
        ]
        
        let consensus = AnalystConsensus(
            strongBuy: 22,
            buy: 10,
            hold: 5,
            sell: 1,
            strongSell: 0,
            avgPriceTarget: 580.00,
            highPriceTarget: 700.00,
            lowPriceTarget: 420.00
        )
        
        let actions = [
            AnalystAction(firm: "Bank of America", rating: .strongBuy, date: Date().addingTimeInterval(-1 * 86400), priceTarget: 700.00, summary: "AI infrastructure build-out has years to run"),
            AnalystAction(firm: "Mizuho", rating: .strongBuy, date: Date().addingTimeInterval(-2 * 86400), priceTarget: 650.00, summary: "Blackwell demand visibility through 2027"),
            AnalystAction(firm: "Morgan Stanley", rating: .buy, date: Date().addingTimeInterval(-3 * 86400), priceTarget: 600.00, summary: "Data center growth remains robust"),
            AnalystAction(firm: "Wells Fargo", rating: .strongBuy, date: Date().addingTimeInterval(-5 * 86400), priceTarget: 625.00, summary: "Most compelling AI play in market"),
            AnalystAction(firm: "Evercore ISI", rating: .buy, date: Date().addingTimeInterval(-7 * 86400), priceTarget: 580.00, summary: "Supply chain constraints easing"),
            AnalystAction(firm: "Bernstein", rating: .buy, date: Date().addingTimeInterval(-9 * 86400), priceTarget: 575.00, summary: "Software revenue becoming meaningful"),
            AnalystAction(firm: "Rosenblatt", rating: .strongBuy, date: Date().addingTimeInterval(-11 * 86400), priceTarget: 680.00, summary: "Sovereign AI creating new demand"),
            AnalystAction(firm: "KeyBanc", rating: .buy, date: Date().addingTimeInterval(-14 * 86400), priceTarget: 595.00, summary: "Gaming recovery adds to AI momentum"),
            AnalystAction(firm: "Raymond James", rating: .strongBuy, date: Date().addingTimeInterval(-16 * 86400), priceTarget: 640.00, summary: "Networking business underappreciated"),
            AnalystAction(firm: "Needham", rating: .buy, date: Date().addingTimeInterval(-19 * 86400), priceTarget: 560.00, summary: "AI training and inference leader")
        ]
        
        return TickerDetailData(
            symbol: "NVDA",
            companyName: "NVIDIA Corporation",
            price: 488.50,
            changeToday: 8.30,
            changeTodayPercent: 1.73,
            profile: profile,
            keyStats: stats,
            news: news,
            analystConsensus: consensus,
            analystActions: actions
        )
    }
    
    // MARK: - Tesla Mock Data
    
    private func createTeslaData() -> TickerDetailData {
        let profile = CompanyProfile(
            description: "Tesla, Inc. designs, develops, manufactures, leases, and sells electric vehicles, energy generation, and storage systems in the United States, China, and internationally. The company is pioneering sustainable energy and autonomous driving technology.",
            ceo: "Elon Musk",
            employees: 140_473,
            foundedYear: 2003,
            headquarters: "Austin, Texas"
        )
        
        let stats = KeyStats(
            volume: 84_216_300,
            open: 221.60,
            high: 223.10,
            low: 216.40,
            avgVolume: 92_100_000,
            marketCap: 693_000_000_000,
            week52High: 299.29,
            week52Low: 101.81,
            peRatio: 61.2,
            dividendYield: 0.0,
            shortInventory: 45_000_000,
            borrowRate: 0.25,
            overnightVolume: 5_200_000
        )
        
        let news = [
            NewsItemDetail(
                title: "Tesla cuts prices in key markets as demand cools",
                source: "Bloomberg",
                publishedAt: Date().addingTimeInterval(-2 * 3600),
                summary: "Price reductions in China and Europe aim to stimulate demand amid increased competition.",
                priceImpact: -0.8
            ),
            NewsItemDetail(
                title: "Elon Musk teases next-gen platform update",
                source: "Reuters",
                publishedAt: Date().addingTimeInterval(-4 * 3600),
                summary: "CEO hints at new affordable EV platform coming in 2025.",
                priceImpact: 0.5
            ),
            NewsItemDetail(
                title: "Tesla deliveries expected to rebound in Q1",
                source: "CNBC",
                publishedAt: Date().addingTimeInterval(-6 * 3600),
                summary: "Analysts predict sequential improvement in delivery numbers.",
                priceImpact: nil
            ),
            NewsItemDetail(
                title: "Full Self-Driving beta expands to more markets",
                source: "The Verge",
                publishedAt: Date().addingTimeInterval(-9 * 3600),
                summary: "Autonomous driving software rolling out to additional countries.",
                priceImpact: 0.3
            ),
            NewsItemDetail(
                title: "Energy storage business sees record deployments",
                source: "MarketWatch",
                publishedAt: Date().addingTimeInterval(-12 * 3600),
                summary: "Megapack installations accelerate as grid storage demand grows.",
                priceImpact: nil
            )
        ]
        
        let consensus = AnalystConsensus(
            strongBuy: 8,
            buy: 12,
            hold: 18,
            sell: 9,
            strongSell: 3,
            avgPriceTarget: 235.00,
            highPriceTarget: 350.00,
            lowPriceTarget: 120.00
        )
        
        let actions = [
            AnalystAction(firm: "Wedbush", rating: .buy, date: Date().addingTimeInterval(-1 * 86400), priceTarget: 300.00, summary: "FSD and energy storage undervalued"),
            AnalystAction(firm: "Morgan Stanley", rating: .buy, date: Date().addingTimeInterval(-3 * 86400), priceTarget: 310.00, summary: "Robotaxi opportunity not priced in"),
            AnalystAction(firm: "Goldman Sachs", rating: .hold, date: Date().addingTimeInterval(-5 * 86400), priceTarget: 220.00, summary: "Waiting for demand inflection"),
            AnalystAction(firm: "Bank of America", rating: .hold, date: Date().addingTimeInterval(-7 * 86400), priceTarget: 225.00, summary: "Near-term headwinds persist"),
            AnalystAction(firm: "JP Morgan", rating: .sell, date: Date().addingTimeInterval(-9 * 86400), priceTarget: 135.00, summary: "Competition intensifying globally"),
            AnalystAction(firm: "Piper Sandler", rating: .buy, date: Date().addingTimeInterval(-11 * 86400), priceTarget: 280.00, summary: "Energy business gaining momentum"),
            AnalystAction(firm: "Bernstein", rating: .sell, date: Date().addingTimeInterval(-13 * 86400), priceTarget: 150.00, summary: "Margin pressure from price cuts"),
            AnalystAction(firm: "Barclays", rating: .hold, date: Date().addingTimeInterval(-15 * 86400), priceTarget: 210.00, summary: "Mixed signals on demand trends"),
            AnalystAction(firm: "UBS", rating: .hold, date: Date().addingTimeInterval(-17 * 86400), priceTarget: 215.00, summary: "Valuation remains elevated"),
            AnalystAction(firm: "Deutsche Bank", rating: .buy, date: Date().addingTimeInterval(-20 * 86400), priceTarget: 270.00, summary: "Long-term tech advantages intact"),
            AnalystAction(firm: "Wells Fargo", rating: .hold, date: Date().addingTimeInterval(-22 * 86400), priceTarget: 200.00, summary: "Cautious on near-term execution"),
            AnalystAction(firm: "Canaccord", rating: .strongBuy, date: Date().addingTimeInterval(-25 * 86400), priceTarget: 350.00, summary: "AI and robotics optionality compelling")
        ]
        
        return TickerDetailData(
            symbol: "TSLA",
            companyName: "Tesla, Inc.",
            price: 218.42,
            changeToday: -3.18,
            changeTodayPercent: -1.44,
            profile: profile,
            keyStats: stats,
            news: news,
            analystConsensus: consensus,
            analystActions: actions
        )
    }
    
    // MARK: - Fallback Data
    
    func createFallbackData(symbol: String) -> TickerDetailData {
        let profile = CompanyProfile(
            description: "Company information not available for \(symbol). This is placeholder data for demonstration purposes.",
            ceo: "N/A",
            employees: 0,
            foundedYear: 0,
            headquarters: "N/A"
        )
        
        let stats = KeyStats(
            volume: nil,
            open: nil,
            high: nil,
            low: nil,
            avgVolume: nil,
            marketCap: nil,
            week52High: nil,
            week52Low: nil,
            peRatio: nil,
            dividendYield: nil,
            shortInventory: nil,
            borrowRate: nil,
            overnightVolume: nil
        )
        
        let news: [NewsItemDetail] = []
        
        let consensus = AnalystConsensus(
            strongBuy: 0,
            buy: 0,
            hold: 0,
            sell: 0,
            strongSell: 0,
            avgPriceTarget: nil,
            highPriceTarget: nil,
            lowPriceTarget: nil
        )
        
        let actions: [AnalystAction] = []
        
        return TickerDetailData(
            symbol: symbol,
            companyName: "\(symbol) Company",
            price: 0.0,
            changeToday: 0.0,
            changeTodayPercent: 0.0,
            profile: profile,
            keyStats: stats,
            news: news,
            analystConsensus: consensus,
            analystActions: actions
        )
    }
}
