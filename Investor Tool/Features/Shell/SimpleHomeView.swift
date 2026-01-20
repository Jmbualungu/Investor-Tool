//
//  SimpleHomeView.swift
//  Investor Tool
//
//  Simplified HomeView for Step 1 - no dependencies
//

import SwiftUI

struct SimpleHomeView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Forecast")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Build DCF models and analyze investment opportunities")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // STEP 3: Show AppState
                        Text("Logged in: \(appState.isLoggedIn ? "Yes" : "No") | Tab: \(appState.selectedTab)")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }
                    .padding(.top, 40)
                    
                    // Start Forecast Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("New Forecast")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Create a DCF valuation model")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        NavigationLink(destination: SimpleDetailView(title: "Ticker Search")) {
                            HStack {
                                Text("Start Forecast")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Recent Tickers
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            ForEach(["AAPL", "MSFT", "NVDA"], id: \.self) { ticker in
                                NavigationLink(destination: SimpleDetailView(title: ticker)) {
                                    Text(ticker)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            
            // Settings Button (top-right)
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: SimpleDetailView(title: "Settings")) {
                        Image(systemName: "gear")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct SimpleDetailView: View {
    let title: String
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Detail screen for \(title)")
                    .foregroundColor(.gray)
                
                Text("Navigation works! ✓")
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SimpleHomeView()
            .environmentObject(AppState())
    }
}
