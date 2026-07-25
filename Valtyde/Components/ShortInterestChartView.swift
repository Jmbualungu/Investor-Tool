import SwiftUI

struct ShortInterestChartView: View {
    let points: [ShortInterestPoint]

    var body: some View {
        GeometryReader { geometry in
            let maxValue = max(points.map { $0.shortInterestPercent }.max() ?? 1, 1)
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottomLeading) {
                HStack(alignment: .bottom, spacing: DSSpacing.s) {
                    ForEach(points) { point in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(DSColors.positive)
                                .frame(height: height * CGFloat(point.shortInterestPercent / maxValue))
                            Text(point.label)
                                .font(DSTypography.caption)
                                .foregroundColor(DSColors.textSecondary)
                        }
                        .frame(width: width / CGFloat(max(points.count, 1)) - DSSpacing.s)
                    }
                }

                Path { path in
                    guard points.count > 1 else { return }
                    for (index, point) in points.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(max(points.count - 1, 1))
                        let y = height * (1 - CGFloat(point.daysToCover / 3.0))
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(DSColors.textPrimary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(height: 140)
        .accessibilityLabel("Short interest chart")
    }
}

struct ShortInterestChartView_Previews: PreviewProvider {
    static var previews: some View {
        ShortInterestChartView(points: [
            ShortInterestPoint(label: "Aug", shortInterestPercent: 3.2, daysToCover: 1.5),
            ShortInterestPoint(label: "Sep", shortInterestPercent: 3.6, daysToCover: 1.7),
            ShortInterestPoint(label: "Oct", shortInterestPercent: 3.1, daysToCover: 1.6),
            ShortInterestPoint(label: "Nov", shortInterestPercent: 2.9, daysToCover: 1.4),
            ShortInterestPoint(label: "Dec", shortInterestPercent: 3.3, daysToCover: 1.8)
        ])
        .padding()
        .background(DSColors.background)
    }
}
