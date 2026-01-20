import SwiftUI

struct AnalystRatingsSectionView: View {
    let consensus: AnalystConsensus
    let actions: [AnalystAction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "Analyst Ratings")
            
            if consensus.total == 0 {
                DSCard {
                    Text("No analyst ratings available")
                        .dsBody()
                        .foregroundColor(DSColors.textSecondary)
                }
            } else {
                consensusSummaryCard
                
                if !actions.isEmpty {
                    analystActionsList
                }
            }
        }
    }
    
    private var consensusSummaryCard: some View {
        DSCard {
            VStack(alignment: .leading, spacing: DSSpacing.m) {
                Text("\(consensus.total) Analyst Ratings")
                    .dsHeadline()
                
                // Five-tier progress bars
                VStack(spacing: DSSpacing.s) {
                    ratingProgressBar(
                        label: "Strong Buy",
                        count: consensus.strongBuy,
                        percentage: consensus.strongBuyPercent,
                        color: Color(red: 0.0, green: 0.6, blue: 0.3)
                    )
                    
                    ratingProgressBar(
                        label: "Buy",
                        count: consensus.buy,
                        percentage: consensus.buyPercent,
                        color: DSColors.positive
                    )
                    
                    ratingProgressBar(
                        label: "Hold",
                        count: consensus.hold,
                        percentage: consensus.holdPercent,
                        color: DSColors.textSecondary
                    )
                    
                    ratingProgressBar(
                        label: "Sell",
                        count: consensus.sell,
                        percentage: consensus.sellPercent,
                        color: Color(red: 0.98, green: 0.54, blue: 0.14)
                    )
                    
                    ratingProgressBar(
                        label: "Strong Sell",
                        count: consensus.strongSell,
                        percentage: consensus.strongSellPercent,
                        color: DSColors.negative
                    )
                }
                
                // Price targets if available
                if let avgTarget = consensus.avgPriceTarget,
                   let highTarget = consensus.highPriceTarget,
                   let lowTarget = consensus.lowPriceTarget {
                    Divider()
                        .background(DSColors.border)
                        .padding(.vertical, DSSpacing.xs)
                    
                    HStack(spacing: DSSpacing.l) {
                        priceTargetItem(label: "Avg Target", value: avgTarget)
                        priceTargetItem(label: "High", value: highTarget)
                        priceTargetItem(label: "Low", value: lowTarget)
                    }
                }
            }
        }
    }
    
    private func ratingProgressBar(label: String, count: Int, percentage: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text(label)
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
                Spacer()
                Text("\(count)")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textPrimary)
                Text("(\(Int(percentage))%)")
                    .font(DSTypography.caption)
                    .foregroundColor(DSColors.textSecondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DSColors.surface)
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: max(8, CGFloat(percentage / 100) * geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
    
    private func priceTargetItem(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            Text(Formatters.formatCurrency(value))
                .font(DSTypography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(DSColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var analystActionsList: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            Text("Recent Actions")
                .dsHeadline()
                .padding(.top, DSSpacing.s)
            
            ForEach(actions.prefix(50)) { action in
                DSCard {
                    HStack(spacing: DSSpacing.m) {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text(action.firm)
                                .font(DSTypography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(DSColors.textPrimary)
                            
                            HStack(spacing: DSSpacing.s) {
                                ratingBadge(action.rating)
                                Text(Formatters.formatDate(action.date, style: .short))
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColors.textSecondary)
                            }
                            
                            if !action.summary.isEmpty {
                                Text(action.summary)
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColors.textSecondary)
                                    .lineLimit(2)
                                    .padding(.top, 2)
                            }
                        }
                        
                        Spacer()
                        
                        if let target = action.priceTarget {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("PT")
                                    .font(DSTypography.caption)
                                    .foregroundColor(DSColors.textSecondary)
                                Text(Formatters.formatCurrency(target))
                                    .font(DSTypography.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(DSColors.textPrimary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func ratingBadge(_ rating: AnalystRating) -> some View {
        let (color, backgroundColor) = ratingColors(rating)
        
        return Text(rating.rawValue)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
    
    private func ratingColors(_ rating: AnalystRating) -> (Color, Color) {
        switch rating {
        case .strongBuy:
            return (Color(red: 0.0, green: 0.6, blue: 0.3), Color(red: 0.0, green: 0.6, blue: 0.3).opacity(0.15))
        case .buy:
            return (DSColors.positive, DSColors.positive.opacity(0.15))
        case .hold:
            return (DSColors.textSecondary, DSColors.textSecondary.opacity(0.15))
        case .sell:
            return (Color(red: 0.98, green: 0.54, blue: 0.14), Color(red: 0.98, green: 0.54, blue: 0.14).opacity(0.15))
        case .strongSell:
            return (DSColors.negative, DSColors.negative.opacity(0.15))
        }
    }
}

struct AnalystRatingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
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
            AnalystAction(
                firm: "Morgan Stanley",
                rating: .strongBuy,
                date: Date().addingTimeInterval(-1 * 86400),
                priceTarget: 230.00,
                summary: "Raised price target on strong services growth"
            ),
            AnalystAction(
                firm: "Goldman Sachs",
                rating: .buy,
                date: Date().addingTimeInterval(-2 * 86400),
                priceTarget: 215.00,
                summary: "Maintains positive outlook on iPhone cycle"
            ),
            AnalystAction(
                firm: "Wells Fargo",
                rating: .hold,
                date: Date().addingTimeInterval(-7 * 86400),
                priceTarget: 195.00,
                summary: "Waiting for clarity on China demand"
            )
        ]
        
        return ScrollView {
            VStack {
                AnalystRatingsSectionView(consensus: consensus, actions: actions)
                    .padding()
            }
        }
        .background(DSColors.background)
    }
}
