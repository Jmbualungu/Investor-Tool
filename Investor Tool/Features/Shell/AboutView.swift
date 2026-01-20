import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                    .font(.system(size: 56, weight: .medium))
                                    .foregroundColor(DSColors.accent)
                                
                                Spacer()
                            }
                            
                            Text("Forecast AI")
                                .dsTitle()
                            
                            Text("A powerful DCF valuation tool built for iOS")
                                .dsBody()
                        }
                    }
                    
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("Version")
                                .dsCaption()
                            Text("1.0.0")
                                .dsHeadline()
                        }
                    }
                    
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("About")
                                .dsCaption()
                            Text("This app helps you create discounted cash flow models and forecast investment returns with ease.")
                                .dsBody()
                        }
                    }
                }
                .padding(DSSpacing.l)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
