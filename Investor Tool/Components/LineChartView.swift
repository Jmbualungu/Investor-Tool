import SwiftUI

struct LineChartView: View {
    let data: [Double]
    let lineColor: Color

    var body: some View {
        GeometryReader { geometry in
            let points = normalizedPoints(in: geometry.size)

            ZStack {
                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: first)
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(height: 180)
        .accessibilityLabel("Price chart")
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard let minValue = data.min(), let maxValue = data.max(), maxValue > minValue else {
            return []
        }
        return data.enumerated().map { index, value in
            let x = size.width * CGFloat(index) / CGFloat(max(data.count - 1, 1))
            let y = size.height * (1 - CGFloat((value - minValue) / (maxValue - minValue)))
            return CGPoint(x: x, y: y)
        }
    }
}

struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartView(data: [1, 2, 1.5, 3, 2.8, 3.2], lineColor: DSColors.accent)
            .padding()
            .background(DSColors.background)
    }
}
