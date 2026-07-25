import SwiftUI

// MARK: - Button Press Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Top Mover Chip

struct DSTopMoverChip: View {
    let mover: MoverItem
    
    var body: some View {
        HStack(spacing: 6) {
            // Ticker is primary, semibold
            Text(mover.ticker)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
            
            // Arrow + % grouped together, visually secondary
            HStack(spacing: 3) {
                Image(systemName: mover.percentChange >= 0 ? "triangle.fill" : "triangle.fill")
                    .font(.system(size: 7))
                    .rotationEffect(mover.percentChange >= 0 ? .degrees(0) : .degrees(180))
                    .foregroundColor(changeColor(for: mover.percentChange))
                
                Text(percentText(mover.percentChange))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(changeColor(for: mover.percentChange))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSSpacing.radiusPill, style: .continuous)
                .stroke(DSColors.border, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityLabel("\(mover.ticker) \(percentText(mover.percentChange))")
    }
    
    // Adjust saturation based on magnitude
    private func changeColor(for percentChange: Double) -> Color {
        let magnitude = abs(percentChange)
        let baseColor = percentChange >= 0 ? DSColors.positive : DSColors.negative
        
        if magnitude > 5 {
            return baseColor
        } else if magnitude > 2 {
            return baseColor.opacity(0.85)
        } else {
            return baseColor.opacity(0.7)
        }
    }
    
    private func percentText(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
}

// MARK: - Heatmap Tile

struct DSHeatmapTile: View {
    let tile: SectorTile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Ticker is primary, always readable
            Text(tile.ticker)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(DSColors.textPrimary)
            
            // % is secondary, uses colored text for clarity
            Text(percentText(tile.percentChange))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(changeColor(for: tile.percentChange))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(heatmapColor(for: tile.percentChange))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(DSColors.border.opacity(0.3), lineWidth: 0.5)
        )
        .accessibilityLabel("\(tile.ticker) \(percentText(tile.percentChange))")
    }
    
    private func percentText(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
    
    // Subtle background color that scales with magnitude
    private func heatmapColor(for percentChange: Double) -> Color {
        let magnitude = abs(percentChange)
        let opacity: Double
        
        if magnitude > 5 {
            opacity = 0.25
        } else if magnitude > 2 {
            opacity = 0.18
        } else {
            opacity = 0.12
        }
        
        if percentChange >= 0 {
            return DSColors.positive.opacity(opacity)
        } else {
            return DSColors.negative.opacity(opacity)
        }
    }
    
    // Text color that also scales with magnitude
    private func changeColor(for percentChange: Double) -> Color {
        let magnitude = abs(percentChange)
        let baseColor = percentChange >= 0 ? DSColors.positive : DSColors.negative
        
        if magnitude > 5 {
            return baseColor
        } else if magnitude > 2 {
            return baseColor.opacity(0.9)
        } else {
            return baseColor.opacity(0.75)
        }
    }
}

// MARK: - Future Card

struct DSFutureCard: View {
    let contract: FutureContract
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Symbol + name: tertiary info at top
            VStack(alignment: .leading, spacing: 2) {
                Text(contract.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                
                Text(contract.symbol)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(DSColors.textSecondary.opacity(0.7))
            }
            
            Spacer()
            
            // Price: PRIMARY hierarchy
            Text(priceText(contract.price))
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundColor(DSColors.textPrimary)
            
            // % change: secondary but visible
            HStack(spacing: 4) {
                Image(systemName: contract.percentChange >= 0 ? "triangle.fill" : "triangle.fill")
                    .font(.system(size: 7))
                    .rotationEffect(contract.percentChange >= 0 ? .degrees(0) : .degrees(180))
                    .foregroundColor(changeColor(for: contract.percentChange))
                
                Text(percentText(contract.percentChange))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(changeColor(for: contract.percentChange))
            }
            
            // Sparkline: subtle, decorative
            SparklineView(points: contract.sparklinePoints, color: changeColor(for: contract.percentChange))
                .frame(height: 32)
                .opacity(0.6)
        }
        .padding(14)
        .frame(width: 170, height: 160)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(DSColors.border, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .accessibilityLabel("\(contract.name), \(priceText(contract.price)), \(percentText(contract.percentChange))")
    }
    
    private func priceText(_ price: Double) -> String {
        if price >= 1000 {
            return String(format: "$%.2f", price)
        } else {
            return String(format: "$%.2f", price)
        }
    }
    
    private func percentText(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
    
    private func changeColor(for percentChange: Double) -> Color {
        let magnitude = abs(percentChange)
        let baseColor = percentChange >= 0 ? DSColors.positive : DSColors.negative
        
        if magnitude > 3 {
            return baseColor
        } else if magnitude > 1 {
            return baseColor.opacity(0.85)
        } else {
            return baseColor.opacity(0.7)
        }
    }
}

// MARK: - Sparkline View

struct SparklineView: View {
    let points: [Double]
    var color: Color = DSColors.accent
    
    var body: some View {
        GeometryReader { geometry in
            if !points.isEmpty {
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    guard let minValue = points.min(),
                          let maxValue = points.max(),
                          maxValue > minValue else {
                        return
                    }
                    
                    let xStep = width / CGFloat(points.count - 1)
                    let yRange = maxValue - minValue
                    
                    for (index, point) in points.enumerated() {
                        let x = CGFloat(index) * xStep
                        let normalizedY = (point - minValue) / yRange
                        let y = height - (CGFloat(normalizedY) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                
                // Subtle end dot for visual anchor
                if let lastPoint = points.last,
                   let minValue = points.min(),
                   let maxValue = points.max(),
                   maxValue > minValue {
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let yRange = maxValue - minValue
                    let normalizedY = (lastPoint - minValue) / yRange
                    let y = height - (CGFloat(normalizedY) * height)
                    
                    Circle()
                        .fill(color)
                        .frame(width: 3, height: 3)
                        .position(x: width, y: y)
                }
            }
        }
    }
}

// MARK: - Economic Event Row

struct DSEconomicEventRow: View {
    let event: EconomicEvent
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                // Title is primary
                Text(event.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DSColors.textPrimary)
                
                // Description is secondary
                Text(event.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(DSColors.textSecondary.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Date: tertiary, right-aligned
            Text(dateText(event.date))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DSColors.textSecondary.opacity(0.7))
        }
        .padding(14)
        .background(DSColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(DSColors.border, lineWidth: 0.5)
        )
        .accessibilityLabel("\(event.title) on \(dateText(event.date))")
    }
    
    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Section Header with Info Icon

struct DSBrowseSectionHeader: View {
    let title: String
    let showInfo: Bool
    
    init(title: String, showInfo: Bool = false) {
        self.title = title
        self.showInfo = showInfo
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Section header: clear hierarchy using title3
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
            
            if showInfo {
                Image(systemName: "info.circle")
                    .font(.system(size: 13))
                    .foregroundColor(DSColors.textSecondary.opacity(0.6))
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview Providers

#Preview("Top Mover Chip") {
    ZStack {
        DSColors.background.ignoresSafeArea()
        DSTopMoverChip(mover: MoverItem(
            ticker: "RIOT",
            companyName: "Riot Platforms",
            price: 12.45,
            percentChange: 16.54
        ))
    }
}

#Preview("Heatmap Tile") {
    ZStack {
        DSColors.background.ignoresSafeArea()
        DSHeatmapTile(tile: SectorTile(
            ticker: "NVDA",
            companyName: "NVIDIA",
            percentChange: -0.43,
            sector: .technology
        ))
        .frame(width: 100, height: 60)
    }
}

#Preview("Future Card") {
    ZStack {
        DSColors.background.ignoresSafeArea()
        DSFutureCard(contract: FutureContract(
            name: "S&P 500",
            symbol: "/MESH26",
            price: 6916.00,
            percentChange: -0.87,
            sparklinePoints: [6850, 6870, 6890, 6910, 6905, 6920, 6915, 6916]
        ))
    }
}

#Preview("Economic Event Row") {
    ZStack {
        DSColors.background.ignoresSafeArea()
        DSEconomicEventRow(event: EconomicEvent(
            title: "Fed decision in Jan 2026",
            date: Date(),
            description: "Federal Reserve interest rate decision"
        ))
        .padding()
    }
}
