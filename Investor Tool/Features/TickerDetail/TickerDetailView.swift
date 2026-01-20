import SwiftUI

struct TickerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TickerDetailViewModel

    init(ticker: Ticker) {
        _viewModel = StateObject(wrappedValue: TickerDetailViewModel(ticker: ticker))
    }

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    headerSection
                    chartSection
                    
                    // Error banner if data fetch failed
                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(errorMessage)
                    }
                    
                    // New enhanced sections
                    if let data = viewModel.tickerDetailData {
                        AboutSectionView(profile: data.profile)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        
                        KeyStatsGridView(stats: data.keyStats)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        
                        NewsSectionView(news: data.news)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                        
                        AnalystRatingsSectionView(consensus: data.analystConsensus, actions: data.analystActions)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    } else if viewModel.isLoading {
                        // Show loading placeholders
                        loadingPlaceholders
                    }
                    
                    // Existing sections below
                    relatedListsSection
                    peopleAlsoOwnSection
                    earningsSection
                    shortInterestSection
                }
                .padding(.horizontal, DSSpacing.l)
                .padding(.bottom, 160)
            }
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0)
            }

            bottomOverlay
        }
        .navigationBarHidden(true)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DSColors.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(DSColors.surface)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Back")

                Spacer()

                HStack(spacing: DSSpacing.s) {
                    Image(systemName: "bell")
                    Image(systemName: "ellipsis")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
            }

            Text(viewModel.ticker)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(DSColors.textPrimary)

            Text(viewModel.companyName)
                .dsCaption()

            Text(Formatters.currency(viewModel.price))
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundColor(DSColors.textPrimary)

            HStack(spacing: DSSpacing.s) {
                Text(changeText(value: viewModel.changeToday, percent: viewModel.changeTodayPercent))
                    .foregroundColor(changeColor(for: viewModel.changeToday))
                Text("Today")
                    .dsCaption()
            }

            HStack(spacing: DSSpacing.s) {
                Text(afterHoursText(value: viewModel.changeAfterHours, percent: viewModel.changeAfterHoursPercent))
                    .foregroundColor(changeColor(for: viewModel.changeAfterHours))
                Text("After hours")
                    .dsCaption()
            }
        }
        .padding(.top, DSSpacing.l)
    }

    private var chartSection: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                LineChartView(data: viewModel.currentChartData, lineColor: DSColors.textPrimary)

                HStack {
                    timeframeSelector
                    Spacer()
                    Button(action: {}) {
                        Text("Advanced")
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textPrimary)
                            .padding(.horizontal, DSSpacing.m)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                                    .stroke(DSColors.border, lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Advanced chart options")
                }
            }
        }
    }

    private var timeframeSelector: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(ChartTimeframe.allCases) { timeframe in
                DSPillChip(
                    title: timeframe.rawValue,
                    isSelected: viewModel.selectedTimeframe == timeframe
                ) {
                    viewModel.selectedTimeframe = timeframe
                }
                .accessibilityLabel("\(timeframe.rawValue) timeframe")
            }
        }
    }

    private var relatedListsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "Related lists")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.s) {
                    ForEach(viewModel.relatedLists, id: \.self) { list in
                        DSPillChip(title: list, icon: "sparkles")
                    }
                }
            }
        }
    }

    private var peopleAlsoOwnSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "People also own")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.m) {
                    ForEach(viewModel.peopleAlsoOwn) { peer in
                        DSCard {
                            VStack(alignment: .leading, spacing: DSSpacing.s) {
                                Text(peer.companyName)
                                    .dsHeadline()
                                Text(peer.ticker)
                                    .dsCaption()
                                Text(percentChangeText(peer.percentChange))
                                    .font(DSTypography.headline)
                                    .foregroundColor(changeColor(for: peer.percentChange))
                            }
                        }
                        .frame(width: 160)
                    }
                }
            }
        }
    }

    private var earningsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "Earnings")
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    EarningsDotChartView(points: viewModel.earnings)
                    Text("Estimated EPS $0.40")
                        .dsCaption()
                    Text("Actual EPS Available on 1/28 After-hours")
                        .dsCaption()
                }
            }

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    Text("Shareholder Q&As")
                        .dsHeadline()
                    ForEach(viewModel.qas) { qa in
                        HStack(spacing: DSSpacing.m) {
                            Text(qa.dateLabel)
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textSecondary)
                                .padding(.horizontal, DSSpacing.s)
                                .padding(.vertical, 6)
                                .background(DSColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(qa.title)
                                    .dsBody()
                                Text("\(qa.questionsAnswered) questions answered")
                                    .dsCaption()
                            }
                            Spacer()
                        }
                        .accessibilityLabel("\(qa.title), \(qa.questionsAnswered) questions answered")
                    }
                }
            }
        }
    }

    private var shortInterestSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "Short interest")
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    ShortInterestChartView(points: viewModel.shortInterestSeries)
                    Text("Short interest % with days to cover line")
                        .dsCaption()
                }
            }

            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    HStack {
                        Text(viewModel.researchReport.provider)
                            .dsHeadline()
                        Spacer()
                        Text(viewModel.researchReport.updatedDate)
                            .dsCaption()
                    }

                    HStack(spacing: 4) {
                        ForEach(0..<viewModel.researchReport.ratingMax, id: \.self) { index in
                            Image(systemName: index < viewModel.researchReport.rating ? "star.fill" : "star")
                                .font(.system(size: 12))
                                .foregroundColor(DSColors.accent)
                        }
                        Text("\(viewModel.researchReport.rating)/\(viewModel.researchReport.ratingMax)")
                            .dsCaption()
                    }

                    HStack {
                        Text("Economic moat")
                            .dsCaption()
                        Spacer()
                        Text(viewModel.researchReport.moat)
                            .dsBody()
                    }

                    HStack {
                        Text("Fair value")
                            .dsCaption()
                        Spacer()
                        Text(viewModel.researchReport.fairValue)
                            .dsBody()
                    }
                }
            }
        }
    }

    private var loadingPlaceholders: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xl) {
            // About placeholder
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                DSSectionHeader(title: "About")
                DSCard {
                    VStack(alignment: .leading, spacing: DSSpacing.m) {
                        Text("Loading company information...")
                            .dsBody()
                        Rectangle()
                            .fill(DSColors.surface)
                            .frame(height: 60)
                    }
                }
            }
            .redacted(reason: .placeholder)
            
            // Stats placeholder
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                DSSectionHeader(title: "Key Stats")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.s) {
                    ForEach(0..<6) { _ in
                        DSStatCell(label: "Loading", value: "N/A")
                    }
                }
            }
            .redacted(reason: .placeholder)
            
            // News placeholder
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                DSSectionHeader(title: "News")
                DSCard {
                    Text("Loading news...")
                        .dsBody()
                }
            }
            .redacted(reason: .placeholder)
            
            // Analyst placeholder
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                DSSectionHeader(title: "Analyst Ratings")
                DSCard {
                    Text("Loading analyst ratings...")
                        .dsBody()
                }
            }
            .redacted(reason: .placeholder)
        }
    }
    
    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: DSSpacing.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(DSColors.accent)
            Text(message)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textPrimary)
        }
        .padding(DSSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColors.accent.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusStandard, style: .continuous))
    }

    private var tradingTrendsSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            Text("Trading Trends")
                .dsHeadline()

            HStack(spacing: DSSpacing.s) {
                ForEach(TradingTrendOption.allCases) { option in
                    DSPillChip(
                        title: option.rawValue,
                        isSelected: viewModel.tradingTrendSelection == option
                    ) {
                        viewModel.tradingTrendSelection = option
                    }
                }
            }

            RoundedRectangle(cornerRadius: DSSpacing.radiusLarge, style: .continuous)
                .fill(DSColors.surface)
                .frame(height: 140)
                .overlay(
                    Text("Trend chart placeholder")
                        .dsCaption()
                )
                .accessibilityLabel("Trading trends chart")
        }
    }

    private var bottomOverlay: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: DSSpacing.s) {
                HStack {
                    Text("Today's volume")
                        .dsCaption()
                    Spacer()
                    Text("84,216,300")
                        .dsCaption()
                }
                .padding(.horizontal, DSSpacing.l)

                DSPrimaryButton("Trade") {}
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.bottom, DSSpacing.s)

                DSTabBar()
            }
            .background(DSColors.background.opacity(0.98))
        }
    }

    private func changeColor(for value: Double) -> Color {
        value >= 0 ? DSColors.positive : DSColors.negative
    }

    private func changeText(value: Double, percent: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value)) (\(sign)\(String(format: "%.2f", percent))%)"
    }

    private func afterHoursText(value: Double, percent: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value)) (\(sign)\(String(format: "%.2f", percent))%)"
    }

    private func percentChangeText(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
}

struct TickerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TickerDetailView(ticker: Ticker(symbol: "TSLA", name: "Tesla, Inc."))
        }
    }
}
