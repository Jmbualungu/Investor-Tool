import SwiftUI

struct NewsSectionView: View {
    let news: [NewsItemDetail]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "News")
            
            if news.isEmpty {
                DSCard {
                    Text("No news available")
                        .dsBody()
                        .foregroundColor(DSColors.textSecondary)
                }
            } else {
                ForEach(news.prefix(5)) { item in
                    DSCard {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            HStack {
                                Text(item.source)
                                    .dsCaption()
                                Text("• \(Formatters.formatRelativeTime(item.publishedAt))")
                                    .dsCaption()
                                Spacer()
                                if let priceImpact = item.priceImpact {
                                    priceImpactBadge(priceImpact)
                                }
                            }
                            
                            Text(item.title)
                                .dsBody()
                                .lineLimit(3)
                        }
                    }
                }
                
                Button(action: {}) {
                    Text("View more")
                        .font(DSTypography.caption)
                        .foregroundColor(DSColors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.m)
                }
                .accessibilityLabel("View more news")
            }
        }
    }
    
    private func priceImpactBadge(_ impact: Double) -> some View {
        let sign = impact >= 0 ? "+" : ""
        let color = impact >= 0 ? DSColors.positive : DSColors.negative
        
        return Text("\(sign)\(impact.formatted(.number.precision(.fractionLength(1))))%")
            .font(DSTypography.caption)
            .foregroundColor(color)
            .padding(.horizontal, DSSpacing.s)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

struct NewsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let news = [
            NewsItemDetail(
                title: "Apple announces new AI features coming to iOS 18",
                source: "Bloomberg",
                publishedAt: Date().addingTimeInterval(-2 * 3600),
                summary: "Apple unveiled new artificial intelligence features.",
                priceImpact: 1.2
            ),
            NewsItemDetail(
                title: "iPhone sales exceed expectations in Q1",
                source: "CNBC",
                publishedAt: Date().addingTimeInterval(-4 * 3600),
                summary: "Strong iPhone 15 demand drives growth.",
                priceImpact: 0.8
            ),
            NewsItemDetail(
                title: "Apple expands services revenue with new subscription tiers",
                source: "Reuters",
                publishedAt: Date().addingTimeInterval(-6 * 3600),
                summary: "The company introduces new pricing models.",
                priceImpact: nil
            )
        ]
        
        return VStack {
            NewsSectionView(news: news)
                .padding()
        }
        .background(DSColors.background)
    }
}
