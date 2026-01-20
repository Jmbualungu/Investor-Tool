//
//  MockCompanyContextProvider.swift
//  Investor Tool
//
//  Mock provider with realistic archetypes for company context data
//  No network calls - deterministic mock data for development
//

import Foundation

final class MockCompanyContextProvider: CompanyContextProviding {
    
    func fetchCompanyContext(ticker: String) async throws -> CompanyContextModel {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        
        // Determine archetype based on ticker
        let archetype = determineArchetype(ticker: ticker)
        
        return generateContextModel(ticker: ticker, archetype: archetype)
    }
    
    // MARK: - Archetype Determination
    
    private enum Archetype {
        case consumerTech      // AAPL, TSLA
        case enterpriseSaaS    // MSFT, CRM
        case commerceCloud     // AMZN, GOOGL
        case cyclicalManufacturing // F, BA
        case generic
    }
    
    private func determineArchetype(ticker: String) -> Archetype {
        let symbol = ticker.uppercased()
        
        switch symbol {
        case "AAPL", "TSLA", "NVDA":
            return .consumerTech
        case "MSFT", "CRM", "NOW", "ADBE":
            return .enterpriseSaaS
        case "AMZN", "GOOGL", "META", "NFLX":
            return .commerceCloud
        case "F", "BA", "CAT", "DE":
            return .cyclicalManufacturing
        default:
            return .generic
        }
    }
    
    // MARK: - Model Generation
    
    private func generateContextModel(ticker: String, archetype: Archetype) -> CompanyContextModel {
        let symbol = ticker.uppercased()
        
        switch archetype {
        case .consumerTech:
            return generateConsumerTechContext(ticker: symbol)
        case .enterpriseSaaS:
            return generateEnterpriseSaaSContext(ticker: symbol)
        case .commerceCloud:
            return generateCommerceCloudContext(ticker: symbol)
        case .cyclicalManufacturing:
            return generateCyclicalManufacturingContext(ticker: symbol)
        case .generic:
            return generateGenericContext(ticker: symbol)
        }
    }
    
    // MARK: - Consumer Tech Archetype
    
    private func generateConsumerTechContext(ticker: String) -> CompanyContextModel {
        CompanyContextModel(
            ticker: ticker,
            companyName: getCompanyName(ticker: ticker),
            sector: "Technology",
            industry: "Consumer Electronics",
            tags: ["Innovation", "Platform", "Ecosystem", "Brand"],
            snapshot: SnapshotModel(
                currentPrice: 185.50,
                marketCap: 2_850_000_000_000, // $2.85T
                dayChangeAbs: 2.35,
                dayChangePct: 1.28,
                description: "Leading consumer technology company with integrated hardware, software, and services ecosystem. Known for premium design and vertical integration.",
                geography: "Global (Americas 40%, Europe 25%, Greater China 20%, Rest of Asia 15%)",
                businessModel: "Hardware sales + Services subscription + Platform fees",
                lifecycle: "Mature with growth pockets"
            ),
            heatMap: HeatMapModel(
                rows: [
                    HeatMapRow(
                        id: "growth",
                        title: "Revenue Growth",
                        subtitle: "Historical trajectory",
                        values: [
                            HeatMapCell(id: "1y", score: 0.65, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.72, label: "Med-High"),
                            HeatMapCell(id: "5y", score: 0.58, label: "Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "margins",
                        title: "Profit Margins",
                        subtitle: "Operating efficiency",
                        values: [
                            HeatMapCell(id: "1y", score: 0.88, label: "High"),
                            HeatMapCell(id: "3y", score: 0.85, label: "High"),
                            HeatMapCell(id: "5y", score: 0.82, label: "High")
                        ]
                    ),
                    HeatMapRow(
                        id: "volatility",
                        title: "Revenue Volatility",
                        subtitle: "Cyclical sensitivity",
                        values: [
                            HeatMapCell(id: "1y", score: 0.35, label: "Low-Med"),
                            HeatMapCell(id: "3y", score: 0.42, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.38, label: "Low-Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "cashflow",
                        title: "FCF Conversion",
                        subtitle: "Cash generation power",
                        values: [
                            HeatMapCell(id: "1y", score: 0.92, label: "High"),
                            HeatMapCell(id: "3y", score: 0.90, label: "High"),
                            HeatMapCell(id: "5y", score: 0.88, label: "High")
                        ]
                    )
                ],
                columns: ["1Y", "3Y", "5Y"]
            ),
            revenueDrivers: [
                DriverModel(
                    id: "units",
                    title: "Unit Sales Growth",
                    subtitle: "Hardware device volume",
                    sensitivity: "High"
                ),
                DriverModel(
                    id: "asp",
                    title: "Average Selling Price",
                    subtitle: "Premium product mix shift",
                    sensitivity: "Med"
                ),
                DriverModel(
                    id: "services",
                    title: "Services Attach Rate",
                    subtitle: "Subscription penetration",
                    sensitivity: "High"
                ),
                DriverModel(
                    id: "wearables",
                    title: "Wearables & Accessories",
                    subtitle: "Ecosystem expansion",
                    sensitivity: "Med"
                )
            ],
            competitors: [
                CompetitorModel(id: "1", name: "Samsung", relativeScale: "Similar", note: "Broader product range"),
                CompetitorModel(id: "2", name: "Microsoft", relativeScale: "Similar", note: "Ecosystem rival"),
                CompetitorModel(id: "3", name: "Alphabet", relativeScale: "Similar", note: "Services & platforms"),
                CompetitorModel(id: "4", name: "Amazon", relativeScale: "Similar", note: "Services & devices")
            ],
            risks: [
                RiskModel(
                    id: "1",
                    title: "Product Cycle Dependency",
                    detail: "Revenue highly tied to annual iPhone refresh cycles and consumer upgrade patterns",
                    impact: "High"
                ),
                RiskModel(
                    id: "2",
                    title: "Regulatory Scrutiny",
                    detail: "App Store policies under antitrust review in multiple jurisdictions",
                    impact: "Med"
                ),
                RiskModel(
                    id: "3",
                    title: "Supply Chain Concentration",
                    detail: "Heavy reliance on Asia-Pacific manufacturing, geopolitical risks",
                    impact: "Med"
                ),
                RiskModel(
                    id: "4",
                    title: "Market Saturation",
                    detail: "Smartphone penetration plateauing in key developed markets",
                    impact: "Med-High"
                )
            ],
            framing: "Think of this as a mature platform play with recurring services growth layered on top of cyclical hardware sales. The ecosystem lock-in is the moat — valuation hinges on services penetration and premium pricing power."
        )
    }
    
    // MARK: - Enterprise SaaS Archetype
    
    private func generateEnterpriseSaaSContext(ticker: String) -> CompanyContextModel {
        CompanyContextModel(
            ticker: ticker,
            companyName: getCompanyName(ticker: ticker),
            sector: "Technology",
            industry: "Enterprise Software",
            tags: ["SaaS", "Recurring Revenue", "Cloud", "B2B"],
            snapshot: SnapshotModel(
                currentPrice: 415.80,
                marketCap: 3_100_000_000_000, // $3.1T
                dayChangeAbs: 5.20,
                dayChangePct: 1.27,
                description: "Cloud-first enterprise software leader with dominant position in productivity, cloud infrastructure, and business applications.",
                geography: "Global (US 50%, EMEA 28%, Asia Pacific 15%, Other 7%)",
                businessModel: "Subscription SaaS + Cloud consumption + Enterprise licensing",
                lifecycle: "Mature with cloud transition growth"
            ),
            heatMap: HeatMapModel(
                rows: [
                    HeatMapRow(
                        id: "growth",
                        title: "Revenue Growth",
                        subtitle: "Historical trajectory",
                        values: [
                            HeatMapCell(id: "1y", score: 0.70, label: "Med-High"),
                            HeatMapCell(id: "3y", score: 0.75, label: "High"),
                            HeatMapCell(id: "5y", score: 0.68, label: "Med-High")
                        ]
                    ),
                    HeatMapRow(
                        id: "margins",
                        title: "Profit Margins",
                        subtitle: "Operating efficiency",
                        values: [
                            HeatMapCell(id: "1y", score: 0.82, label: "High"),
                            HeatMapCell(id: "3y", score: 0.80, label: "High"),
                            HeatMapCell(id: "5y", score: 0.75, label: "Med-High")
                        ]
                    ),
                    HeatMapRow(
                        id: "volatility",
                        title: "Revenue Volatility",
                        subtitle: "Cyclical sensitivity",
                        values: [
                            HeatMapCell(id: "1y", score: 0.18, label: "Low"),
                            HeatMapCell(id: "3y", score: 0.22, label: "Low"),
                            HeatMapCell(id: "5y", score: 0.25, label: "Low-Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "cashflow",
                        title: "FCF Conversion",
                        subtitle: "Cash generation power",
                        values: [
                            HeatMapCell(id: "1y", score: 0.85, label: "High"),
                            HeatMapCell(id: "3y", score: 0.82, label: "High"),
                            HeatMapCell(id: "5y", score: 0.78, label: "Med-High")
                        ]
                    )
                ],
                columns: ["1Y", "3Y", "5Y"]
            ),
            revenueDrivers: [
                DriverModel(
                    id: "cloudgrowth",
                    title: "Cloud Revenue Growth",
                    subtitle: "Azure & cloud services expansion",
                    sensitivity: "High"
                ),
                DriverModel(
                    id: "seatexpansion",
                    title: "Seat Expansion",
                    subtitle: "M365 user growth & ARPU",
                    sensitivity: "Med"
                ),
                DriverModel(
                    id: "retention",
                    title: "Net Retention Rate",
                    subtitle: "Enterprise account expansion",
                    sensitivity: "Med-High"
                ),
                DriverModel(
                    id: "newproducts",
                    title: "New Product Adoption",
                    subtitle: "AI & emerging solutions",
                    sensitivity: "Med"
                )
            ],
            competitors: [
                CompetitorModel(id: "1", name: "Amazon (AWS)", relativeScale: "Similar", note: "Cloud infrastructure leader"),
                CompetitorModel(id: "2", name: "Google Cloud", relativeScale: "Smaller", note: "Cloud & productivity rival"),
                CompetitorModel(id: "3", name: "Salesforce", relativeScale: "Smaller", note: "CRM & enterprise apps"),
                CompetitorModel(id: "4", name: "Oracle", relativeScale: "Smaller", note: "Database & enterprise software")
            ],
            risks: [
                RiskModel(
                    id: "1",
                    title: "Cloud Margin Pressure",
                    detail: "Intense price competition in cloud infrastructure, margin compression risk",
                    impact: "Med"
                ),
                RiskModel(
                    id: "2",
                    title: "Enterprise IT Budget Cycles",
                    detail: "Vulnerable to enterprise spending pullbacks during macro slowdowns",
                    impact: "Med"
                ),
                RiskModel(
                    id: "3",
                    title: "Security & Compliance",
                    detail: "Increasing scrutiny on data privacy, security breaches can erode trust",
                    impact: "Med-High"
                ),
                RiskModel(
                    id: "4",
                    title: "Legacy Revenue Decline",
                    detail: "On-premise licensing revenue declining faster than cloud growth",
                    impact: "Low-Med"
                )
            ],
            framing: "This is a compounding story: sticky recurring revenue with expanding margins as cloud scale kicks in. The moat is enterprise lock-in and cross-sell opportunity. Model it as ARR growth × expanding take rate."
        )
    }
    
    // MARK: - Commerce + Cloud Archetype
    
    private func generateCommerceCloudContext(ticker: String) -> CompanyContextModel {
        CompanyContextModel(
            ticker: ticker,
            companyName: getCompanyName(ticker: ticker),
            sector: "Consumer Discretionary",
            industry: "Internet Retail & Cloud Services",
            tags: ["E-commerce", "Cloud", "Two-sided Market", "Logistics"],
            snapshot: SnapshotModel(
                currentPrice: 178.25,
                marketCap: 1_850_000_000_000, // $1.85T
                dayChangeAbs: -1.85,
                dayChangePct: -1.03,
                description: "Diversified platform spanning e-commerce marketplace, cloud infrastructure, digital advertising, and logistics.",
                geography: "Global (North America 60%, International 30%, AWS Global 10%)",
                businessModel: "Marketplace fees + AWS consumption + Advertising + Subscriptions",
                lifecycle: "Mature with emerging segment growth"
            ),
            heatMap: HeatMapModel(
                rows: [
                    HeatMapRow(
                        id: "growth",
                        title: "Revenue Growth",
                        subtitle: "Historical trajectory",
                        values: [
                            HeatMapCell(id: "1y", score: 0.58, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.68, label: "Med-High"),
                            HeatMapCell(id: "5y", score: 0.78, label: "High")
                        ]
                    ),
                    HeatMapRow(
                        id: "margins",
                        title: "Profit Margins",
                        subtitle: "Operating efficiency",
                        values: [
                            HeatMapCell(id: "1y", score: 0.55, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.52, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.48, label: "Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "volatility",
                        title: "Revenue Volatility",
                        subtitle: "Cyclical sensitivity",
                        values: [
                            HeatMapCell(id: "1y", score: 0.52, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.48, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.45, label: "Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "cashflow",
                        title: "FCF Conversion",
                        subtitle: "Cash generation power",
                        values: [
                            HeatMapCell(id: "1y", score: 0.68, label: "Med-High"),
                            HeatMapCell(id: "3y", score: 0.65, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.60, label: "Med")
                        ]
                    )
                ],
                columns: ["1Y", "3Y", "5Y"]
            ),
            revenueDrivers: [
                DriverModel(
                    id: "gmv",
                    title: "Gross Merchandise Value",
                    subtitle: "E-commerce marketplace volume",
                    sensitivity: "High"
                ),
                DriverModel(
                    id: "cloudgrowth",
                    title: "AWS Revenue Growth",
                    subtitle: "Cloud infrastructure expansion",
                    sensitivity: "High"
                ),
                DriverModel(
                    id: "advertising",
                    title: "Advertising Revenue",
                    subtitle: "Sponsored products & display ads",
                    sensitivity: "Med-High"
                ),
                DriverModel(
                    id: "international",
                    title: "International Penetration",
                    subtitle: "Geographic expansion",
                    sensitivity: "Med"
                )
            ],
            competitors: [
                CompetitorModel(id: "1", name: "Walmart", relativeScale: "Similar", note: "Omnichannel retail"),
                CompetitorModel(id: "2", name: "Alibaba", relativeScale: "Similar", note: "China e-commerce leader"),
                CompetitorModel(id: "3", name: "Microsoft (Azure)", relativeScale: "Similar", note: "Cloud infrastructure"),
                CompetitorModel(id: "4", name: "Shopify", relativeScale: "Smaller", note: "Merchant platform")
            ],
            risks: [
                RiskModel(
                    id: "1",
                    title: "Regulatory Pressure",
                    detail: "Antitrust scrutiny on marketplace practices and competitive conduct",
                    impact: "High"
                ),
                RiskModel(
                    id: "2",
                    title: "Capex Intensity",
                    detail: "Heavy investment in fulfillment centers and logistics infrastructure",
                    impact: "Med-High"
                ),
                RiskModel(
                    id: "3",
                    title: "Labor & Unionization",
                    detail: "Rising labor costs, unionization efforts in fulfillment network",
                    impact: "Med"
                ),
                RiskModel(
                    id: "4",
                    title: "AWS Margin Compression",
                    detail: "Cloud price competition and infrastructure investment drag on margins",
                    impact: "Med"
                )
            ],
            framing: "A conglomerate play: low-margin retail subsidized by high-margin AWS cash flow. Value the segments separately — AWS is the crown jewel. Model retail as scale play with improving mix shift toward advertising."
        )
    }
    
    // MARK: - Cyclical Manufacturing Archetype
    
    private func generateCyclicalManufacturingContext(ticker: String) -> CompanyContextModel {
        CompanyContextModel(
            ticker: ticker,
            companyName: getCompanyName(ticker: ticker),
            sector: "Industrials",
            industry: "Automotive Manufacturing",
            tags: ["Cyclical", "Capital Intensive", "Commodity", "Legacy"],
            snapshot: SnapshotModel(
                currentPrice: 12.45,
                marketCap: 49_500_000_000, // $49.5B
                dayChangeAbs: -0.32,
                dayChangePct: -2.51,
                description: "Traditional automotive manufacturer navigating industry shift to electric vehicles and autonomous technology.",
                geography: "Global (North America 55%, Europe 25%, China 15%, Other 5%)",
                businessModel: "Vehicle sales + Financing + Aftermarket parts",
                lifecycle: "Mature / Transitioning"
            ),
            heatMap: HeatMapModel(
                rows: [
                    HeatMapRow(
                        id: "growth",
                        title: "Revenue Growth",
                        subtitle: "Historical trajectory",
                        values: [
                            HeatMapCell(id: "1y", score: 0.35, label: "Low-Med"),
                            HeatMapCell(id: "3y", score: 0.28, label: "Low"),
                            HeatMapCell(id: "5y", score: 0.32, label: "Low-Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "margins",
                        title: "Profit Margins",
                        subtitle: "Operating efficiency",
                        values: [
                            HeatMapCell(id: "1y", score: 0.38, label: "Low-Med"),
                            HeatMapCell(id: "3y", score: 0.35, label: "Low-Med"),
                            HeatMapCell(id: "5y", score: 0.30, label: "Low")
                        ]
                    ),
                    HeatMapRow(
                        id: "volatility",
                        title: "Revenue Volatility",
                        subtitle: "Cyclical sensitivity",
                        values: [
                            HeatMapCell(id: "1y", score: 0.78, label: "High"),
                            HeatMapCell(id: "3y", score: 0.82, label: "High"),
                            HeatMapCell(id: "5y", score: 0.85, label: "High")
                        ]
                    ),
                    HeatMapRow(
                        id: "cashflow",
                        title: "FCF Conversion",
                        subtitle: "Cash generation power",
                        values: [
                            HeatMapCell(id: "1y", score: 0.42, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.38, label: "Low-Med"),
                            HeatMapCell(id: "5y", score: 0.35, label: "Low-Med")
                        ]
                    )
                ],
                columns: ["1Y", "3Y", "5Y"]
            ),
            revenueDrivers: [
                DriverModel(
                    id: "volume",
                    title: "Vehicle Unit Volume",
                    subtitle: "Production & sales volume",
                    sensitivity: "High"
                ),
                DriverModel(
                    id: "mix",
                    title: "Product Mix Shift",
                    subtitle: "Truck/SUV vs sedan mix",
                    sensitivity: "High"
                ),
                DriverModel(
                    id: "pricing",
                    title: "Pricing Power",
                    subtitle: "Net transaction price",
                    sensitivity: "Med"
                ),
                DriverModel(
                    id: "financing",
                    title: "Financing Penetration",
                    subtitle: "Captive finance attachment",
                    sensitivity: "Low-Med"
                )
            ],
            competitors: [
                CompetitorModel(id: "1", name: "General Motors", relativeScale: "Similar", note: "Domestic rival"),
                CompetitorModel(id: "2", name: "Toyota", relativeScale: "Larger", note: "Global market leader"),
                CompetitorModel(id: "3", name: "Tesla", relativeScale: "Smaller", note: "EV disruptor"),
                CompetitorModel(id: "4", name: "Stellantis", relativeScale: "Similar", note: "Global OEM")
            ],
            risks: [
                RiskModel(
                    id: "1",
                    title: "EV Transition Risk",
                    detail: "Heavy capex required for electrification, uncertain demand trajectory",
                    impact: "High"
                ),
                RiskModel(
                    id: "2",
                    title: "Cyclical Demand",
                    detail: "Highly sensitive to consumer confidence and interest rates",
                    impact: "High"
                ),
                RiskModel(
                    id: "3",
                    title: "Supply Chain Disruptions",
                    detail: "Semiconductor shortages, commodity price volatility",
                    impact: "Med-High"
                ),
                RiskModel(
                    id: "4",
                    title: "Legacy Cost Structure",
                    detail: "High fixed costs, pension obligations, dealer network",
                    impact: "Med"
                )
            ],
            framing: "This is a value/turnaround bet, not a growth story. Model through-the-cycle earnings power and apply trough multiples. The key risk is whether legacy OEMs can compete in the EV era — assume elevated capex for 5+ years."
        )
    }
    
    // MARK: - Generic Archetype
    
    private func generateGenericContext(ticker: String) -> CompanyContextModel {
        CompanyContextModel(
            ticker: ticker,
            companyName: getCompanyName(ticker: ticker),
            sector: "Diversified",
            industry: "General Business",
            tags: ["Growth", "Established", "Diversified"],
            snapshot: SnapshotModel(
                currentPrice: 125.00,
                marketCap: 500_000_000_000, // $500B
                dayChangeAbs: 0.75,
                dayChangePct: 0.60,
                description: "Diversified company with operations across multiple business segments and geographies.",
                geography: "Global (Diversified)",
                businessModel: "Diversified revenue streams",
                lifecycle: "Mature"
            ),
            heatMap: HeatMapModel(
                rows: [
                    HeatMapRow(
                        id: "growth",
                        title: "Revenue Growth",
                        subtitle: "Historical trajectory",
                        values: [
                            HeatMapCell(id: "1y", score: 0.50, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.52, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.48, label: "Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "margins",
                        title: "Profit Margins",
                        subtitle: "Operating efficiency",
                        values: [
                            HeatMapCell(id: "1y", score: 0.55, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.53, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.52, label: "Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "volatility",
                        title: "Revenue Volatility",
                        subtitle: "Cyclical sensitivity",
                        values: [
                            HeatMapCell(id: "1y", score: 0.45, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.42, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.40, label: "Med")
                        ]
                    ),
                    HeatMapRow(
                        id: "cashflow",
                        title: "FCF Conversion",
                        subtitle: "Cash generation power",
                        values: [
                            HeatMapCell(id: "1y", score: 0.60, label: "Med"),
                            HeatMapCell(id: "3y", score: 0.58, label: "Med"),
                            HeatMapCell(id: "5y", score: 0.56, label: "Med")
                        ]
                    )
                ],
                columns: ["1Y", "3Y", "5Y"]
            ),
            revenueDrivers: [
                DriverModel(
                    id: "market",
                    title: "Market Share Gains",
                    subtitle: "Competitive positioning",
                    sensitivity: "Med"
                ),
                DriverModel(
                    id: "pricing",
                    title: "Pricing Power",
                    subtitle: "Price realization vs inflation",
                    sensitivity: "Med"
                ),
                DriverModel(
                    id: "expansion",
                    title: "Geographic Expansion",
                    subtitle: "International growth",
                    sensitivity: "Med"
                ),
                DriverModel(
                    id: "newproducts",
                    title: "New Product Mix",
                    subtitle: "Innovation & portfolio refresh",
                    sensitivity: "Low-Med"
                )
            ],
            competitors: [
                CompetitorModel(id: "1", name: "Industry Peer A", relativeScale: "Similar", note: nil),
                CompetitorModel(id: "2", name: "Industry Peer B", relativeScale: "Larger", note: nil),
                CompetitorModel(id: "3", name: "Industry Peer C", relativeScale: "Smaller", note: nil)
            ],
            risks: [
                RiskModel(
                    id: "1",
                    title: "Market Competition",
                    detail: "Competitive pressure from established players and new entrants",
                    impact: "Med"
                ),
                RiskModel(
                    id: "2",
                    title: "Economic Sensitivity",
                    detail: "Revenue exposed to macroeconomic cycles and consumer spending",
                    impact: "Med"
                ),
                RiskModel(
                    id: "3",
                    title: "Operational Execution",
                    detail: "Ability to deliver on strategic initiatives and margin expansion",
                    impact: "Med"
                )
            ],
            framing: "A balanced play with moderate growth potential and stable cash flows. Model as steady-state growth with gradual margin improvement. Focus on sustainable competitive advantages and capital allocation discipline."
        )
    }
    
    // MARK: - Helpers
    
    private func getCompanyName(ticker: String) -> String {
        let names: [String: String] = [
            "AAPL": "Apple Inc.",
            "MSFT": "Microsoft Corporation",
            "AMZN": "Amazon.com, Inc.",
            "GOOGL": "Alphabet Inc.",
            "TSLA": "Tesla, Inc.",
            "META": "Meta Platforms, Inc.",
            "NVDA": "NVIDIA Corporation",
            "CRM": "Salesforce, Inc.",
            "NOW": "ServiceNow, Inc.",
            "ADBE": "Adobe Inc.",
            "NFLX": "Netflix, Inc.",
            "F": "Ford Motor Company",
            "BA": "The Boeing Company",
            "CAT": "Caterpillar Inc.",
            "DE": "Deere & Company"
        ]
        
        return names[ticker.uppercased()] ?? "\(ticker.uppercased()) Inc."
    }
}
