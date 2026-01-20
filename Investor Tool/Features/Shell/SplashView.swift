import SwiftUI

struct SplashView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            VStack(spacing: DSSpacing.xl) {
                Spacer()
                
                // App Icon/Logo
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(DSColors.accent)
                    .dsGlow(color: DSColors.accentGlow, radius: 20)
                
                VStack(spacing: DSSpacing.s) {
                    Text("Forecast AI")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(DSColors.textPrimary)
                    
                    Text("DCF Valuation Made Simple")
                        .dsBody()
                }
                
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: DSColors.accent))
                    .scaleEffect(1.2)
            }
            .padding(DSSpacing.xl)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onContinue()
            }
        }
    }
}

#Preview {
    SplashView(onContinue: {})
}
