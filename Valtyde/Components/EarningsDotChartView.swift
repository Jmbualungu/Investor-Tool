import SwiftUI

struct EarningsDotChartView: View {
    let points: [EarningsPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            HStack(spacing: DSSpacing.l) {
                legendDot(color: DSColors.textSecondary, label: "Estimated EPS")
                legendDot(color: DSColors.accent, label: "Actual EPS")
            }

            HStack(alignment: .bottom, spacing: DSSpacing.m) {
                ForEach(points) { point in
                    VStack(spacing: DSSpacing.xs) {
                        ZStack {
                            Circle()
                                .fill(DSColors.textSecondary.opacity(0.4))
                                .frame(width: 10, height: 10)
                                .offset(y: -dotOffset(for: point.estimatedEPS))

                            if let actual = point.actualEPS {
                                Circle()
                                    .fill(DSColors.accent)
                                    .frame(width: 12, height: 12)
                                    .offset(y: -dotOffset(for: actual))
                            }
                        }
                        .frame(height: 70)

                        Text(point.quarter)
                            .font(DSTypography.caption)
                            .foregroundColor(DSColors.textSecondary)
                    }
                }
            }
        }
        .accessibilityLabel("Earnings chart")
    }

    private func dotOffset(for value: Double) -> CGFloat {
        let maxValue = max(points.map { max($0.estimatedEPS, $0.actualEPS ?? 0) }.max() ?? 1, 0.1)
        return CGFloat(value / maxValue) * 50
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
        }
    }
}

struct EarningsDotChartView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsDotChartView(points: [
            EarningsPoint(quarter: "Q4 FY24", estimatedEPS: 0.62, actualEPS: 0.71),
            EarningsPoint(quarter: "Q1 FY25", estimatedEPS: 0.44, actualEPS: nil),
            EarningsPoint(quarter: "Q2 FY25", estimatedEPS: 0.48, actualEPS: nil)
        ])
        .padding()
        .background(DSColors.background)
    }
}
