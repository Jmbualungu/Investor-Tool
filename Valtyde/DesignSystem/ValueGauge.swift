import SwiftUI

/// The Valtyde signature: a vertical gauge showing the gap between the market
/// **price** (grey marker) and the value Valtyde **predicts** (cyan marker),
/// with the margin-of-safety band tinted green (undervalued) or red (over).
/// Pure shapes — screens compose their own labels around it.
struct ValueGauge: View {
    let price: Double
    let value: Double
    var markerRadius: CGFloat = 6

    private var mos: Double { price > 0 ? (value - price) / price : 0 }
    private var undervalued: Bool { value >= price }

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let cx = geo.size.width / 2

            // Gap encodes magnitude (bigger margin → bigger band); direction
            // puts the cyan value marker up when undervalued.
            let gap = min(max(abs(mos) * 2.0, 0.16), 0.66)
            let clamp: (Double) -> Double = { min(max($0, 0.10), 0.90) }
            let valueFrac = clamp(undervalued ? 0.5 - gap / 2 : 0.5 + gap / 2)
            let priceFrac = clamp(undervalued ? 0.5 + gap / 2 : 0.5 - gap / 2)
            let valueY = h * valueFrac
            let priceY = h * priceFrac
            let bandTop = min(valueY, priceY)
            let bandBottom = max(valueY, priceY)
            let bandColor = undervalued ? DSColors.positive : DSColors.negative

            ZStack {
                // track
                Capsule()
                    .fill(DSColors.border)
                    .frame(width: 3, height: h * 0.86)
                    .position(x: cx, y: h / 2)

                // margin-of-safety band
                RoundedRectangle(cornerRadius: markerRadius)
                    .fill(bandColor.opacity(0.24))
                    .frame(width: markerRadius * 2, height: max(0, bandBottom - bandTop))
                    .position(x: cx, y: (bandTop + bandBottom) / 2)

                // market price marker (grey)
                Circle()
                    .fill(DSColors.textSecondary)
                    .frame(width: markerRadius * 2, height: markerRadius * 2)
                    .position(x: cx, y: priceY)

                // predicted value marker (cyan, glowing)
                Circle()
                    .fill(DSColors.cyan)
                    .frame(width: markerRadius * 2.1, height: markerRadius * 2.1)
                    .shadow(color: DSColors.cyan.opacity(0.7), radius: markerRadius * 0.9)
                    .position(x: cx, y: valueY)
            }
        }
    }
}

/// Compact gauge for list rows (~34×38).
struct MicroValueGauge: View {
    let price: Double
    let value: Double

    var body: some View {
        ValueGauge(price: price, value: value, markerRadius: 3.2)
            .frame(width: 34, height: 38)
    }
}

#Preview {
    HStack(spacing: 30) {
        ValueGauge(price: 212.40, value: 230.10).frame(width: 56, height: 180)
        ValueGauge(price: 190.20, value: 155.00).frame(width: 56, height: 180)
        MicroValueGauge(price: 212, value: 230)
    }
    .padding(40)
    .background(DSColors.background)
}
