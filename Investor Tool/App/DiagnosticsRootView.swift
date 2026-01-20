//
//  DiagnosticsRootView.swift
//  Investor Tool
//
//  Minimal root view to verify SwiftUI rendering works
//

import SwiftUI

struct DiagnosticsRootView: View {
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("DIAGNOSTICS ROOT")
                    .font(.largeTitle)
                    .bold()
                
                Text("If you can see this, the app is launching and rendering SwiftUI.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(Date().description)
                    .font(.caption)
                
                Divider()
                    .padding()
                
                Text("App is running")
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            }
            .padding()
        }
    }
}

#Preview {
    DiagnosticsRootView()
}
