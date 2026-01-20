//
//  DebugHUD.swift
//  Investor Tool
//
//  Debug overlay showing build info and app state
//

import SwiftUI

struct DebugHUD: View {
    let buildStamp: String
    let hasSeenOnboarding: Bool
    let pathCount: Int
    let ticker: String?
    let onReset: () -> Void
    
    var body: some View {
        #if DEBUG
        VStack(alignment: .leading, spacing: 6) {
            Text("DEBUG HUD")
                .font(.caption)
                .bold()
            
            Text(buildStamp)
                .font(.caption2)
            
            Text("onboarding: \(hasSeenOnboarding ? "seen" : "not seen")")
                .font(.caption2)
            
            Text("path: \(pathCount)")
                .font(.caption2)
            
            Text("ticker: \(ticker ?? "nil")")
                .font(.caption2)
            
            Button("Reset App State") {
                onReset()
            }
            .font(.caption.bold())
            .buttonStyle(.bordered)
            .padding(.top, 4)
        }
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        #else
        EmptyView()
        #endif
    }
}

#Preview {
    DebugHUD(
        buildStamp: "BuildStamp-001",
        hasSeenOnboarding: true,
        pathCount: 2,
        ticker: "AAPL"
    ) {
        print("Reset tapped")
    }
    .padding()
}
