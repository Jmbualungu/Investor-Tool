//
//  DebugHUDView.swift
//  Investor Tool
//
//  Debug overlay showing current state
//

import SwiftUI

struct DebugHUDView: View {
    @EnvironmentObject var router: FlowRouter
    @EnvironmentObject var config: GlobalAppConfig
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isExpanded {
                expandedView
            } else {
                collapsedView
            }
        }
        .background(Color.black.opacity(0.85))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        .padding(8)
    }
    
    private var collapsedView: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(config.safeMode ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text("DEBUG")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Button(action: { withAnimation { isExpanded = true } }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
    
    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("DEBUG HUD")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { withAnimation { isExpanded = false } }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            debugRow(label: "Route", value: router.path.last?.displayName ?? "Root")
            debugRow(label: "Depth", value: "\(router.path.count)")
            debugRow(label: "Ticker", value: router.selectedTicker?.symbol ?? "None")
            
            HStack(spacing: 4) {
                Text("Safe:")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                
                Circle()
                    .fill(config.safeMode ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(config.safeMode ? "ON" : "OFF")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(config.safeMode ? .green : .red)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            HStack(spacing: 6) {
                debugButton("Reset", icon: "arrow.counterclockwise") {
                    router.reset()
                }
                
                debugButton("Safe", icon: config.safeMode ? "checkmark.shield.fill" : "shield.slash.fill") {
                    config.toggleSafeMode()
                }
            }
        }
        .padding(8)
        .frame(minWidth: 160)
    }
    
    private func debugRow(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text("\(label):")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
    
    private func debugButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
                Text(title)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.2))
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        VStack {
            HStack {
                DebugHUDView()
                    .environmentObject(FlowRouter())
                    .environmentObject(GlobalAppConfig())
                Spacer()
            }
            Spacer()
        }
    }
}
