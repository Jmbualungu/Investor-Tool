import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Quote Model (using shared InvestorQuotes)
private let INVESTOR_QUOTES: [InvestorQuote] = [
    InvestorQuote(
        text: "Risk comes from not knowing what you're doing.",
        author: "Warren Buffett"
    ),
    InvestorQuote(
        text: "An investment operation is one which, upon thorough analysis, promises safety of principal and an adequate return.",
        author: "Benjamin Graham"
    ),
    InvestorQuote(
        text: "All intelligent investing is value investing — acquiring more than you are paying for.",
        author: "Charlie Munger"
    )
]

struct LandingView: View {
    let onStart: () -> Void
    let onLogin: () -> Void
    
    @State private var currentPage = 0
    @State private var disclaimerScrolledToBottom = false
    @State private var disclaimerCheckboxAccepted = false
    @StateObject private var disclaimerManager = DisclaimerManager()
    @State private var currentQuoteIndex = Int.random(in: 0..<INVESTOR_QUOTES.count)
    
    private let totalPages = 5
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    featuresPage.tag(1)
                    howItWorksPage.tag(2)
                    disclaimerPage.tag(3)
                    getStartedPage.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                // Pagination Dots
                paginationDots
                    .padding(.bottom, DSSpacing.m)
                
                // CTA Buttons (only show on last page)
                if currentPage == 4 {
                    ctaButtons
                        .padding(.horizontal, DSSpacing.l)
                        .padding(.bottom, DSSpacing.xl)
                        .transition(.opacity)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startQuoteRotation()
        }
    }
    
    // MARK: - Quote Rotation
    private func startQuoteRotation() {
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentQuoteIndex = (currentQuoteIndex + 1) % INVESTOR_QUOTES.count
            }
        }
    }
    
    // MARK: - Page 1: Welcome
    private var welcomePage: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()
            
            logoView
            
            quoteView
                .padding(.bottom, DSSpacing.s)
            
            VStack(spacing: DSSpacing.m) {
                Text("Welcome to ForecastAI")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Unlock Future Insights")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DSSpacing.l)
            
            Spacer()
        }
    }
    
    // MARK: - Page 2: Features
    private var featuresPage: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()
            
            logoView
            
            quoteView
                .padding(.bottom, DSSpacing.s)
            
            VStack(spacing: DSSpacing.l) {
                Text("Data-Driven Predictions")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.l)
                
                VStack(spacing: DSSpacing.l) {
                    featureRow(
                        icon: "chart.xyaxis.line",
                        title: "Historical Analysis",
                        description: "Deep insights from market data"
                    )
                    
                    featureRow(
                        icon: "brain.head.profile",
                        title: "AI-Powered Forecasts",
                        description: "Advanced algorithms predict trends"
                    )
                    
                    featureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Growth Projections",
                        description: "Visualize potential returns"
                    )
                }
                .padding(.horizontal, DSSpacing.l)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Page 3: Financial Disclaimer
    private var disclaimerPage: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: DSSpacing.l) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "exclamationmark.shield.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Title
                Text("Important Financial Disclaimer")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.l)
                
                // Scrollable disclaimer text
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: DSSpacing.m) {
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scroll")).origin.y
                                )
                            }
                            .frame(height: 0)
                            
                            Text(disclaimerText)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(4)
                            
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(DSSpacing.l)
                    }
                    .frame(maxHeight: 300)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        // Check if scrolled near bottom (within 50 points)
                        if value < -50 {
                            disclaimerScrolledToBottom = true
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.l)
                
                // Scroll indicator
                if !disclaimerScrolledToBottom {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Please scroll to continue")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
                }
                
                // Checkbox
                Button(action: {
                    if disclaimerScrolledToBottom {
                        disclaimerCheckboxAccepted.toggle()
                    }
                }) {
                    HStack(alignment: .top, spacing: DSSpacing.s) {
                        Image(systemName: disclaimerCheckboxAccepted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(disclaimerScrolledToBottom ? .white : .white.opacity(0.3))
                        
                        Text("I have read and understand that ForecastAI does not provide financial advice.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(disclaimerScrolledToBottom ? .white : .white.opacity(0.5))
                            .multilineTextAlignment(.leading)
                    }
                }
                .disabled(!disclaimerScrolledToBottom)
                .padding(.horizontal, DSSpacing.l)
                .padding(.top, DSSpacing.s)
                
                // Continue button
                Button(action: {
                    disclaimerManager.accept()
                    withAnimation {
                        currentPage = 4
                    }
                }) {
                    Text("Accept & Continue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            (disclaimerScrolledToBottom && disclaimerCheckboxAccepted) 
                                ? DSColors.accentPurple 
                                : Color.white.opacity(0.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .disabled(!(disclaimerScrolledToBottom && disclaimerCheckboxAccepted))
                .padding(.horizontal, DSSpacing.l)
                .padding(.top, DSSpacing.m)
            }
            
            Spacer()
        }
    }
    
    private var disclaimerText: String {
        """
        ForecastAI is provided for informational and educational purposes only and does not constitute financial, investment, legal, or tax advice.
        
        The forecasts, projections, analyses, and outputs generated by this application are based on user-provided assumptions, historical data, and modeled scenarios. They are inherently forward-looking and subject to uncertainty, risk, and change.
        
        ForecastAI does not make any representations or warranties regarding the accuracy, completeness, or reliability of any information or results produced. Past performance is not indicative of future results.
        
        You acknowledge that any investment or financial decisions you make are your sole responsibility, and you should consult with a qualified financial advisor, accountant, or other professional before making any investment decisions.
        
        By continuing, you agree that ForecastAI, its creators, affiliates, and partners shall not be liable for any losses, damages, or claims arising from the use of this application.
        """
    }
    
    // MARK: - Page 3: How It Works
    private var howItWorksPage: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()
            
            logoView
            
            quoteView
                .padding(.bottom, DSSpacing.s)
            
            VStack(spacing: DSSpacing.l) {
                Text("Simple 3-Step Process")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.l)
                
                VStack(spacing: DSSpacing.l) {
                    stepRow(number: "1", title: "Select your ticker", icon: "magnifyingglass")
                    stepRow(number: "2", title: "Set assumptions", icon: "slider.horizontal.3")
                    stepRow(number: "3", title: "View forecasts", icon: "chart.bar.fill")
                }
                .padding(.horizontal, DSSpacing.l)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Page 4: Get Started
    private var getStartedPage: some View {
        VStack(spacing: 0) {
            Spacer()
            
            logoView
                .padding(.bottom, DSSpacing.xl)
            
            VStack(spacing: DSSpacing.m) {
                Text("Welcome to ForecastAI")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Unlock Future Insights")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, DSSpacing.l)
            .padding(.bottom, DSSpacing.xl)
            
            // Disclaimer Section
            disclaimerSection
                .padding(.horizontal, DSSpacing.xl)
            
            Spacer()
        }
    }
    
    // MARK: - Components
    
    private var quoteView: some View {
        VStack(spacing: 4) {
            Text("\"\(INVESTOR_QUOTES[currentQuoteIndex].text)\"")
                .font(.system(size: 15, weight: .regular))
                .italic()
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
            
            Text("— \(INVESTOR_QUOTES[currentQuoteIndex].author)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, DSSpacing.l)
        .frame(minHeight: 60)
        .id(currentQuoteIndex) // Force view replacement for animation
        .transition(.opacity)
    }
    
    private var logoView: some View {
        Group {
            if let uiImage = UIImage(named: "app_logo") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DSColors.accentPurple.opacity(0.3),
                                    DSColors.accentPurple.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(DSColors.accentPurple)
                }
            }
        }
    }
    
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.m) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(DSColors.accentPurple)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
    
    private func stepRow(number: String, title: String, icon: String) -> some View {
        HStack(spacing: DSSpacing.m) {
            ZStack {
                Circle()
                    .fill(DSColors.accentPurple)
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(DSColors.accentPurple.opacity(0.6))
        }
        .padding(DSSpacing.m)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var disclaimerSection: some View {
        VStack(spacing: 6) {
            Text("Forecasts are based on historical data and predictive models.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 4) {
                Text("Review our")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                
                Button("methodology") {
                    // TODO: Navigate to About/Settings
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                
                Text("to learn more.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("Future performance is not guaranteed.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
    }
    
    private var paginationDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }
    
    private var ctaButtons: some View {
        VStack(spacing: DSSpacing.m) {
            // Primary Button
            Button(action: onStart) {
                Text("Start Forecasting")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(DSColors.accentPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: DSColors.accentPurpleGlow, radius: 12, x: 0, y: 6)
            }
            
            // Secondary Button
            Button(action: onLogin) {
                Text("Access Your Account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, DSSpacing.s)
        }
    }
}

// MARK: - Preference Key for Scroll Tracking
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    NavigationStack {
        LandingView(onStart: {}, onLogin: {})
    }
}
