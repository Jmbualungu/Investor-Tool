//
//  TickerDetailScreen.swift
//  Investor Tool
//
//  Simple ticker detail screen for routing test
//

import SwiftUI

struct TickerDetailScreen: View {
    let ticker: String
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Ticker Symbol
                Text(ticker)
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.blue)
                
                // Info
                VStack(spacing: 12) {
                    Text("Ticker Detail View")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Navigation working! ✓")
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Show AppState
                    Text("Tab: \(appState.selectedTab)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Placeholder content
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Company", value: "\(ticker) Inc.")
                    InfoRow(label: "Price", value: "$XXX.XX")
                    InfoRow(label: "Market Cap", value: "$XXX B")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle(ticker)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        TickerDetailScreen(ticker: "AAPL")
            .environmentObject(AppState())
    }
}
