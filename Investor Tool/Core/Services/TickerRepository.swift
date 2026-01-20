//
//  TickerRepository.swift
//  Investor Tool
//
//  Mock ticker data and search functionality for DCF Setup
//

import Foundation

class TickerRepository {
    static let shared = TickerRepository()
    
    private init() {}
    
    // MARK: - Mock Data
    
    private(set) lazy var allTickers: [DCFTicker] = [
        // Technology - Large Cap
        DCFTicker(
            symbol: "AAPL",
            name: "Apple Inc.",
            sector: "Technology",
            industry: "Consumer Electronics",
            marketCapTier: .large,
            businessModel: .platform,
            blurb: "Designs and manufactures consumer electronics, software, and services. Known for iPhone, Mac, and services ecosystem.",
            currentPrice: 185.50
        ),
        DCFTicker(
            symbol: "MSFT",
            name: "Microsoft Corporation",
            sector: "Technology",
            industry: "Software",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Develops software, cloud services, and hardware. Azure cloud and Office 365 drive recurring revenue.",
            currentPrice: 420.25
        ),
        DCFTicker(
            symbol: "GOOGL",
            name: "Alphabet Inc.",
            sector: "Technology",
            industry: "Internet Services",
            marketCapTier: .large,
            businessModel: .advertising,
            blurb: "Parent company of Google. Dominates digital advertising with Search and YouTube.",
            currentPrice: 152.30
        ),
        DCFTicker(
            symbol: "META",
            name: "Meta Platforms Inc.",
            sector: "Technology",
            industry: "Social Media",
            marketCapTier: .large,
            businessModel: .advertising,
            blurb: "Social networking and metaverse company. Facebook, Instagram, and WhatsApp drive ad revenue.",
            currentPrice: 485.75
        ),
        DCFTicker(
            symbol: "NVDA",
            name: "NVIDIA Corporation",
            sector: "Technology",
            industry: "Semiconductors",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Designs GPUs for gaming, data centers, and AI. Leading position in AI computing.",
            currentPrice: 875.40
        ),
        DCFTicker(
            symbol: "TSLA",
            name: "Tesla, Inc.",
            sector: "Consumer Cyclical",
            industry: "Auto Manufacturers",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Electric vehicle and clean energy company. Pioneering autonomous driving and energy storage.",
            currentPrice: 342.90
        ),
        DCFTicker(
            symbol: "AMZN",
            name: "Amazon.com Inc.",
            sector: "Consumer Cyclical",
            industry: "Internet Retail",
            marketCapTier: .large,
            businessModel: .platform,
            blurb: "E-commerce and cloud computing leader. AWS drives high-margin revenue growth.",
            currentPrice: 178.25
        ),
        DCFTicker(
            symbol: "NFLX",
            name: "Netflix Inc.",
            sector: "Communication Services",
            industry: "Entertainment",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Streaming entertainment service with 240M+ subscribers globally. Ad tier driving new growth.",
            currentPrice: 520.30
        ),
        
        // Healthcare - Large/Mid Cap
        DCFTicker(
            symbol: "UNH",
            name: "UnitedHealth Group",
            sector: "Healthcare",
            industry: "Healthcare Plans",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Largest health insurer in the US. Optum division provides care delivery and pharmacy benefits.",
            currentPrice: 512.75
        ),
        DCFTicker(
            symbol: "JNJ",
            name: "Johnson & Johnson",
            sector: "Healthcare",
            industry: "Drug Manufacturers",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Pharmaceutical, medical device, and consumer health products. Diversified healthcare giant.",
            currentPrice: 158.90
        ),
        DCFTicker(
            symbol: "LLY",
            name: "Eli Lilly and Company",
            sector: "Healthcare",
            industry: "Drug Manufacturers",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Pharmaceutical company focused on diabetes, oncology, and weight loss treatments.",
            currentPrice: 745.20
        ),
        DCFTicker(
            symbol: "ABBV",
            name: "AbbVie Inc.",
            sector: "Healthcare",
            industry: "Drug Manufacturers",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Biopharmaceutical company known for Humira and growing immunology portfolio.",
            currentPrice: 168.45
        ),
        
        // Financials - Large/Mid Cap
        DCFTicker(
            symbol: "JPM",
            name: "JPMorgan Chase & Co.",
            sector: "Financial Services",
            industry: "Banks - Diversified",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Largest US bank by assets. Diversified across consumer banking, investment banking, and asset management.",
            currentPrice: 198.30
        ),
        DCFTicker(
            symbol: "BAC",
            name: "Bank of America Corp",
            sector: "Financial Services",
            industry: "Banks - Diversified",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Second-largest US bank. Strong retail franchise and investment banking presence.",
            currentPrice: 42.85
        ),
        DCFTicker(
            symbol: "V",
            name: "Visa Inc.",
            sector: "Financial Services",
            industry: "Credit Services",
            marketCapTier: .large,
            businessModel: .platform,
            blurb: "Global payments technology company. Processes transactions but doesn't issue cards or lend.",
            currentPrice: 285.40
        ),
        DCFTicker(
            symbol: "MA",
            name: "Mastercard Inc.",
            sector: "Financial Services",
            industry: "Credit Services",
            marketCapTier: .large,
            businessModel: .platform,
            blurb: "Payment processing network with high-margin, capital-light business model.",
            currentPrice: 465.90
        ),
        
        // Consumer - Various
        DCFTicker(
            symbol: "WMT",
            name: "Walmart Inc.",
            sector: "Consumer Defensive",
            industry: "Discount Stores",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "World's largest retailer. Growing e-commerce and advertising businesses.",
            currentPrice: 68.25
        ),
        DCFTicker(
            symbol: "HD",
            name: "The Home Depot",
            sector: "Consumer Cyclical",
            industry: "Home Improvement",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Leading home improvement retailer. Benefits from housing market strength and DIY trends.",
            currentPrice: 385.70
        ),
        DCFTicker(
            symbol: "NKE",
            name: "Nike Inc.",
            sector: "Consumer Cyclical",
            industry: "Footwear & Accessories",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Global athletic footwear and apparel brand. Shifting to direct-to-consumer sales model.",
            currentPrice: 78.50
        ),
        DCFTicker(
            symbol: "SBUX",
            name: "Starbucks Corporation",
            sector: "Consumer Cyclical",
            industry: "Restaurants",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Global coffeehouse chain with loyalty program driving recurring revenue. Expanding in China.",
            currentPrice: 95.30
        ),
        
        // Industrials - Mid Cap
        DCFTicker(
            symbol: "CAT",
            name: "Caterpillar Inc.",
            sector: "Industrials",
            industry: "Construction Machinery",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Manufactures construction and mining equipment. Cyclical exposure to infrastructure spending.",
            currentPrice: 325.40
        ),
        DCFTicker(
            symbol: "BA",
            name: "The Boeing Company",
            sector: "Industrials",
            industry: "Aerospace & Defense",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Aerospace company designing and manufacturing commercial jetliners and defense systems.",
            currentPrice: 178.60
        ),
        DCFTicker(
            symbol: "UPS",
            name: "United Parcel Service",
            sector: "Industrials",
            industry: "Integrated Freight & Logistics",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Package delivery and supply chain management. Benefits from e-commerce growth.",
            currentPrice: 142.75
        ),
        
        // Energy - Large/Mid Cap
        DCFTicker(
            symbol: "XOM",
            name: "Exxon Mobil Corporation",
            sector: "Energy",
            industry: "Oil & Gas Integrated",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Integrated oil and gas company. Upstream, downstream, and chemical operations.",
            currentPrice: 108.90
        ),
        DCFTicker(
            symbol: "CVX",
            name: "Chevron Corporation",
            sector: "Energy",
            industry: "Oil & Gas Integrated",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Major oil company with global upstream and downstream assets. Strong dividend history.",
            currentPrice: 155.25
        ),
        
        // Technology - Mid/Small Cap
        DCFTicker(
            symbol: "SQ",
            name: "Block, Inc.",
            sector: "Technology",
            industry: "Financial Technology",
            marketCapTier: .mid,
            businessModel: .platform,
            blurb: "Fintech company with Square merchant services and Cash App consumer platform.",
            currentPrice: 68.40
        ),
        DCFTicker(
            symbol: "SHOP",
            name: "Shopify Inc.",
            sector: "Technology",
            industry: "Software",
            marketCapTier: .mid,
            businessModel: .subscription,
            blurb: "E-commerce platform for merchants. Subscription + transaction-based revenue model.",
            currentPrice: 78.90
        ),
        DCFTicker(
            symbol: "ROKU",
            name: "Roku, Inc.",
            sector: "Technology",
            industry: "Entertainment",
            marketCapTier: .mid,
            businessModel: .advertising,
            blurb: "Streaming platform and ad network. Monetizes through device sales and platform fees.",
            currentPrice: 72.35
        ),
        DCFTicker(
            symbol: "PLTR",
            name: "Palantir Technologies",
            sector: "Technology",
            industry: "Software",
            marketCapTier: .mid,
            businessModel: .subscription,
            blurb: "Data analytics software for government and enterprise. AI-powered decision making platform.",
            currentPrice: 45.80
        ),
        DCFTicker(
            symbol: "SNOW",
            name: "Snowflake Inc.",
            sector: "Technology",
            industry: "Software",
            marketCapTier: .mid,
            businessModel: .subscription,
            blurb: "Cloud data platform enabling data storage, processing, and analytics. Consumption-based pricing.",
            currentPrice: 165.20
        ),
        
        // Consumer - Mid/Small Cap
        DCFTicker(
            symbol: "LULU",
            name: "Lululemon Athletica",
            sector: "Consumer Cyclical",
            industry: "Apparel Retail",
            marketCapTier: .mid,
            businessModel: .transactional,
            blurb: "Athletic apparel retailer targeting premium segment. Strong brand loyalty and DTC presence.",
            currentPrice: 385.60
        ),
        DCFTicker(
            symbol: "ETSY",
            name: "Etsy, Inc.",
            sector: "Consumer Cyclical",
            industry: "Internet Retail",
            marketCapTier: .mid,
            businessModel: .platform,
            blurb: "Online marketplace for handmade and vintage items. Takes commission on sales.",
            currentPrice: 58.25
        ),
        
        // Healthcare - Mid Cap
        DCFTicker(
            symbol: "DXCM",
            name: "DexCom, Inc.",
            sector: "Healthcare",
            industry: "Medical Devices",
            marketCapTier: .mid,
            businessModel: .subscription,
            blurb: "Continuous glucose monitoring systems for diabetes management. Recurring consumable revenue.",
            currentPrice: 85.40
        ),
        DCFTicker(
            symbol: "HIMS",
            name: "Hims & Hers Health",
            sector: "Healthcare",
            industry: "Healthcare Plans",
            marketCapTier: .small,
            businessModel: .subscription,
            blurb: "Telehealth and wellness platform. Subscription-based model for medications and treatments.",
            currentPrice: 24.70
        ),
        
        // Real Estate - Mid Cap
        DCFTicker(
            symbol: "AMT",
            name: "American Tower Corp",
            sector: "Real Estate",
            industry: "REIT - Specialty",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Cell tower REIT leasing space to wireless carriers. Recurring lease revenue with escalators.",
            currentPrice: 212.85
        ),
        DCFTicker(
            symbol: "PLD",
            name: "Prologis, Inc.",
            sector: "Real Estate",
            industry: "REIT - Industrial",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "Industrial logistics real estate. Benefits from e-commerce and supply chain trends.",
            currentPrice: 118.50
        ),
        
        // Additional Tech
        DCFTicker(
            symbol: "CRM",
            name: "Salesforce, Inc.",
            sector: "Technology",
            industry: "Software",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Cloud-based CRM platform with enterprise software suite. Subscription-based SaaS model.",
            currentPrice: 285.40
        ),
        DCFTicker(
            symbol: "ADBE",
            name: "Adobe Inc.",
            sector: "Technology",
            industry: "Software",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Creative software suite and digital experience platform. Strong subscription transition complete.",
            currentPrice: 512.75
        ),
        DCFTicker(
            symbol: "ORCL",
            name: "Oracle Corporation",
            sector: "Technology",
            industry: "Software",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Enterprise software and cloud infrastructure. Database and cloud applications.",
            currentPrice: 128.90
        ),
        
        // Additional Consumer
        DCFTicker(
            symbol: "MCD",
            name: "McDonald's Corporation",
            sector: "Consumer Cyclical",
            industry: "Restaurants",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Global fast-food chain. Franchise model generates recurring royalty revenue.",
            currentPrice: 285.30
        ),
        DCFTicker(
            symbol: "KO",
            name: "The Coca-Cola Company",
            sector: "Consumer Defensive",
            industry: "Beverages",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Global beverage company with iconic brand portfolio. Consistent cash generation.",
            currentPrice: 62.45
        ),
        DCFTicker(
            symbol: "PEP",
            name: "PepsiCo, Inc.",
            sector: "Consumer Defensive",
            industry: "Beverages",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Food and beverage conglomerate. Snacks (Frito-Lay) and beverages drive diversified revenue.",
            currentPrice: 168.90
        ),
        
        // Telecom
        DCFTicker(
            symbol: "T",
            name: "AT&T Inc.",
            sector: "Communication Services",
            industry: "Telecom Services",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Telecom provider with wireless and fiber networks. Subscription-based recurring revenue.",
            currentPrice: 22.15
        ),
        DCFTicker(
            symbol: "VZ",
            name: "Verizon Communications",
            sector: "Communication Services",
            industry: "Telecom Services",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Wireless carrier with extensive 5G network. High-quality network commands premium pricing.",
            currentPrice: 41.30
        ),
        
        // Additional Financials
        DCFTicker(
            symbol: "GS",
            name: "Goldman Sachs Group",
            sector: "Financial Services",
            industry: "Investment Banking",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Leading investment bank and asset manager. Trading and advisory revenue.",
            currentPrice: 485.25
        ),
        DCFTicker(
            symbol: "BLK",
            name: "BlackRock, Inc.",
            sector: "Financial Services",
            industry: "Asset Management",
            marketCapTier: .large,
            businessModel: .assetHeavy,
            blurb: "World's largest asset manager. Fee-based revenue on $10T+ in AUM.",
            currentPrice: 912.40
        ),
        
        // Semiconductors
        DCFTicker(
            symbol: "AMD",
            name: "Advanced Micro Devices",
            sector: "Technology",
            industry: "Semiconductors",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "CPU and GPU designer competing with Intel and NVIDIA. Data center growth driver.",
            currentPrice: 142.85
        ),
        DCFTicker(
            symbol: "INTC",
            name: "Intel Corporation",
            sector: "Technology",
            industry: "Semiconductors",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Semiconductor manufacturer focused on CPUs. Investing heavily in foundry capabilities.",
            currentPrice: 42.90
        ),
        DCFTicker(
            symbol: "QCOM",
            name: "Qualcomm Inc.",
            sector: "Technology",
            industry: "Semiconductors",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Mobile chip designer with strong 5G position. Licensing revenue from patents.",
            currentPrice: 168.75
        ),
        
        // Biotech
        DCFTicker(
            symbol: "GILD",
            name: "Gilead Sciences",
            sector: "Healthcare",
            industry: "Biotechnology",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "Biopharmaceutical company focused on HIV, oncology, and liver diseases.",
            currentPrice: 78.30
        ),
        DCFTicker(
            symbol: "MRNA",
            name: "Moderna, Inc.",
            sector: "Healthcare",
            industry: "Biotechnology",
            marketCapTier: .mid,
            businessModel: .transactional,
            blurb: "mRNA technology platform for vaccines and therapeutics. COVID vaccine revenue.",
            currentPrice: 68.50
        ),
        
        // Entertainment/Media
        DCFTicker(
            symbol: "DIS",
            name: "The Walt Disney Company",
            sector: "Communication Services",
            industry: "Entertainment",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Media and entertainment conglomerate. Parks, streaming (Disney+), and content production.",
            currentPrice: 92.85
        ),
        DCFTicker(
            symbol: "SPOT",
            name: "Spotify Technology",
            sector: "Communication Services",
            industry: "Entertainment",
            marketCapTier: .mid,
            businessModel: .subscription,
            blurb: "Music streaming platform with 500M+ users. Freemium and premium subscription model.",
            currentPrice: 298.40
        ),
        
        // Retail
        DCFTicker(
            symbol: "TGT",
            name: "Target Corporation",
            sector: "Consumer Defensive",
            industry: "Discount Stores",
            marketCapTier: .large,
            businessModel: .transactional,
            blurb: "General merchandise retailer with strong private label brands. Growing digital presence.",
            currentPrice: 148.25
        ),
        DCFTicker(
            symbol: "COST",
            name: "Costco Wholesale",
            sector: "Consumer Defensive",
            industry: "Discount Stores",
            marketCapTier: .large,
            businessModel: .subscription,
            blurb: "Membership warehouse club. Membership fees drive high-margin recurring revenue.",
            currentPrice: 785.90
        ),
    ]
    
    var popularTickers: [DCFTicker] {
        Array(allTickers.prefix(10))
    }
    
    // MARK: - Lookup
    
    func findTicker(bySymbol symbol: String) -> DCFTicker? {
        return allTickers.first { $0.symbol.uppercased() == symbol.uppercased() }
    }
    
    // MARK: - Search
    
    func search(query: String) -> [DCFTicker] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            return popularTickers
        }
        
        let uppercaseQuery = trimmedQuery.uppercased()
        
        // Exact symbol match
        let exactMatches = allTickers.filter { $0.symbol == uppercaseQuery }
        
        // Symbol prefix match
        let prefixMatches = allTickers.filter {
            $0.symbol.hasPrefix(uppercaseQuery) && $0.symbol != uppercaseQuery
        }
        
        // Symbol substring match
        let symbolSubstringMatches = allTickers.filter {
            $0.symbol.contains(uppercaseQuery) &&
            !$0.symbol.hasPrefix(uppercaseQuery) &&
            $0.symbol != uppercaseQuery
        }
        
        // Name match (case-insensitive)
        let nameMatches = allTickers.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedQuery) &&
            !$0.symbol.contains(uppercaseQuery)
        }
        
        // Combine and deduplicate
        var results: [DCFTicker] = []
        results.append(contentsOf: exactMatches)
        results.append(contentsOf: prefixMatches)
        results.append(contentsOf: symbolSubstringMatches)
        results.append(contentsOf: nameMatches)
        
        return Array(results.prefix(20))
    }
    
    // MARK: - Revenue Driver Generation
    
    func generateDefaultRevenueDrivers(for businessModel: BusinessModelTag, sector: String) -> [RevenueDriver] {
        switch businessModel {
        case .subscription:
            return subscriptionDrivers()
        case .transactional:
            return transactionalDrivers(sector: sector)
        case .assetHeavy:
            return assetHeavyDrivers(sector: sector)
        case .platform:
            return platformDrivers()
        case .advertising:
            return advertisingDrivers()
        case .other:
            return genericDrivers()
        }
    }
    
    private func subscriptionDrivers() -> [RevenueDriver] {
        [
            RevenueDriver(
                title: "Customer Growth",
                subtitle: "Year-over-year subscriber additions",
                unit: .percent,
                value: 15.0,
                min: -5.0,
                max: 40.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "ARPU Growth",
                subtitle: "Average revenue per user expansion",
                unit: .percent,
                value: 8.0,
                min: -10.0,
                max: 25.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "Net Revenue Retention",
                subtitle: "Existing customer spend change",
                unit: .percent,
                value: 110.0,
                min: 85.0,
                max: 140.0,
                step: 1.0
            ),
        ]
    }
    
    private func transactionalDrivers(sector: String) -> [RevenueDriver] {
        if sector.contains("Financial") {
            return [
                RevenueDriver(
                    title: "Transaction Volume",
                    subtitle: "Growth in number of transactions",
                    unit: .percent,
                    value: 12.0,
                    min: -10.0,
                    max: 35.0,
                    step: 1.0
                ),
                RevenueDriver(
                    title: "Average Transaction Size",
                    subtitle: "Dollars per transaction growth",
                    unit: .percent,
                    value: 5.0,
                    min: -5.0,
                    max: 20.0,
                    step: 1.0
                ),
                RevenueDriver(
                    title: "Take Rate",
                    subtitle: "Fee as % of transaction value",
                    unit: .percent,
                    value: 2.5,
                    min: 1.5,
                    max: 4.0,
                    step: 0.1
                ),
            ]
        } else {
            return [
                RevenueDriver(
                    title: "Volume Growth",
                    subtitle: "Units sold year-over-year",
                    unit: .percent,
                    value: 8.0,
                    min: -15.0,
                    max: 30.0,
                    step: 1.0
                ),
                RevenueDriver(
                    title: "Pricing Power",
                    subtitle: "Price increases captured",
                    unit: .percent,
                    value: 4.0,
                    min: -5.0,
                    max: 15.0,
                    step: 0.5
                ),
                RevenueDriver(
                    title: "New Channels",
                    subtitle: "Revenue from new distribution",
                    unit: .percent,
                    value: 10.0,
                    min: 0.0,
                    max: 30.0,
                    step: 1.0
                ),
            ]
        }
    }
    
    private func assetHeavyDrivers(sector: String) -> [RevenueDriver] {
        if sector.contains("Financial") {
            return [
                RevenueDriver(
                    title: "Loan Growth",
                    subtitle: "Lending portfolio expansion",
                    unit: .percent,
                    value: 6.0,
                    min: -5.0,
                    max: 20.0,
                    step: 1.0
                ),
                RevenueDriver(
                    title: "Net Interest Margin",
                    subtitle: "Spread on lending activities",
                    unit: .percent,
                    value: 3.2,
                    min: 2.0,
                    max: 5.0,
                    step: 0.1
                ),
                RevenueDriver(
                    title: "Fee Income Growth",
                    subtitle: "Non-interest revenue expansion",
                    unit: .percent,
                    value: 8.0,
                    min: -5.0,
                    max: 20.0,
                    step: 1.0
                ),
            ]
        } else {
            return [
                RevenueDriver(
                    title: "Capacity Utilization",
                    subtitle: "Asset productivity improvement",
                    unit: .percent,
                    value: 75.0,
                    min: 50.0,
                    max: 95.0,
                    step: 1.0
                ),
                RevenueDriver(
                    title: "Pricing Growth",
                    subtitle: "Rate per unit of capacity",
                    unit: .percent,
                    value: 5.0,
                    min: -10.0,
                    max: 20.0,
                    step: 1.0
                ),
                RevenueDriver(
                    title: "Asset Base Growth",
                    subtitle: "New capacity coming online",
                    unit: .percent,
                    value: 8.0,
                    min: 0.0,
                    max: 25.0,
                    step: 1.0
                ),
            ]
        }
    }
    
    private func platformDrivers() -> [RevenueDriver] {
        [
            RevenueDriver(
                title: "Active Users",
                subtitle: "Growth in active user base",
                unit: .percent,
                value: 18.0,
                min: -5.0,
                max: 50.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "Monetization Rate",
                subtitle: "Revenue per active user",
                unit: .percent,
                value: 12.0,
                min: -10.0,
                max: 35.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "Network Effects",
                subtitle: "Value multiplier from scale",
                unit: .multiple,
                value: 1.15,
                min: 0.90,
                max: 1.40,
                step: 0.05
            ),
        ]
    }
    
    private func advertisingDrivers() -> [RevenueDriver] {
        [
            RevenueDriver(
                title: "Impressions Growth",
                subtitle: "Ad inventory expansion",
                unit: .percent,
                value: 14.0,
                min: -10.0,
                max: 40.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "CPM Growth",
                subtitle: "Cost per thousand impressions",
                unit: .percent,
                value: 6.0,
                min: -15.0,
                max: 25.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "Ad Load Increase",
                subtitle: "More ads per user session",
                unit: .percent,
                value: 8.0,
                min: 0.0,
                max: 20.0,
                step: 1.0
            ),
        ]
    }
    
    private func genericDrivers() -> [RevenueDriver] {
        [
            RevenueDriver(
                title: "Revenue Growth",
                subtitle: "Year-over-year top-line growth",
                unit: .percent,
                value: 10.0,
                min: -10.0,
                max: 40.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "Market Share Gain",
                subtitle: "Share of addressable market",
                unit: .percent,
                value: 5.0,
                min: -5.0,
                max: 20.0,
                step: 1.0
            ),
            RevenueDriver(
                title: "Product Mix Shift",
                subtitle: "Higher-value product adoption",
                unit: .percent,
                value: 7.0,
                min: -10.0,
                max: 25.0,
                step: 1.0
            ),
        ]
    }
}
