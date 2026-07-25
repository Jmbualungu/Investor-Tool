import SwiftUI

struct KeyStatsGridView: View {
    let stats: KeyStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "Key Stats")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.s) {
                statCell(label: "Volume", value: Formatters.formatVolume(stats.volume))
                statCell(label: "Overnight vol", value: Formatters.formatVolume(stats.overnightVolume))
                statCell(label: "Avg vol", value: Formatters.formatVolume(stats.avgVolume))
                statCell(label: "Open", value: Formatters.formatCurrency(stats.open))
                statCell(label: "High / Low", value: Formatters.formatHighLow(high: stats.high, low: stats.low))
                statCell(label: "Market cap", value: Formatters.formatMarketCap(stats.marketCap))
                statCell(label: "52-week high / low", value: Formatters.formatHighLow(high: stats.week52High, low: stats.week52Low))
                statCell(label: "P/E ratio", value: Formatters.formatNumber(stats.peRatio))
                statCell(label: "Dividend yield", value: Formatters.formatPercent(stats.dividendYield))
                statCell(label: "Borrow rate", value: Formatters.formatPercent(stats.borrowRate))
                statCell(label: "Short inventory", value: Formatters.formatVolume(stats.shortInventory))
            }
        }
    }
    
    private func statCell(label: String, value: String) -> some View {
        DSStatCell(label: label, value: value)
    }
}

struct KeyStatsGridView_Previews: PreviewProvider {
    static var previews: some View {
        let stats = KeyStats(
            volume: 84_216_300,
            open: 186.50,
            high: 188.20,
            low: 185.40,
            avgVolume: 92_100_000,
            marketCap: 2_800_000_000_000,
            week52High: 199.62,
            week52Low: 164.08,
            peRatio: 29.5,
            dividendYield: 0.52,
            shortInventory: 125_000_000,
            borrowRate: 0.15,
            overnightVolume: 5_200_000
        )
        
        return VStack {
            KeyStatsGridView(stats: stats)
                .padding()
        }
        .background(DSColors.background)
    }
}
